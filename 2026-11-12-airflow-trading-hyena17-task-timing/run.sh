#!/usr/bin/env bash
set +x
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
python_bin="${PYTHON:-python3}"
if [[ $# -gt 1 || ( $# -eq 1 && "$1" != --refresh ) ]]; then
    echo 'Usage: ./run.sh [--refresh]' >&2
    exit 2
fi
if [[ "${1:-}" == --refresh ]]; then
    ssh_user="${AIRFLOW_SSH_USER:-infra}"
    ssh_host="${AIRFLOW_SSH_HOST:-infra.t1}"
    snapshot_file="$(mktemp)"
    trap 'rm -f -- "$snapshot_file"' EXIT
    ssh_command=(ssh -o ConnectTimeout=15)
    if [[ -n "${AIRFLOW_SSH_PASSWORD:-}" ]]; then
        command -v sshpass >/dev/null || { echo 'Password authentication needs sshpass.' >&2; exit 1; }
        ssh_command=(sshpass -e ssh -o ConnectTimeout=15 -o NumberOfPasswordPrompts=1)
    else
        ssh_command+=(-o BatchMode=yes)
    fi
    SSHPASS="${AIRFLOW_SSH_PASSWORD:-}" "${ssh_command[@]}" "$ssh_user@$ssh_host" \
        'docker exec -i airflow /usr/local/python3/bin/python3 -' \
        < export_airflow.py > "$snapshot_file"
    unset AIRFLOW_SSH_PASSWORD
    "$python_bin" export_airflow.py --write-snapshot "$snapshot_file"
fi
"$python_bin" analyze.py
