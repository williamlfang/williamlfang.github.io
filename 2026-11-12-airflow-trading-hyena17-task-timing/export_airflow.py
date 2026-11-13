"""Read-only export of the latest 20 completed trading.hyena17 scheduled runs.

Run inside the existing Airflow container: python export_airflow.py
Save that output locally, then run: python export_airflow.py --write-snapshot OUTPUT
Only task timing and non-secret configuration fields are exported.
"""
import csv
from datetime import datetime, timezone
import io
import json
import os
from pathlib import Path
import sys
import tempfile

DAG_ID = 'trading.hyena17'
PREFIX = 'AIRFLOW_TIMING_JSON='
FIELDS = ['date', 'task_id', 'attempt', 'started_at', 'ended_at', 'state', 'queue_seconds', 'source']


def utc(value):
    if value is None:
        return None
    if isinstance(value, str):
        value = datetime.fromisoformat(value)
    return value.replace(tzinfo=timezone.utc) if value.tzinfo is None else value.astimezone(timezone.utc)


def reconstruct(events, tasks, failures):
    rows, pending, unmatched = [], {}, 0
    for event in events:
        key = event['execution_date'], event['task_id']
        if event['event'] == 'running':
            if key in pending:
                rows.append(pending.pop(key))
            pending[key] = {'date': str(event['execution_date'])[:10], 'task_id': event['task_id'],
                            'started_at': utc(event['dttm']), 'ended_at': None, 'state': 'unknown',
                            'queue_seconds': None, 'source': 'audit_log_unfinished'}
        elif key in pending:
            row = pending.pop(key)
            row.update(ended_at=utc(event['dttm']), state=event['event'], source='audit_log')
            rows.append(row)
        else:
            unmatched += 1
    rows.extend(pending.values())
    lookup = {}
    for row in rows:
        lookup.setdefault((row['date'], row['task_id']), []).append(row)
    for records, source in [(tasks, 'task_instance'), (failures, 'task_fail')]:
        for task in records:
            start, end = utc(task['start_date']), utc(task['end_date'])
            if start is None:
                continue
            day = task['run_id'][len('scheduled__'):len('scheduled__') + 10]
            state = task.get('state', 'failed')
            candidates = lookup.get((day, task['task_id']), [])
            match = next((row for row in candidates if abs((row['started_at'] - start).total_seconds()) < 1
                          and ((row['state'] == 'unknown' and row['ended_at'] is None)
                               or (row['state'] == state and row['ended_at'] and end
                                   and abs((row['ended_at'] - end).total_seconds()) < 1))), None)
            if match is None:
                if end is None or state not in ['success', 'failed'] or task.get('operator') != 'EmptyOperator':
                    continue
                match = {'date': day, 'task_id': task['task_id'], 'queue_seconds': None}
                rows.append(match)
                lookup.setdefault((day, task['task_id']), []).append(match)
            match.update(started_at=start, ended_at=end, state=state, source=source)
            queued = utc(task.get('queued_dttm'))
            if queued and queued <= start:
                match['queue_seconds'] = (start - queued).total_seconds()
    rows.sort(key=lambda row: (row['date'], row['task_id'], row['started_at']))
    counts = {}
    for row in rows:
        key = row['date'], row['task_id']
        counts[key] = counts.get(key, 0) + 1
        row['attempt'] = counts[key]
        row['started_at'] = row['started_at'].isoformat()
        row['ended_at'] = row['ended_at'].isoformat() if row['ended_at'] else ''
    return rows, unmatched


def capture():
    import airflow
    from airflow import settings
    from airflow.configuration import conf
    from sqlalchemy import bindparam, text

    engine = settings.engine
    with engine.connect() as conn:
        if engine.dialect.name == 'mysql':
            conn.execute(text('SET SESSION TRANSACTION READ ONLY'))
        def read(query, values):
            return [dict(row._mapping) for row in conn.execute(query, values)]
        runs = read(text("SELECT run_id,execution_date,start_date,end_date,state,dag_hash FROM dag_run "
                         "WHERE dag_id=:dag AND run_type='scheduled' AND state IN ('success','failed') "
                         "ORDER BY execution_date DESC LIMIT 20"), {'dag': DAG_ID})
        if not runs:
            raise ValueError('No completed scheduled runs found')
        params = {'dag': DAG_ID, 'runs': [row['run_id'] for row in runs]}
        def task_rows(table, columns):
            query = text('SELECT ' + columns + ' FROM ' + table
                         + ' WHERE dag_id=:dag AND run_id IN :runs').bindparams(bindparam('runs', expanding=True))
            return read(query, params)
        tasks = task_rows('task_instance', 'run_id,task_id,state,start_date,end_date,queued_dttm,operator')
        failures = task_rows('task_fail', 'run_id,task_id,start_date,end_date')
        query = text("SELECT dttm,task_id,event,execution_date FROM log WHERE dag_id=:dag "
                     "AND execution_date IN :dates AND event IN ('running','success','failed') "
                     "ORDER BY execution_date,task_id,dttm,id").bindparams(bindparam('dates', expanding=True))
        events = read(query, {'dag': DAG_ID, 'dates': [row['execution_date'] for row in runs]})
    attempts, unmatched = reconstruct(events, tasks, failures)
    metadata = {'collected_at_utc': datetime.now(timezone.utc).isoformat(), 'dag_id': DAG_ID,
                'airflow_version': airflow.__version__, 'timezone': conf.get('core', 'default_timezone'),
                'executor': conf.get('core', 'executor'),
                'config': {key: conf.get(section, key) for section, key in [
                    ('core', 'parallelism'), ('core', 'max_active_tasks_per_dag'),
                    ('core', 'max_active_runs_per_dag'), ('scheduler', 'scheduler_heartbeat_sec')]},
                'scheduled_dates': sorted(str(row['execution_date'])[:10] for row in runs),
                'dag_hashes': len({row['dag_hash'] for row in runs}), 'current_task_rows': len(tasks),
                'failure_rows': len(failures), 'audit_event_count': len(events),
                'ignored_terminals_without_start': unmatched}
    run_rows = [{'date': str(row['execution_date'])[:10], 'state': row['state'],
                 'metadata_start_utc': utc(row['start_date']).isoformat() if row['start_date'] else '',
                 'metadata_end_utc': utc(row['end_date']).isoformat() if row['end_date'] else ''}
                for row in reversed(runs)]
    return {'metadata': metadata, 'attempts': attempts, 'runs': run_rows}


def csv_text(rows, fields):
    buffer = io.StringIO(newline='')
    writer = csv.DictWriter(buffer, fieldnames=fields)
    writer.writeheader()
    writer.writerows(rows)
    return buffer.getvalue()


def write_snapshot(path):
    lines = [line[len(PREFIX):] for line in Path(path).read_text().splitlines() if line.startswith(PREFIX)]
    if len(lines) != 1:
        raise ValueError('Expected exactly one complete timing snapshot in the SSH output')
    snapshot = json.loads(lines[0])
    if snapshot['metadata']['dag_id'] != DAG_ID or not snapshot['attempts']:
        raise ValueError('Wrong DAG or empty task snapshot')
    contents = {
        'attempts.csv': csv_text(snapshot['attempts'], FIELDS),
        'metadata.json': json.dumps(snapshot['metadata'], indent=2) + '\n',
        'runs.csv': csv_text(snapshot['runs'], ['date', 'state', 'metadata_start_utc', 'metadata_end_utc']),
    }
    root = Path(__file__).resolve().parent
    for name, content in contents.items():
        with tempfile.NamedTemporaryFile(mode='w', dir=root, prefix='.' + name, delete=False) as handle:
            handle.write(content)
            temporary = handle.name
        os.replace(temporary, root / name)
    print('Saved timing snapshot for ' + snapshot['metadata']['scheduled_dates'][-1])


if __name__ == '__main__':
    if len(sys.argv) == 3 and sys.argv[1] == '--write-snapshot':
        write_snapshot(sys.argv[2])
    elif len(sys.argv) == 1:
        print(PREFIX + json.dumps(capture()))
    else:
        raise SystemExit('Usage: export_airflow.py [--write-snapshot SSH_OUTPUT]')
