

/* wait event latency averaged over each hour

   output looks like

   BTIME               AVG_MS
   --------------- ----------
   20-JUL-11 06:00      5.854
   20-JUL-11 07:00      4.116
   20-JUL-11 08:00     21.158
   20-JUL-11 09:02      5.591
   20-JUL-11 10:00      4.116
   20-JUL-11 11:00      6.248
   20-JUL-11 12:00     23.634
   20-JUL-11 13:00     22.529
   20-JUL-11 14:00      21.62
   20-JUL-11 15:00     18.038
   20-JUL-11 16:00     23.127

*/


@@setup

define v_dbid=NULL;
select &v_dbid from dual;
col f_dbid new_value v_dbid
select &database_id f_dbid from dual;
select &v_dbid from dual;
select nvl(&v_dbid,dbid) f_dbid from v$database;
select &v_dbid from dual;


select
       btime,
       round((time_ms_end-time_ms_beg)/nullif(count_end-count_beg,0),3) avg_ms
from (
select
       to_char(s.BEGIN_INTERVAL_TIME,'&&date_format')  btime,
       total_waits count_end,
       time_waited_micro/1000 time_ms_end,
       Lag (e.time_waited_micro/1000)
              OVER( PARTITION BY e.event_name ORDER BY s.snap_id) time_ms_beg,
       Lag (e.total_waits)
              OVER( PARTITION BY e.event_name ORDER BY s.snap_id) count_beg
from
       DBA_HIST_SYSTEM_EVENT e,
       DBA_HIST_SNAPSHOT s
where
         s.snap_id=e.snap_id
   and e.event_name like '%&like_event%'
   and e.dbid=&v_dbid
   and s.dbid=&v_dbid
order by begin_interval_time
)
order by btime
/

