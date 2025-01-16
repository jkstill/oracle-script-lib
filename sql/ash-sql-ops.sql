
-- ash-sql-ops.sql
-- Jared Still 2023
-- jkstill@gmail.com

set line 250 trimspool on
set pagesize 50

@@legacy-exclude

col sample_time format a25
col sql_exec_start format a25
col sql_id format a13
col inst_id format 9999 head 'INST|ID'
col con_id format 999 head 'CON|ID'

alter session set nls_timestamp_format = 'yyyy-mm-dd hh24:mi:ss.ff';
alter session set nls_date_format = 'yyyy-mm-dd hh24:mi:ss';

-- this is problematic on a legacy db, as we cannot comment out a sqlplus command with a substitution variable
--&&legacy_db break on sql_id skip 1 on con_id on inst_id on sql_exec_id on seconds
break on sql_id skip 1 on con_id on inst_id on session_id on sql_exec_id on seconds


with data as (
	select
	 	sql_id
		&legacy_db , con_id
		, inst_id
		, session_id
		, sql_exec_id
		, count(*) over (partition by sql_id
			&legacy_db , con_id
			, inst_id, session_id, sql_exec_id  ) seconds
		, row_number() over (partition by sql_id
			&legacy_db , con_id
			, inst_id, session_id, sql_exec_id order by sql_exec_id, sample_id ) row#
		, sample_id
		, sql_exec_start
		, sample_time
		, sql_plan_operation
	from gv$active_session_history
	where sql_id is not null
		and sample_id is not null
		and sql_exec_id is not null
	--and sql_id  = '7hk2m2702ua0g'
)
select *
from data
where seconds > 1
order by  sql_id
	&legacy_db , con_id
	, inst_id, sql_exec_id ,sample_id
/

