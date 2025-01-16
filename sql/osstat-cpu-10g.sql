
-- osstat-cpu-10g.sql
-- gather OS CPU Metrics from AWR
-- this will not work properly on 11g+ due to different metric names
-- it may be necessary to adjust the stat_name's that are retrieved
-- as they may be different between 10g versions

@clear_for_spool

set term off

set linesize 400 trimspool on

spool osstat-cpu-10g.csv

--prompt BEGIN_TIME,END_TIME,ELAPSED_SECONDS,INSTANCE_NUMBER,AVG_BUSY_TIME,AVG_IDLE_TIME,AVG_SYS_TIME,AVG_USER_TIME,BUSY_TIME,IDLE_TIME,NUM_CPUS,NUM_CPU_CORES,PHYSICAL_MEMORY_BYTES,RSRC_MGR_CPU_WAIT_TIME,SYS_TIME,USER_TIME,VM_IN_BYTES,VM_OUT_BYTES

prompt BEGIN_TIME,END_TIME,ELAPSED_SECONDS,CPU_SECONDS,INSTANCE_NUMBER,BUSY_TIME,IDLE_TIME,IOWAIT_TIME,LOAD,NICE_TIME,NUM_CPUS,PHYSICAL_MEMORY_BYTES,RSRC_MGR_CPU_WAIT_TIME,SYS_TIME,USER_TIME


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
		, case when lag(o.value,1) over (partition by o.instance_number, stat_name order by s.snap_id) is null
			then 'SKIP'
		else 'OK'
		end lag_control
		, case when stat_name like '%TIME'  
				then (o.value - lag(o.value,1) over (partition by o.instance_number, stat_name order by s.snap_id) ) / 100
				else o.value
		end value
	from dba_hist_osstat o
	join dba_hist_snapshot s on s.snap_id = o.snap_id
		and s.instance_number = o.instance_number
		and s.dbid = o.dbid
	and o.stat_name in (
		-- choose the columns you need - 10.2.0.4 and 10.2.0.5 are different
		-- select distinct stat_name from dba_hist_osstat order by 1
		--'AVG_BUSY_TIME'
		--,'AVG_IDLE_TIME'
		--,'AVG_SYS_TIME'
		--,'AVG_USER_TIME'
		'BUSY_TIME'
		,'IDLE_TIME'
		,'IOWAIT_TIME'
		,'LOAD'
		,'NICE_TIME'
		,'NUM_CPUS'
		--,'NUM_CPU_CORES'
		,'PHYSICAL_MEMORY_BYTES'
		,'RSRC_MGR_CPU_WAIT_TIME'
		,'SYS_TIME'
		,'USER_TIME'
		--,'VM_IN_BYTES'
		--,'VM_OUT_BYTES'
	)
)
select
	begin_time
	|| ',' || max(end_time)
	|| ',' || max(elapsed_seconds)
	-- this is CPU_SECONDS - not perfect (no max(elapsed_seconds)) , but close enough
	|| ',' || max(decode (stat_name,'NUM_CPUS',value * elapsed_seconds,null) )
	|| ',' || instance_number
	--|| ',' || max(decode (stat_name,'AVG_BUSY_TIME',value,null) )
	--|| ',' || max(decode (stat_name,'AVG_IDLE_TIME',value,null) )
	--|| ',' || max(decode (stat_name,'AVG_SYS_TIME',value,null) )
	--|| ',' || max(decode (stat_name,'AVG_USER_TIME',value,null) )
	|| ',' || max(decode (stat_name,'BUSY_TIME',value,null) )
	|| ',' || max(decode (stat_name,'IDLE_TIME',value,null) )
	|| ',' || max(decode (stat_name,'IOWAIT_TIME',value,null) )
	|| ',' || max(decode (stat_name,'LOAD',value,null) )
	|| ',' || max(decode (stat_name,'NICE_TIME',value,null) )
	|| ',' || max(decode (stat_name,'NUM_CPUS',value,null) )
	--|| ',' || max(decode (stat_name,'NUM_CPU_CORES',value,null) )
	|| ',' || max(decode (stat_name,'PHYSICAL_MEMORY_BYTES',value,null) )
	|| ',' || max(decode (stat_name,'RSRC_MGR_CPU_WAIT_TIME',value,null) )
	|| ',' || max(decode (stat_name,'SYS_TIME',value,null) )
	|| ',' || max(decode (stat_name,'USER_TIME',value,null) )
	--|| ',' || max(decode (stat_name,'VM_IN_BYTES',value,null) )
	--|| ',' || max(decode (stat_name,'VM_OUT_BYTES',value,null) )
from data
where lag_control = 'OK'
group by instance_number, begin_time, end_time, elapsed_seconds
order by begin_time, instance_number
/

spool off

set term on
@clears
set linesize 200 trimspool on


