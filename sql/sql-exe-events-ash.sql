
-- sql-exe-events-ash.sql
-- Jared Still  jkstill@gmail.com
--  2018

@clears

col u_sql_id new_value u_sql_id noprint
var v_sql_id varchar2(13) 

set linesize 200 trimspool on
set pagesize 100

prompt
prompt SQL_ID: 
prompt

set term off feed off verify off

select '&1' u_sql_id from dual;

set term on feed on

exec :v_sql_id := '&u_sql_id'

break on session_id on sql_exec_id skip 1

with sql_data as (
	select inst_id, sql_id
		, session_id, session_serial#, sql_exec_id
		, nvl(event,'CPU') event
	from gv$active_session_history h
	where sql_id = :v_sql_id
	order by
		inst_id
		, sql_id
		, session_id
		, session_serial#
		, sql_exec_id
)
select 
	session_id, sql_exec_id
	, event
	, count(event) event_count
from sql_data
group by 
	session_id, sql_exec_id
	, event
order by 
	session_id, sql_exec_id
	, event_count
/

undef &1

