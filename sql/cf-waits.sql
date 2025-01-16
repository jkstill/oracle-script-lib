
-- cf-waits.sql - Control File Waits

set linesize 200 trimspool on
set pagesize 100

col total_waits_fg head 'TOTAL|FG WAITS' format 999,999,999,999
col average_wait_fg ON FORMAT   999,990.0999
col average_wait ON HEADING  'AVG|WAIT' headsep '|' FORMAT   9999999.099999
col time_waited_fg_seconds ON HEADING  'TIME|WAITED|FG SECONDS' headsep '|' FORMAT   999,990.099999
col avg_time_waited_micro_fg ON HEADING  'AV|TIME|WAITED|SECONDS' headsep '|' FORMAT   99,999,990.099999
col total_waits ON HEADING  'TOTAL|WAITS' headsep '|' FORMAT   999,999,999
col event ON HEADING  'EVENT NAME' FORMAT   a50

select
        event
        , total_waits_fg
        , time_waited_micro_fg/1000000 time_waited_fg_seconds
        , time_waited_micro_fg / total_waits_fg / 1000000 avg_time_waited_micro_fg
from v$system_event
where event like '%control%'
and total_waits_fg > 0
/

