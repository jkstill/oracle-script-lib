
-- sysmetric-hist-matrix.sql
-- Jared Still 2023
-- crosstab of some metrics available in DBA_HIST_SYSMETRIC_HISTORY
-- see 'metric-names.sql' for all possible metric name
-- see 'metrics-available.sql' to determine just which metrics are available.


/*
                                                                                             CPU     Host
                                                                                         Seconds      CPU
          Inst   CON                                             Elapsed         CPU         Per      Per               Net Bytes      Redo Bytes      Redo Bytes  Sess ID
 Snap ID   Num    ID BEGIN_TIME          END_TIME                Seconds     Seconds   Container   Second        AAS   Per Second      Per Second         Per Txn    Count
-------- ----- ----- ------------------- ------------------- ----------- ----------- ----------- -------- ---------- ------------ --------------- --------------- --------
    5330     1     0 2023-10-23 19:16:31 2023-10-23 19:17:32       61.00        0.00        0.00     0.24       0.05          243         772,067         217,595      186
    5330     1     0 2023-10-23 19:17:32 2023-10-23 19:18:31       59.00        0.00        0.00     0.09       0.00        3,461         861,073      51,139,112      186
    5330     1     0 2023-10-23 19:18:31 2023-10-23 19:19:32       61.00        0.00        0.00     0.03       0.00        2,019               2             140      186
*/


col snap_id format 9999999 head 'Snap ID'
col begin_time format a19
col end_time format a19
col instance_number format 9999 head 'Inst|Num'
col con_id format 9999 head 'CON|ID'
col elapsed_seconds format 999,990.90 head 'Elapsed|Seconds'
col cpu_seconds format 999,990.90 head 'CPU|Seconds'
col cpu_seconds_ct format 999,990.90 head 'CPU|Seconds|Per|Container'
col aas format 99,990.90 head 'AAS'
col sess_id_count format 999,999 head 'Sess ID|Count'
col host_cpu_usage_per_second format 9990.09 head 'Host|CPU|Per|Second'
col host_cpu_utilization_pct format 9990.09 head 'Host|CPU|Util|Pct'
col db_cpu_time_ratio format 990.09 head 'DB CPU|Time|Ratio'
col db_time_per_second format 990.09 head 'DB Time|Per|Second'
col net_bytes_per_second format 999,999,990 head 'Net Bytes|Per Second'
col redo_bytes_per_second format 99,999,999,990 head 'Redo Bytes|Per Second'
col redo_bytes_per_txn format 99,999,999,990 head 'Redo Bytes|Per Txn'


-- the empty string chooses output
def use_std=''
def use_csv='--'

set term on
set linesize 250 trimspool on
set feedback on
set pagesize 100
ttitle off
btitle off
clear break
set echo off pause off timing off time off verify off

-- for STD
spool sysmetric-hist-matrix.log

-- for CSV
--set feedback off
--set pagesize 0

--spool sysmetric-hist-matrix.csv
--prompt snap_id,instance_number,con_id,begin_time,end_time,elapsed_seconds,cpu_seconds,cpu_seconds_ct,host_cpu_usage_per_second,aas,net_bytes_per_second,redo_bytes_per_second,redo_bytes_per_txn,sess_id_count

with metric_data as (
	select
		h.snap_id snap_id
		, h.instance_number
		, h.con_id
		, to_char(h.begin_time,'yyyy-mm-dd hh24:mi:ss') begin_time
		, to_char(h.end_time,'yyyy-mm-dd hh24:mi:ss') end_time
		, round(( h.end_time - h.begin_time) * 86400,0) elapsed_seconds -- these are dates, not timestamps
		, case
			when h.metric_name = 'CPU Usage Per Sec' and g.name = 'System Metrics Long Duration' then
				 round(value / 100,2)
			else null
		end cpu_seconds
		-- container total
		, case
			when h.metric_name = 'CPU Usage Per Sec' and g.name = 'PDB System Metrics Long Duration' then
				sum(h.value / 100) over (partition by h.instance_number,to_char(h.begin_time,'yyyy-mm-dd hh24:mi:ss') order by h.con_id)
			else null
		end cpu_seconds_ct
		, case 
			when h.metric_name = 'Host CPU Usage Per Sec' and g.name = 'System Metrics Long Duration' then
				h.value / 100 
			else null
		end  host_cpu_usage_per_second
		, case 
			when h.metric_name = 'Host CPU Utilization (%)' and g.name = 'System Metrics Long Duration' then
				h.value 
			else null
		end host_cpu_utilization_pct
		, case
			when h.metric_name = 'Average Active Sessions' and g.name = 'System Metrics Long Duration' then
				round(h.value,2)
			else null
		end aas
		, case
			when h.metric_name = 'Database CPU Time Ratio' and g.name = 'System Metrics Long Duration' then
				h.value 
			else null
		end db_cpu_time_ratio
		, case
			when h.metric_name = 'DB Time Per Second' and g.name = 'Service Metrics' then
				h.value 
			else null
		end db_time_per_second
		, case
			when h.metric_name = 'Network Traffic Volume Per Sec' and g.name = 'System Metrics Long Duration' then
				h.value 
			else null
		end net_bytes_per_second
		, case
			when h.metric_name = 'Redo Generated Per Sec' and g.name = 'System Metrics Long Duration' then
				h.value 
			else null
		end redo_bytes_per_second
		, case
			when h.metric_name = 'Redo Generated Per Txn' and g.name = 'System Metrics Long Duration' then
				h.value 
			else null
		end redo_bytes_per_txn
		--, metric_unit
	from DBA_HIST_SYSMETRIC_HISTORY h
	-- many changes required to use the  gv$sysmetric_history view
	-- probably best as a different script
	--from gv$sysmetric_history h
	join v$metricgroup g on g.group_id = h.group_id
	where metric_name in(
		'CPU Usage Per Sec'
		,'Average Active Sessions'
		, 'Host CPU Utilization (%)'
		, 'Database CPU Time Ratio'
		, 'DB Time Per Second'
		, 'Host CPU Usage Per Sec'
		, 'Network Traffic Volume Per Sec'
		, 'Redo Generated Per Sec'
		, 'Redo Generated Per Txn'
	)
),
data as (
	select
		snap_id
		, instance_number
		, con_id
		, begin_time
		, end_time
		, elapsed_seconds
		, min(cpu_seconds) cpu_seconds
		, min(cpu_seconds) cpu_seconds_ct
		, min(host_cpu_usage_per_second) host_cpu_usage_per_second
		, min(host_cpu_utilization_pct) host_cpu_utilization_pct
		, min(db_cpu_time_ratio) db_cpu_time_ratio
		, min(db_time_per_second) db_time_per_second
		, min(aas) aas
		, min(net_bytes_per_second) net_bytes_per_second
		, min(redo_bytes_per_second) redo_bytes_per_second
		, min(redo_bytes_per_txn) redo_bytes_per_txn
	from metric_data
	group by snap_id, instance_number, con_id, begin_time, end_time, elapsed_seconds
)
select
	&&use_std d.snap_id
	&&use_std , d.instance_number
	&&use_std , d.con_id
	&&use_std , d.begin_time
	&&use_std , d.end_time
	&&use_std , d.elapsed_seconds
	&&use_std , d.cpu_seconds
	&&use_std , d.cpu_seconds_ct
	&&use_std , d.host_cpu_usage_per_second
	-- some host CPU stats are not being recorded in AWR
	--&&use_std , d.host_cpu_utilization_pct
	--  'Database CPU Time Ratio' also not being recorded
	--&&use_std , d.db_cpu_time_ratio
	--&&use_std , d.db_time_per_second
	&&use_std , d.aas
	&&use_std , d.net_bytes_per_second
	&&use_std , d.redo_bytes_per_second
	&&use_std , d.redo_bytes_per_txn
	&&use_std , s.sess_id_count
	--
	&&use_csv d.snap_id
	&&use_csv ||','|| d.instance_number
	&&use_csv ||','|| d.con_id
	&&use_csv ||','|| d.begin_time
	&&use_csv ||','|| d.end_time
	&&use_csv ||','|| d.elapsed_seconds
	&&use_csv ||','|| d.cpu_seconds
	&&use_csv ||','|| d.cpu_seconds_ct
	&&use_csv ||','|| d.host_cpu_usage_per_second
	-- some host CPU stats are not being recorded in AWR
	--&&use_csv ||','|| d.host_cpu_utilization_pct
	--  'Database CPU Time Ratio' also not being recorded
	--&&use_csv ||','|| d.db_cpu_time_ratio
	--&&use_csv ||','|| d.db_time_per_second
	&&use_csv ||','|| d.aas
	&&use_csv ||','|| d.net_bytes_per_second
	&&use_csv ||','|| d.redo_bytes_per_second
	&&use_csv ||','|| d.redo_bytes_per_txn
	&&use_csv ||','|| s.sess_id_count
from data d
join (
	select snap_id, instance_number, count(distinct session_id) sess_id_count
	from dba_hist_active_sess_history
	group by snap_id, instance_number
) s on s.snap_id = d.snap_id and s.instance_number = d.instance_number
&use_std order by snap_id, instance_number, con_id, begin_time
&use_csv order by 1
/

spool off


--ed sysmetric-hist-matrix.csv
ed sysmetric-hist-matrix.log


