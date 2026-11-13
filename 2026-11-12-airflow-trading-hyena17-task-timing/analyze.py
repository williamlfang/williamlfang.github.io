"""Regenerate this post's figures and tables from its snapshot with original Airflow identifiers.

Run: python analyze.py
Requires pandas, numpy, and matplotlib. Does not connect to Airflow.
"""
import json
from pathlib import Path

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.colors import TwoSlopeNorm
import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parent
TZ = 'Asia/Shanghai'
INCIDENT = '2026-11-11'
META = json.loads((ROOT / 'metadata.json').read_text())
LATEST = max(META['scheduled_dates'])
BLUE, RED, GOLD, GREEN = '#2563a6', '#c2413b', '#d49b32', '#138575'
plt.rcParams.update({'font.family': 'DejaVu Sans', 'font.size': 10, 'axes.spines.top': False,
                     'axes.spines.right': False, 'axes.titleweight': 'bold', 'savefig.facecolor': 'white'})


def family(task):
    for prefix, label in [
        ('zsun_live_trade_stock_target_pos_', 'Live stock session'),
        ('zsun_live_trade_futures_target_pos_', 'Live futures session'),
        ('zsun_pre_trade_stock_target_pos_', 'Stock targets'),
        ('zsun_pre_trade_futures_target_pos_', 'Futures targets'),
        ('zfu_param_to_R7.', 'Relay transfer'),
        ('zfu_param_to_', 'Host transfer'),
        ('zfu_param_', 'Parameter generation'),
        ('zfu_check_', 'Parameter checks'),
        ('h17.trading.shared_', 'Shared service startup'),
        ('h17.trading.raven_snap_', 'Snapshot service startup'),
        ('h17.trading.', 'Stock algo launch'),
        ('futures_hedge.check.', 'Hedge checks'),
        ('futures_hedge.trading.', 'Futures algo launch'),
        ('wait_until_', 'Intentional wait'),
    ]:
        if task.startswith(prefix):
            return label
    return {'zsun_pre_trade_stock_weight': 'Stock weight', 'redis_tpc': 'Redis startup',
            'futures_hedge.risk': 'Futures risk', 'futures_hedge.param': 'Futures parameters'}.get(task, 'Other setup')


def save(fig, name):
    fig.savefig(ROOT / name, dpi=165, bbox_inches='tight')
    plt.close(fig)


def clock(seconds):
    return (pd.Timestamp('2000-01-01 09:30') + pd.Timedelta(seconds=float(seconds))).strftime('%H:%M:%S')


def short(task):
    for prefix, label in [
        ('zsun_pre_trade_stock_target_pos_', 'Stock target position'),
        ('h17.trading.shared_', 'Shared services'),
        ('h17.trading.', 'Stock algo launch'),
        ('zfu_param_to_R7.', 'zfu_param_to_R7'),
        ('zfu_param_to_', 'zfu_param_to'),
        ('zfu_param_', 'zfu_param'),
        ('zfu_check_', 'zfu_check'),
        ('futures_hedge.trading.', 'Futures launch'),
    ]:
        if task.startswith(prefix):
            name = task[len(prefix):]
            return f'{label}: {name}'
    return task


def running_seconds_after_deadline(started, ended):
    cutoff = started.dt.normalize() + pd.Timedelta(hours=9, minutes=30)
    runtime = (ended - started).dt.total_seconds()
    late = (ended - cutoff).dt.total_seconds().clip(lower=0)
    return np.minimum(runtime, late)


def load_attempts():
    df = pd.read_csv(ROOT / 'attempts.csv')
    for col in ['started_at', 'ended_at']:
        df[col] = pd.to_datetime(df[col], utc=True).dt.tz_convert(TZ)
    df['family'] = df.task_id.map(family)
    cutoff = df.started_at.dt.normalize() + pd.Timedelta(hours=9, minutes=30)
    df['runtime_s'] = (df.ended_at - df.started_at).dt.total_seconds()
    df['finish_offset_s'] = (df.ended_at - cutoff).dt.total_seconds()
    df['start_offset_s'] = (df.started_at - cutoff).dt.total_seconds()
    df['running_after_s'] = running_seconds_after_deadline(df.started_at, df.ended_at)
    assert df.loc[df.ended_at.notna(), 'runtime_s'].ge(0).all(), 'Negative duration'
    assert df.queue_seconds.dropna().ge(0).all(), 'Negative queue delay'
    assert df.running_after_s.dropna().ge(0).all()
    assert (df.running_after_s.dropna() <= df.runtime_s.dropna() + 0.001).all()
    return df


def run():
    df = load_attempts()
    morning = df[df.started_at.dt.strftime('%Y-%m-%d').eq(df.date)
                 & df.started_at.dt.hour.ge(9) & df.started_at.dt.hour.lt(12)].copy()
    first = morning.sort_values('started_at').drop_duplicates(['date', 'task_id'])
    success = first[first.state.eq('success')].copy()
    latest = success[success.date.eq(LATEST)].copy()
    session = latest.family.str.startswith('Live ')
    setup = latest[~session & ~latest.family.eq('Intentional wait')].copy()
    available_dates = sorted(success.loc[success.family.eq('Stock weight'), 'date'].unique())
    baseline = success[success.date.isin(set(available_dates) - {INCIDENT})]

    # Readiness uses the first successful morning attempt, including recovery attempts.
    recovered = morning[morning.state.eq('success')].sort_values('ended_at').drop_duplicates(['date', 'task_id'])
    history = []
    for day in META['scheduled_dates']:
        g = recovered[recovered.date.eq(day)]
        def offset(label, agg='max'):
            v = g.loc[g.family.eq(label), 'finish_offset_s']
            return getattr(v, agg)() if len(v) else np.nan
        history.append({'date': day, 'Stock weight done': offset('Stock weight'),
                        'First stock target': offset('Stock targets', 'min'),
                        'Last stock target': offset('Stock targets'), 'Redis done': offset('Redis startup'),
                        'Last algo launch': offset('Stock algo launch'), 'Last shared ready': offset('Shared service startup')})
    history = pd.DataFrame(history).set_index('date')
    history.to_csv(ROOT / 'daily-readiness.csv', float_format='%.3f')

    # Latest morning timeline, with queues shown only when the original queue timestamp survived.
    stock = latest[latest.family.eq('Stock targets')].sort_values('ended_at')
    slow_shared = latest[latest.family.eq('Shared service startup')].nlargest(4, 'runtime_s')
    algo = latest[latest.family.eq('Stock algo launch')].sort_values('task_id')
    shared = latest[latest.family.eq('Shared service startup')].sort_values('task_id')
    futures = latest[latest.family.eq('Futures algo launch')].sort_values('task_id')
    params = latest[latest.family.eq('Parameter generation')].sort_values('task_id')
    relay = latest[latest.family.eq('Relay transfer')].sort_values('task_id')
    transfers = latest[latest.family.eq('Host transfer')].sort_values('task_id')
    checks = latest[latest.family.eq('Parameter checks')].sort_values('task_id')
    account_colos = algo.task_id.str.removeprefix('h17.trading.').str.split('_', n=1)
    accounts = {parts[1] for parts in account_colos}
    colos = {parts[0] for parts in account_colos}
    assert accounts == set(latest.loc[latest.family.eq('Live stock session'), 'task_id'].str.removeprefix('zsun_live_trade_stock_target_pos_'))
    assert colos == set(shared.task_id.str.removeprefix('h17.trading.shared_'))
    assert set(futures.task_id.str.removeprefix('futures_hedge.trading.')) == set(latest.loc[latest.family.eq('Live futures session'), 'task_id'].str.removeprefix('zsun_live_trade_futures_target_pos_'))
    assert accounts == set(params.task_id.str.removeprefix('zfu_param_'))
    assert accounts == set(relay.task_id.str.removeprefix('zfu_param_to_R7.'))
    assert accounts == set(checks.task_id.str.removeprefix('zfu_check_'))
    assert colos == set(transfers.task_id.str.removeprefix('zfu_param_to_'))
    panels = [
        (f'{LATEST}: stock weight and all {len(stock)} fund targets', pd.concat([latest[latest.family.eq('Stock weight')], stock])),
        (f'zfu_param generation: all {len(params)} accounts', params),
        (f'zfu_param_to_R7 transfers: all {len(relay)} accounts', relay),
        (f'zfu_param_to_Colo transfers: all {len(transfers)} colos', transfers),
        (f'zfu_check validation: all {len(checks)} accounts', checks),
        (f'Stock algo launches: {len(accounts)} accounts, {len(colos)} colos, {len(algo)} account/colo tasks', algo),
        (f'Shared services: all {len(shared)} colos', shared),
        (f'Redis, all {len(futures)} futures account launches, and risk', pd.concat([latest[latest.family.eq('Redis startup')], futures, latest[latest.family.eq('Futures risk')]])),
    ]
    timeline_families = ['Stock weight', 'Stock targets', 'Parameter generation', 'Relay transfer',
                         'Host transfer', 'Parameter checks', 'Stock algo launch',
                         'Shared service startup', 'Redis startup', 'Futures algo launch', 'Futures risk']
    expected_tasks = set(latest.loc[latest.family.isin(timeline_families), 'task_id'])
    drawn_tasks = [task for _, rows in panels for task in rows.task_id]
    assert len(drawn_tasks) == len(set(drawn_tasks)) and set(drawn_tasks) == expected_tasks
    fig, axes = plt.subplots(len(panels), 1, figsize=(16, sum(len(rows) for _, rows in panels)*.24+5),
                             gridspec_kw={'height_ratios': [len(rows)+3 for _, rows in panels]})
    for ax, (title, rows) in zip(axes, panels):
        ax.axvspan(0, 6.1, color=RED, alpha=.045)
        for y, row in enumerate(rows.itertuples()):
            start = row.start_offset_s / 60
            width = row.runtime_s / 60
            if pd.notna(row.queue_seconds):
                ax.barh(y, row.queue_seconds / 60, left=start-row.queue_seconds/60, height=.55, color=GOLD)
            ax.barh(y, width, left=start, height=.55, color=BLUE)
            ax.text(start+width+.04, y, f'{row.runtime_s:.1f}s', va='center', fontsize=8.5)
        ax.set_yticks(range(len(rows)), [short(s) for s in rows.task_id], fontsize=9)
        ax.invert_yaxis()
        ax.axvline(0, color=RED, lw=1.4)
        ax.set_xlim(-6.2, 6.05)
        ax.set_xticks(np.arange(-6, 7, 1), [clock(x*60)[:5] for x in range(-6, 7)])
        ax.set_title(title, loc='left', pad=14)
        ax.grid(axis='x', alpha=.18)
    axes[-1].set_xlabel('Local time, UTC+8. Blue = task running; amber = queued to running, where available.')
    fig.tight_layout()
    save(fig, 'morning-timeline.png')

    # Historical completion times, not summed parallel task durations.
    values = history.to_numpy(dtype=float)/60
    fig, ax = plt.subplots(figsize=(12, 10.2))
    cmap = plt.get_cmap('RdYlBu_r').copy()
    cmap.set_bad('#e2e5e9')
    image = ax.imshow(np.ma.masked_invalid(values), aspect='auto', cmap=cmap,
                      norm=TwoSlopeNorm(vmin=-10, vcenter=0, vmax=10))
    for y in range(len(history)):
        for x in range(len(history.columns)):
            value = history.iloc[y, x]
            ax.text(x, y, clock(value) if np.isfinite(value) else 'no record', ha='center', va='center', fontsize=8.5,
                    color='white' if np.isfinite(value) and abs(value)>480 else '#18212b')
    ax.set_xticks(range(len(history.columns)), [s.replace(' ', '\n', 1) for s in history.columns])
    ax.set_yticks(range(len(history)), [d + ('  * incident' if d == INCIDENT else '') for d in history.index])
    ax.set_title('Twenty scheduled dates: when did each stage finish?', loc='left', pad=18)
    ax.text(0, -.11, 'UTC+8. Gray = missing successful morning record, not an on-time completion.\n'
            'Color clips at +/-10 minutes; printed timestamps retain the full delay. Incident day is separate from baseline.',
            transform=ax.transAxes, fontsize=9)
    fig.colorbar(image, ax=ax, shrink=.8, label='Minutes relative to 09:30')
    fig.tight_layout()
    save(fig, 'readiness-history.png')

    # Rank own runtime after the deadline. This is not end-to-end lateness or CPU time.
    ranking = setup[setup.running_after_s.gt(0)].nlargest(14, 'running_after_s').sort_values('running_after_s')
    historical = baseline.groupby('task_id').running_after_s.quantile(.9)
    fig, ax = plt.subplots(figsize=(12, 7.8))
    ax.barh(range(len(ranking)), ranking.running_after_s, color=BLUE, height=.6, label=f'{LATEST} first attempt')
    p90 = [historical.get(t, np.nan) for t in ranking.task_id]
    ax.scatter(p90, np.arange(len(ranking))-.23, color=RED, marker='D', s=27, label='Historical p90, successful first attempts')
    for y, row in enumerate(ranking.itertuples()):
        ax.text(row.running_after_s+3, y, f'{row.running_after_s:.1f}s; done {row.ended_at:%H:%M:%S}', va='center', fontsize=8)
    ax.set_yticks(range(len(ranking)), [short(t) for t in ranking.task_id], fontsize=9)
    ax.set_xlim(0, max(ranking.running_after_s.max(), np.nanmax(p90))*1.34)
    ax.set_xlabel('Seconds this task was running after 09:30, excluding queue and upstream waits')
    ax.set_title('The longest setup tasks after the open are shared-service startups', loc='left', pad=18)
    ax.legend(loc='lower right', fontsize=8)
    ax.grid(axis='x', alpha=.18)
    fig.tight_layout()
    save(fig, 'late-task-ranking.png')

    # Dependency readiness and queue delay are different intervals.
    families = ['Stock weight', 'Stock targets', 'Parameter generation', 'Host transfer', 'Parameter checks',
                'Shared service startup', 'Stock algo launch', 'Redis startup', 'Futures algo launch', 'Hedge checks']
    family_rows=[]
    for label in families:
        g=setup[setup.family.eq(label)]
        b=baseline[baseline.family.eq(label)]
        family_rows.append({'family':label, 'latest_n':len(g), 'latest_runtime_p50_s':g.runtime_s.median(),
                            'latest_runtime_max_s':g.runtime_s.max(), 'latest_late_n':int(g.finish_offset_s.gt(0).sum()),
                            'latest_queue_n':int(g.queue_seconds.notna().sum()), 'latest_queue_p50_s':g.queue_seconds.median(),
                            'latest_queue_max_s':g.queue_seconds.max(), 'historical_n':len(b),
                            'historical_runtime_p50_s':b.runtime_s.median(), 'historical_runtime_p90_s':b.runtime_s.quantile(.9)})
    family_table=pd.DataFrame(family_rows)
    family_table.to_csv(ROOT/'family-summary.csv',index=False,float_format='%.3f')
    fig, axes = plt.subplots(1, 2, figsize=(12, 6.6))
    for ax, column, title, color in [(axes[0],'latest_runtime_p50_s','Median task runtime',BLUE),
                                    (axes[1],'latest_queue_p50_s','Median queued-to-running delay',GOLD)]:
        ax.barh(family_table.family, family_table[column], color=color, height=.6)
        ax.invert_yaxis()
        ax.set_title(title,loc='left')
        ax.set_xlabel('Seconds')
        ax.grid(axis='x',alpha=.18)
        for y, value in enumerate(family_table[column]):
            if pd.notna(value):
                ax.text(value+family_table[column].max()*.015,y,f'{value:.1f}',va='center',fontsize=9)
        ax.margins(x=.15)
    axes[1].tick_params(labelleft=False)
    fig.suptitle(f'{LATEST}: observed executor queue delays are much smaller than task runtime',x=.02,ha='left',fontweight='bold')
    fig.text(.02,.005,'Queue timestamps survive only for matching current task instances. Time before queueing is not measured here.',fontsize=9)
    fig.tight_layout(rect=[0,.03,1,.95])
    save(fig,'runtime-and-queue.png')

    # This is an observational change in recorded timings, not a controlled benchmark.
    weights = recovered[recovered.family.eq('Stock weight')].sort_values('date')
    fig, ax = plt.subplots(figsize=(11.5, 4.8))
    xpos = np.arange(len(weights))
    colors = [RED if d == INCIDENT else BLUE for d in weights.date]
    ax.bar(xpos, weights.runtime_s, color=colors, width=.65)
    ax.axhline(300, color=GOLD, ls='--', lw=1.4, label='300s request timeout seen in Nov 11-12 logs')
    ax.set_xticks(xpos, [d[5:] for d in weights.date], rotation=45, ha='right')
    ax.set_ylabel('Task runtime, seconds')
    ax.set_xlabel('Scheduled date, 2026. Earlier task logs are unavailable in the rebuilt container.')
    ax.set_title('Stock-weight time rises from about 109s to about 341s after Oct 23', loc='left', pad=15)
    ax.legend(loc='upper left', fontsize=8)
    ax.grid(axis='y', alpha=.18)
    fig.tight_layout()
    save(fig, 'stock-weight-history.png')

    # Long-lived tasks get a launch-time measure instead of a five-hour "slow" flag.
    live = first[first.date.eq(LATEST) & first.family.str.startswith('Live ')].copy()
    fig, axes=plt.subplots(2,1,figsize=(11,5.8),sharex=True)
    for ax,label in zip(axes,['Live stock session','Live futures session']):
        g=live[live.family.eq(label)].sort_values('start_offset_s')
        x=np.sort(np.r_[0,g.start_offset_s.to_numpy()/60])
        ax.step(x,np.arange(len(x)),where='post',color=GREEN,lw=2)
        ax.scatter(g.start_offset_s/60,np.arange(1,len(g)+1),s=14,color=GREEN)
        ax.set_ylabel('Tasks started')
        ax.set_title(f'{label}: {len(g)} starts, {clock(g.start_offset_s.min())} to {clock(g.start_offset_s.max())}',loc='left')
        ax.grid(alpha=.18)
    axes[-1].set_xlabel('Minutes after 09:30. A task start does not prove the first order or downstream service readiness.')
    axes[-1].set_xlim(0,max(live.start_offset_s)/60*1.08)
    fig.tight_layout()
    save(fig,'live-session-starts.png')

    setup.sort_values('finish_offset_s',ascending=False)[['task_id','family','started_at','ended_at','runtime_s','running_after_s','queue_seconds','source']].to_csv(ROOT/'latest-morning-tasks.csv',index=False,float_format='%.3f')
    stock_weight=latest[latest.family.eq('Stock weight')].iloc[0]
    redis=latest[latest.family.eq('Redis startup')].iloc[0]
    checks=latest[latest.family.eq('Hedge checks')]
    first_stock=stock.ended_at.min()
    last_stock=stock.ended_at.max()
    eligible=max(first_stock,checks.ended_at.max())
    summary={'date_range':[min(META['scheduled_dates']),LATEST], 'scheduled_dates':len(META['scheduled_dates']),
             'baseline_dates':len(set(available_dates)-{INCIDENT}), 'first_attempt_states':first.state.value_counts().to_dict(),
             'latest_first_attempt_states':first[first.date.eq(LATEST)].state.value_counts().to_dict(),
             'stock_weight_runtime_s':stock_weight.runtime_s,'stock_weight_finish':str(stock_weight.ended_at),
             'stock_weight_headroom_s':-stock_weight.finish_offset_s,'stock_targets':len(stock),
             'first_stock_done':str(first_stock),'last_stock_done':str(last_stock),
             'stock_target_barrier_s':(last_stock-first_stock).total_seconds(), 'redis_started':str(redis.started_at),
             'redis_runtime_s':redis.runtime_s, 'last_hedge_check_done':str(checks.ended_at.max()),
             'new_redis_eligibility_lower_bound':str(eligible), 'latest_setup_tasks':len(setup),
             'latest_late_setup_tasks':int(setup.finish_offset_s.gt(0).sum()),
             'latest_setup_queue_p50_s':setup.queue_seconds.median(), 'latest_setup_queue_p90_s':setup.queue_seconds.quantile(.9),
             'latest_setup_queue_max_s':setup.queue_seconds.max(),'latest_queue_samples':int(setup.queue_seconds.notna().sum()),
             'latest_running_session_tasks':len(live),
             'live_session_launches':{label:{'count':len(g),'first':str(g.started_at.min()),'last':str(g.started_at.max())} for label,g in live.groupby('family')},
             'latest_slowest_shared':slow_shared[['task_id','runtime_s','ended_at']].astype({'ended_at':str}).to_dict('records'),
             'missing_stock_weight_dates':sorted(set(META['scheduled_dates'])-set(available_dates)),
             'incident_morning_failures':int(morning[morning.date.eq(INCIDENT)].state.eq('failed').sum())}
    (ROOT/'summary.json').write_text(json.dumps(summary,indent=2,default=str)+'\n')
    print(json.dumps(summary,indent=2,default=str))
    print('\nFAMILY SUMMARY\n'+family_table.round(2).to_string(index=False))


if __name__=='__main__':
    assert short('zsun_pre_trade_stock_target_pos_ZX7') == 'Stock target position: ZX7'
    assert short('h17.trading.shared_Colo153') == 'Shared services: Colo153'
    assert family('h17.trading.Colo153_Broker_Account') == 'Stock algo launch'
    assert family('zfu_param_to_Colo153') == 'Host transfer'
    assert family('zfu_param_to_R7.Broker_Account') == 'Relay transfer'
    starts = pd.Series(pd.to_datetime(['2026-11-12T01:28Z', '2026-11-12T01:29Z',
                                      '2026-11-12T01:31Z', '2026-11-12T01:31Z'])).dt.tz_convert(TZ)
    ends = pd.Series(pd.to_datetime(['2026-11-12T01:29Z', '2026-11-12T01:31Z',
                                    '2026-11-12T01:33Z', None])).dt.tz_convert(TZ)
    overlap = running_seconds_after_deadline(starts, ends)
    assert overlap.iloc[:3].tolist() == [0, 60, 120]
    assert pd.isna(overlap.iloc[3]), 'An unfinished task must not become a zero-duration success'
    run()
