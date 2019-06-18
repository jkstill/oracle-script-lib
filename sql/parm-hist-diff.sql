
SET PAUSE OFF
SET PAGESIZE 100
SET LINESIZE 200

col snap_id format 99999999
col snap_time FORMAT A30
col parameter_name FORMAT A40
col prev_value FORMAT A20
col value FORMAT A20


spool parmdiff.txt

with data as (
   select /*+ no_merge materialize */
      p.snap_id
      , to_char(s.begin_interval_time,'yyyy-mm-dd hh24:mi:ss') snap_time
      , p.instance_number inst_id
      , p.parameter_name
      , p.value
   from dba_hist_parameter p
   join dba_hist_snapshot s
      on s.snap_id = p.snap_id
      and s.snap_id = p.snap_id
      and s.instance_number = p.instance_number
      --and s.con_dbid = p.con_dbid
      and s.con_id = p.con_id
      --and s.begin_interval_time > systimestamp - numtodsinterval( 1 ,'day')
),
diffs as (
   select distinct
      --d.snap_id
      d.snap_time
      , d.inst_id
      , d.parameter_name
      , d.value
      , lag(d.value,1) over ( partition by d.snap_id, d.inst_id, d.parameter_name order by snap_id) prev_value
   from data d
)
select f.*
from diffs f
where  f.value != f.prev_value
order by snap_time
/

spool off

