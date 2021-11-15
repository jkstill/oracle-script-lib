
-- aas_hist_metrics.sql
-- jared still - 2015-07-16
-- 
-- jkstill@gmail.com

set pause off
set echo off
set timing off
set trimspool on
set feed off term off echo off verify off

clear col
clear break
clear computes

btitle ''
ttitle ''

btitle off
ttitle off

set newpage 1
set pages 0 lines 200 


col value format 999999
col instance_number head INST# format 99999

spool aas_hist_metrics.csv

prompt END_TIME,INST#,CORES,WALL_TIME,AAS,HOST_CPU_SEC,DB_CPU_SEC,BG_DB_CPU_SEC,DB_TIME,SYS_TIME

with data as (
	select 
		to_char(h.end_time,'yyyy-mm-dd hh24:mi:ss') end_time
		, h.instance_number
		, h.intsize
		, h.metric_name
		, h.value
		, os.cpu_count_current cores
	from dba_hist_sysmetric_history h
	--join gv$license os on os.inst_id = h.instance_number
	--/*	
	-- this is what I would like to use for cores, but for some
	-- reason the view does not have recent data in
	-- could just be a problem with my test db
	join (
		select snap_id, value cpu_count_current
		from 
		dba_hist_osstat
		where stat_name = 'NUM_CPU_CORES'
	) os on os.snap_id = h.snap_id
	--*/
	where h.metric_name in (
		'Average Active Sessions'
		, 'Host CPU Usage Per Sec'
		, 'CPU Usage Per Sec'
		, 'Background CPU Usage Per Sec'
	)
)
select 
	/*
	end_time
	, instance_number
	, cores
	, cores * intsize wall_time
	, aas
	, host_cpu_sec
	, db_cpu_sec
	, bg_db_cpu_sec
	, db_cpu_sec + bg_db_cpu_sec db_time
	, host_cpu_sec + db_cpu_sec + bg_db_cpu_sec  sys_time
	*/
	end_time
	|| ',' || instance_number
	|| ',' || cores
	|| ',' || cores * intsize
	|| ',' || aas
	|| ',' || host_cpu_sec
	|| ',' || db_cpu_sec
	|| ',' || bg_db_cpu_sec
	|| ',' || (db_cpu_sec + bg_db_cpu_sec)
	|| ',' || (host_cpu_sec + db_cpu_sec + bg_db_cpu_sec)
from (
	select end_time
		, metric_name
		, intsize / 100 intsize
		, cores
		, instance_number
		, value
	from data
)
pivot (
	sum (value) 
	for metric_name in (
		'Average Active Sessions' as aas
		, 'Host CPU Usage Per Sec' as host_cpu_sec
		, 'CPU Usage Per Sec' as db_cpu_sec
		, 'Background CPU Usage Per Sec' bg_db_cpu_sec
	)
)
--order by 1,2
order by 1 
/


spool off


set feed on term on 
set pagesize 60



