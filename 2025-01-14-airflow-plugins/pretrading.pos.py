from wepy.utils.init import (
    datetime, timedelta, re,
    cal, log, wx_test, robot_secops,
)
from wepy.utils.airflow_util import (
    DAG, AirflowUtil,
    # BashOperator,
)
RSYNCX = 'rsync --timeout=30 -Parzvlt'

# Define multiple cron schedules
from mycron import MultiCronTimetable
multi_cron = MultiCronTimetable(
    cron_defs = [
        "50,59 08 * * 1-5",  # Original schedule
        "01,05 09 * * 1-5",        # Additional schedule 1: 7:30 AM Mon-Fri
    ],
    timezone = "Asia/Shanghai"
)

@cal.check_today_trading
def dag_failure_alert(context):
    log.err(context)
    AirflowUtil.dag_failure_alert(context, ['wx_test', 'robot_secops'])

@cal.check_today_trading
def task_failure_alert(context):
    log.err(context)
    AirflowUtil.task_failure_alert(context, ['wx_test', 'robot_secops'])

@cal.check_today_trading
def dag_success_alert(context):
    msg = f"""
        succ to run dag::pre/post-trading.pos
        @{datetime.now()}
    """
    log.inf(msg)
    log.inf(context)
    for w in [wx_test]:
        w.send(msg)

def check_cmd(colo, cmd=''):
    msg = f"--------[ERR][{colo}]_failed_to_run_{cmd}"
    return f""" ssh ops.r7 bash /home/ops/git/jobs/ops/mon/wechat_cli.sh futops "{msg}" """

with DAG(
    dag_id         = "pretrading.pos",
    default_args   = AirflowUtil.default_args(retry=0),
    # schedule       = "01,05 09,15 * * 1-5",
    schedule       = multi_cron,
    start_date     = datetime(2023, 1, 1, tzinfo=AirflowUtil.local_tz()),
    catchup        = False,
    dagrun_timeout = timedelta(seconds=60*30),
    tags           = ['pretrading', 'pos', 'gui', 'stk', 'cv'],
    on_failure_callback = dag_failure_alert,
    on_success_callback = dag_success_alert,
) as dag:
# def create_pretrading_tasks(dag):
    def handle_pos(colo, src, exch, acct, posfile):
        num = re.sub("[A-z]", "", colo)
        id  = f"Colo{num}"
        dst = f"/fs/public/ops/pos/{id}"
        exch = exch.upper()
        if exch in ['SH', 'SSE', 'SHSE']:
            exch = 'SHSE'
        elif exch in ['SZ', 'SZSE']:
            exch = 'SZSE'
        pos_acct = acct.split('_')[-1].lower()
        acct_cv = f"{acct}_CV"
        acct_stk = f"{acct}_STK"
        ## ----------------------------------------------------------
        gw_api = 'tora' if id in ['Colo202', 'Colo205'] else 'xeleq3'

        return AirflowUtil.create_docker(
            task_id = f'handle_pos_{id}_{acct}',
            image   = '192.168.1.162:5000/r7:v1.0',
            mounts  = {'/fs': '/fs'},
            command = f"""
                ssh {id} "bash ~/git/infra/output/{id}/run.qry.{gw_api}.{acct}.save.sh" || echo "failed to save qry"

                mkdir -p {dst}
                cd {dst}
                ##NOTE: 只同步本账户的信息，避免其他账户的影响
                {RSYNCX} {id}:{src}/$(echo {posfile} |sed "s/.csv//g")* ./
                sleep 1

                yday=$(date -d "-1 days" +'%Y-%m-%d')
                today=$(date +'%Y-%m-%d')
                today_slim=$(date +'%Y%m%d')
                now=$(date +'%H:%M:%S')
                TRADING_START_TIME="09:29:00"
                echo "docker now:${{now}}"

                init_posfile=init.pos.{acct}.{exch}.${{today}}.csv
                init_posfile_cv=init.pos.{acct_cv}.{exch}.${{today}}.csv
                init_posfile_stk=init.pos.{acct_stk}.{exch}.${{today}}.csv
                post_posfile=post.pos.{acct}.{exch}.${{today}}.csv
                post_posfile_cv=post.pos.{acct_cv}.{exch}.${{today}}.csv
                post_posfile_stk=post.pos.{acct_stk}.{exch}.${{today}}.csv
                qry_posfile=qry.pos.{acct}.{exch}.${{today}}.csv

                ## unlink first to avoid error file
                if [[ "${{now}}" < "${{TRADING_START_TIME}}" ]]; then
                    echo "...........init_posfile: ${{init_posfile}}"
                    unlink init.pos.{acct}.{exch}.csv
                    unlink /fs/public/ops/pos/init.pos/init.pos.{acct}.{exch}.csv
                fi

                latest=$(ls -alhtr ./ |egrep pos |egrep "${{today}}|${{today_slim}}" |grep {pos_acct} |grep -v orig |grep -v bk |egrep -v ^l |rev |cut -d" " -f1|rev |tail -1)
                echo "\nlatest:{dst}/${{latest}}:\n$(cat ${{latest}})"
                sleep 1

                modified=$(stat ${{latest}} |grep -i Modify|cut -d" " -f2)
                if [[ "${{modified}}" < "${{today}}" ]];
                then
                    echo "❌❌❌❌❌❌ modified:${{modified}} not latest:(${{today}}) pos found" && {check_cmd(colo, posfile + "is_not_latest")}
                    exit -1
                fi

                if [[ "${{now}}" < "${{TRADING_START_TIME}}" ]]; then
                    if [[ $(cat ${{latest}} |wc -l) -ge 2 ]] && ! egrep -q "${{today}}" ${{latest}};
                    then
                        echo "❌❌❌❌❌❌ data not latest:(${{today}}) pos found"
                        exit -1
                    fi
                fi

                if [[ "${{now}}" < "${{TRADING_START_TIME}}" ]]; then
                    if [[ ! -f ${{init_posfile}} ]]; then
                        echo "InstrumentID,Symbol,TradingDay,HistoryLong,HistoryShort,ExchangeName,ExchangeID"                      > /tmp/${{init_posfile}}
                        awk -F, "NR>1 {{print \$1\",\"\$1\",\"\$2\",\"\$3+\$5\",\"\$4+\$6\",\"\$7\",\"\$8}}" {posfile} |tr " " "," >> /tmp/${{init_posfile}}
                        cp /tmp/${{init_posfile}} ${{init_posfile}}
                        ln -sfn ${{init_posfile}} init.pos.{acct}.{exch}.csv
                    elif egrep -q "TodayLong" ${{init_posfile}}; then
                        cp ${{init_posfile}} /tmp/${{init_posfile}}
                        echo "InstrumentID,Symbol,TradingDay,HistoryLong,HistoryShort,ExchangeName,ExchangeID"                                   > ${{init_posfile}}
                        awk -F, "NR>1 {{print \$1\",\"\$1\",\"\$2\",\"\$3+\$5\",\"\$4+\$6\",\"\$7\",\"\$8}}" /tmp/${{init_posfile}} |tr " " "," >> ${{init_posfile}}
                        ln -sfn ${{init_posfile}} init.pos.{acct}.{exch}.csv
                    fi

                    # echo "InstrumentID,Symbol,TradingDay,HistoryLong,HistoryShort,ExchangeName,ExchangeID"                      > /tmp/${{init_posfile}}
                    # awk -F, "NR>1 {{print \$1\",\"\$1\",\"\$2\",\"\$3+\$5\",\"\$4+\$6\",\"\$7\",\"\$8}}" {posfile} |tr " " "," >> /tmp/${{init_posfile}}
                    # cp /tmp/${{init_posfile}} ${{init_posfile}}
                    # ln -sfn ${{init_posfile}} init.pos.{acct}.{exch}.csv
                    echo "#init.pos---------------------------"
                    ls -alh init.pos.{acct}.{exch}.csv
                    echo "#-----------------------------------"

                    ## all
                    ln -sfn init.pos.{acct}.{exch}.${{today}}.csv init.pos.{acct}.{exch}.csv

                    ## cv
                    egrep "^InstrumentID|^1" ${{init_posfile}} > /tmp/${{init_posfile_cv}}
                    cp /tmp/${{init_posfile_cv}} ${{init_posfile_cv}}
                    ln -sfn ${{init_posfile_cv}} init.pos.{acct_cv}.{exch}.csv

                    ## stk
                    egrep -v "^1" ${{init_posfile}} > /tmp/${{init_posfile_stk}}
                    cp /tmp/${{init_posfile_stk}} ${{init_posfile_stk}}
                    ln -sfn ${{init_posfile_stk}} init.pos.{acct_stk}.{exch}.csv

                elif [[ "${{now}}" > "15:00:00" ]]; then
                        echo "InstrumentID,Symbol,TradingDay,HistoryLong,HistoryShort,ExchangeName,ExchangeID"                      > /tmp/${{post_posfile}}
                        awk -F, "NR>1 {{print \$1\",\"\$1\",\"\$2\",\"\$3+\$5\",\"\$4+\$6\",\"\$7\",\"\$8}}" {posfile} |tr " " "," >> /tmp/${{post_posfile}}
                        cp /tmp/${{post_posfile}} ${{post_posfile}}
                        ln -sfn ${{post_posfile}} post.pos.{acct}.{exch}.csv

                        ## cv
                        egrep "^InstrumentID|^1" ${{post_posfile}} > /tmp/${{post_posfile_cv}}
                        cp /tmp/${{post_posfile_cv}} ${{post_posfile_cv}}
                        ln -sfn ${{post_posfile_cv}} post.pos.{acct_cv}.{exch}.csv

                        ## stk
                        egrep -v "^1" ${{post_posfile}} > /tmp/${{post_posfile_stk}}
                        cp /tmp/${{post_posfile_stk}} ${{post_posfile_stk}}
                        ln -sfn ${{post_posfile_stk}} post.pos.{acct_stk}.{exch}.csv

                        sleep 1
                        cp {posfile} ${{qry_posfile}}
                        ln -sfn ${{qry_posfile}} qry.pos.{acct}.{exch}.csv

                    echo "#post.pos---------------------------"
                    ls -alh post.pos.{acct}.{exch}.csv
                    echo "#-----------------------------------"
                else
                    echo "nan"
                fi

                if ls -alh |egrep -q init; then
                    mkdir -p /fs/public/ops/pos/init.pos/
                    {RSYNCX} ./init.pos*{acct}* /fs/public/ops/pos/init.pos/
                    sleep 1
                    {RSYNCX} ./init.pos*{acct}* {id}:{src}/
                    echo "init.pos updated"
                fi
                if ls -alh |egrep -q post; then
                    mkdir -p /fs/public/ops/pos/post.pos/
                    {RSYNCX} ./post.pos*{acct}* /fs/public/ops/pos/post.pos/
                    sleep 1
                    {RSYNCX} ./post.pos*{acct}* {id}:{src}/
                    echo "post.pos updated"
                fi
                if ls -alh |egrep -q qry; then
                    mkdir -p /fs/public/ops/pos/qry.pos/
                    sleep 1
                    {RSYNCX} ./qry*{acct}* /fs/public/ops/pos/qry.pos/
                    echo "qry.pos updated"
                fi
            """,
            on_failure_callback = task_failure_alert
        )

    pos_121 = handle_pos(colo='121', src="~/xeleq.qry/data", exch='sh', acct='GTJA_DT1', posfile='pos.dt1.csv')
    pos_106 = handle_pos(colo='106', src="~/xeleq.qry/data", exch='sz', acct='GTJA_DT1', posfile='pos.dt1.csv')

    pos_107_zx1 = handle_pos(colo='107', src="~/xeleq.qry/data", exch='sh', acct='GTJA_ZX1', posfile='pos.zx1.csv')
    pos_118_zx1 = handle_pos(colo='118', src="~/xeleq.qry/data", exch='sz', acct='GTJA_ZX1', posfile='pos.zx1.csv')

    pos_107_zz1 = handle_pos(colo='107', src="~/xeleq.qry/data", exch='sh', acct='GTJA_ZZ1', posfile='pos.zz1.csv')
    pos_118_zz1 = handle_pos(colo='118', src="~/xeleq.qry/data", exch='sz', acct='GTJA_ZZ1', posfile='pos.zz1.csv')

    pos_109 = handle_pos(colo='109', src="~/xeleq.qry/data", exch='sh', acct='GTJA_MCC', posfile='pos.mcc.csv')
    pos_110 = handle_pos(colo='110', src="~/xeleq.qry/data", exch='sz', acct='GTJA_MCC', posfile='pos.mcc.csv')

    pos_113 = handle_pos(colo='113', src="~/xeleq.qry/data", exch='sh', acct='GTJA_VKY', posfile='pos.vky.csv')
    pos_116 = handle_pos(colo='116', src="~/xeleq.qry/data", exch='sz', acct='GTJA_VKY', posfile='pos.vky.csv')

    pos_115 = handle_pos(colo='115', src="~/xeleq.qry/data", exch='sh', acct='GTJA_RMB', posfile='pos.rmb.csv')
    pos_120 = handle_pos(colo='120', src="~/xeleq.qry/data", exch='sz', acct='GTJA_RMB', posfile='pos.rmb.csv')

    pos_105 = handle_pos(colo='105', src="~/xeleq.qry/data", exch='sh', acct='GTJA_SXU', posfile='pos.sxu.csv')
    pos_108 = handle_pos(colo='108', src="~/xeleq.qry/data", exch='sz', acct='GTJA_SXU', posfile='pos.sxu.csv')

    pos_202 = handle_pos(colo='202', src="~/tora.qry/data", exch='sz', acct='HuaXin_YQ1', posfile='pos.yq1.csv')
    pos_205 = handle_pos(colo='205', src="~/tora.qry/data", exch='sh', acct='HuaXin_YQ1', posfile='pos.yq1.csv')

    cmd = """
        for m in Colo1{03..30} Colo202 Colo205
        do
        {
            echo "rsync_init_pos_to_colo: [${m}] -------------------------------"
            rsync --timeout=30 -Przvlt /fs/public/ops/pos/init.pos ${m}:~/ || echo "--------------[❌❌❌❌❌❌ ]${m} rsync failed: $?"
            rsync --timeout=30 -Przvlt /fs/public/ops/pos/post.pos ${m}:~/ || echo "--------------[❌❌❌❌❌❌ ]${m} rsync failed: $?"
        } &
        done

        sleep 10 && wait
        echo "all rsync to machine done! @$(date +'%Y-%m-%dT%H:%M:%S.%6N')"
        """
    rsync_init_pos_to_colo =  AirflowUtil.create_docker(
            task_id = 'rsync_init_pos_to_colo',
            image   = '192.168.1.162:5000/r7:v1.0',
            mounts  = {'/fs': '/fs'},
            command = cmd,
            on_failure_callback = task_failure_alert
        )

    ## ========================================================================
    [
        pos_121, pos_106,

        pos_107_zx1, pos_118_zx1,
        pos_107_zz1, pos_118_zz1,

        pos_109, pos_110,
        pos_113, pos_115,
        pos_116, pos_120,
        pos_105, pos_108,

        pos_202, pos_205,
    ] >> rsync_init_pos_to_colo
    ## ========================================================================

# with DAG(
#     dag_id         = "pretrading.pos",
#     default_args   = AirflowUtil.default_args(retry=0),
#     schedule       = "45,55 08 * * 1-5",
#     start_date     = datetime(2023, 1, 1, tzinfo=AirflowUtil.local_tz()),
#     catchup        = False,
#     dagrun_timeout = timedelta(seconds=60*30),
#     tags           = ['pretrading', 'pos', 'gui', 'stk', 'cv'],
#     on_failure_callback = dag_failure_alert,
#     on_success_callback = dag_success_alert,
# ) as dag_morning:
#     create_pretrading_tasks(dag_success_alert)
#
# with DAG(
#     dag_id         = "pretrading.pos.extra",
#     default_args   = AirflowUtil.default_args(retry=0),
#     schedule       = "01,05 09,15 * * 1-5",
#     start_date     = datetime(2023, 1, 1, tzinfo=AirflowUtil.local_tz()),
#     catchup        = False,
#     dagrun_timeout = timedelta(seconds=60*30),
#     tags           = ['pretrading', 'pos', 'gui', 'stk', 'cv'],
#     on_failure_callback = dag_failure_alert,
#     on_success_callback = dag_success_alert,
# ) as dag_morning:
#     create_pretrading_tasks(dag_success_alert)
