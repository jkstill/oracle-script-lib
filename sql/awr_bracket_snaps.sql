
-- awr_bracket_snaps.sql

/*


bracket days for snapshot reports

This example gets the snap_id value for Friday/Monday
between about 8:30 and 23:30 for each for each of these days.

Snapshots are at 30 minute intervals at approx the top and bottom of the hour.


*/

col snaps_to_get format a25
col awr_date format a15
col weekday format a10

with awrsnaps as (
   select
      rtrim(to_char(begin_interval_time,'DAY')) weekday
      , to_date(to_char(begin_interval_time,'yyyy-mm-dd'),'yyyy-mm-dd') awr_date
      , begin_interval_time
      , snap_id
      , (extract (hour from ( begin_interval_time - trunc(begin_interval_time))) * 3600)
         + (extract (minute from ( begin_interval_time - trunc(begin_interval_time))) * 60)
         + extract (second from ( begin_interval_time - trunc(begin_interval_time))) snap_seconds
   from dba_hist_snapshot
   where instance_number = 1
) ,
data as (
select
   to_char(awr_date,'yyyy-mm-dd') awr_date
   , weekday
   , snap_id
   , round(snap_seconds,0) snap_seconds
from awrsnaps
where weekday in ('FRIDAY','MONDAY')
-- 30 minute snapshots - approx at top and bottom of hour
and (
   snap_seconds between ( 7.65 * 3600 ) and ( 8.33 * 3600)
   or
   snap_seconds between ( 23.35 * 3600 ) and ( 23.65 * 3600)
)
-- start with Friday nove 1
and begin_interval_time > to_timestamp('2013-11-01 00:00:00','yyyy-mm-dd hh24:mi:ss')
order by snap_id
)
select awr_date, weekday, listagg(snap_id,':') within group(order by awr_date,weekday) snaps_to_get
from data
group by awr_date, weekday
/
