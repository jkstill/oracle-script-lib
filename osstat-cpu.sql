
-- osstat-cpu.sql
-- gather OS CPU Metrics from AWR

@clear_for_spool

set term off

spool osstat-cpu-lks.csv

prompt BEGIN_TIME,END_TIME,ELAPSED_SECONDS,INSTANCE_NUMBER,BUSY_TIME,IDLE_TIME,IOWAIT_TIME,LOAD,PHYSICAL_MEMORY_BYTES,SYS_TIME,USER_TIME,VM_IN_BYTES,VM_OUT_BYTES

with data as (
	select o.snap_id
		, to_char(s.begin_interval_time,'yyyy-mm-dd hh24:mi:ss') begin_time
		, to_char(s.end_interval_time,'yyyy-mm-dd hh24:mi:ss') end_time
		, (extract( day from (s.end_interval_time - s.begin_interval_time) )*24*60*60)+
			(extract( hour from (s.end_interval_time - s.begin_interval_time) )*60*60)+
			(extract( minute from (s.end_interval_time - s.begin_interval_time) )*60)+
			(extract( second from (s.end_interval_time - s.begin_interval_time)))
		elapsed_seconds
		, o.instance_number
		, o.stat_name
		, o.value
	from dba_hist_osstat o
	join dba_hist_snapshot s on s.snap_id = o.snap_id
		and s.instance_number = o.instance_number
		and s.dbid = o.dbid
	where stat_name in ('LOAD','IDLE_TIME','BUSY_TIME','USER_TIME','SYS_TIME','IOWAIT_TIME','VM_IN_BYTES','VM_OUT_BYTES','PHYSICAL_MEMORY_BYTES')
)
select
	begin_time
	|| ',' || end_time
	|| ',' || elapsed_seconds
	|| ',' || instance_number
	|| ',' || listagg(value, ',') within group (order by stat_name)
from data
group by instance_number, begin_time, end_time, elapsed_seconds
order by begin_time, instance_number
/

spool off

set term on
@clears

