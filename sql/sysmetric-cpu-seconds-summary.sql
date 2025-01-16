
-- sysmetric-cpu-seconds-summary.sql
-- Jared Still 2022

col snap_id format 9999999
col instance_number format 9999 head 'INST'
col begin_time format a20
col end_time format a20
col elapsed_seconds format 99999 head 'ELAPSED|SECONDS'
col cpu_seconds format 99,990.990
col sess_id_count format 999,999 head 'SESSCOUNT'
col sum_squares format 999,990.90 head 'DEVIATION|FROM MEAN'

set verify off

-- the value with the blank string is the type of report to use
-- the other MUST be '--'
def use_std='--'
def use_csv=''

set term on
set linesize 200 trimspool on
ttitle off
btitle off
clear break
set echo off pause off timing off time off

-- it is necessary to manually comment out one set of commands, dependent on report type

-- for STD
--set pagesize 100
--set feedback on

-- for CSV
set feedback off 
set pagesize 0

spool sysmetric-cpu-seconds-summary.csv
prompt snap_id,instance_number,con_id,begin_time,end_time,elapsed_seconds,cpu_seconds,sum_squares,sess_id_count

with cpu_data as (
	select
		snap_id
		, instance_number
		, con_id
		, to_char(begin_time,'yyyy-mm-dd hh24:mi:ss') begin_time
		, to_char(end_time,'yyyy-mm-dd hh24:mi:ss') end_time
		, sum_squares
		, round(( end_time - begin_time) * 86400,0) elapsed_seconds -- these are dates, not timestamps
		, maxval / 100 cpu_seconds -- recorded in centiseconds
		, metric_unit
	from DBA_HIST_SYSMETRIC_SUMMARY
	where metric_name = 'CPU Usage Per Sec'
)
select
	&use_std d.snap_id
	&use_std , d.instance_number
	&use_std , d.con_id
	&use_std , d.begin_time
	&use_std , d.end_time
	&use_std , d.elapsed_seconds
	&use_std , d.cpu_seconds
	&use_std , d.sum_squares
	&use_std , s.sess_id_count
--
	&use_csv d.snap_id
	&use_csv ||','|| d.instance_number
	&use_csv ||','|| d.con_id
	&use_csv ||','|| d.begin_time
	&use_csv ||','|| d.end_time
	&use_csv ||','|| d.elapsed_seconds
	&use_csv ||','|| d.cpu_seconds
	&use_csv ||','|| d.sum_squares
	&use_csv ||','|| s.sess_id_count
from cpu_data d
join (
	select snap_id, instance_number, count(distinct session_id) sess_id_count
	from dba_hist_active_sess_history
	group by snap_id, instance_number
) s on s.snap_id = d.snap_id and s.instance_number = d.instance_number
&use_std order by snap_id, instance_number
&use_csv order by 1
/

spool off


