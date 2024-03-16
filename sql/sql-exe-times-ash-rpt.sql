
-- sql-exe-times-ash-rpt.sql
-- 2023 Jared Still
--
-- report on the execution times of a SQL statement from ASH

@clears

set linesize 300 trimspool on
set pagesize 100

col v_sql_id new_value v_sql_id noprint

prompt SQL_ID: 

set feed off term off head off
select '&1' v_sql_id from dual;
set feed on term on  head on

col sql_id format a13
col start_time format a22
col sample_time format a22
col end_time format a22

spool sql-exe-times-ash-rpt-&v_sql_id..txt

with data as (
	select sql_id, sql_exec_id, sql_exec_start, 
		min(sql_exec_start) start_time, 
		max(sql_exec_start + (sample_time - sql_exec_start)) end_time,
		max(sample_time - sql_exec_start) duration
	from v$active_session_history
	where sql_id = '&v_sql_id'
		and sql_exec_id is not null
	group by sql_id, sql_exec_id, sql_exec_start
	order by sql_exec_start, sql_id, sql_exec_id
)
select sql_id
	, to_char(sql_exec_start,'yyyy-mm-dd hh24:mi:ss') sql_exec_start
	, sql_exec_id
	, to_char(start_time,'yyyy-mm-dd hh24:mi:ss') start_time
	, to_char(end_time,'yyyy-mm-dd hh24:mi:ss') end_time
	, duration
from data
/

spool off

ed sql-exe-times-ash-rpt-&v_sql_id..txt

