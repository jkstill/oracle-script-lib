
--log-switch-histogram.sql
-- histogram of redo log switch times

with lograw as (
    select (lc.first_time - lag(lc.first_time,1) over(order by thread#, sequence#)) * 86400 seconds_since_switch
    from v$log_history lc
),
histo as (
    select
        seconds_since_Switch
        -- histogram up to 10 minutes per log switch
        , width_bucket(seconds_since_switch, 1, 600, 20) LogSwitchTime
    from lograw
)
select
    min(seconds_since_Switch) min_seconds,
    max(seconds_since_Switch) max_seconds,
    count(*) LogsWitchCount
from histo
group by logswitchtime
order by LogSwitchTime
/

