
@nls_time_format

set linesize 200 trimspool on
set pagesize 60


col begin_interval_time format a30
col value format 999,999,999,999,999

break on begin_interval_time

select sh.begin_interval_time, ss.instance_number, ss.stat_name, ss.value
from dba_hist_sysstat ss
join dba_hist_snapshot sh on sh.snap_id = ss.snap_id
   and sh.dbid = ss.dbid
   and sh.instance_number = ss.instance_number
   and ss.stat_name like '%flash%'
   and sh.begin_interval_time >= systimestamp - interval '4' hour
order by ss.snap_id, ss.stat_name
/           
