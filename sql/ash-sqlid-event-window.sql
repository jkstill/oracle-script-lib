
-- ash-sqlid-event-window.sql
-- Jared Still 2021 jkstill@gmail.com 
--
-- get all SQL running within a certain time each hour
-- in this case it is a 2 minutes window at the top of the hour
-- change the '-' to '+' to move the window around


col event format a40
set linesize 200 trimspool on
set pagesize 200

col pct_of_db_time format 999.99

break on inst_id on sql_id on session_id on session_serial# on sql_exec_id skip 1

with raw_data as (
	select inst_id
		, sql_exec_start
		, sql_id
		, session_id
		, session_serial#
		, sql_exec_id
		,decode(session_state,'ON CPU','ON CPU',h.event) event
	from gv$active_session_history h
	where
		sample_time between
			trunc(sample_time,'hh24') - numtodsinterval(1,'minute')
			and
			trunc(sample_time,'hh24') + numtodsinterval(1,'minute')
		and sql_id is not null
), summarized as(
	select distinct inst_id, sql_exec_start,	session_id, session_serial#, sql_exec_id,	 sql_id, event
		,count(*) 
			over (
				partition by inst_id, session_id, session_serial#, sql_exec_id, sql_exec_start, sql_id, event
				order by inst_id, session_id, session_serial#,sql_id
			) event_count
		,count(*) 
			over (
				partition by inst_id, session_id, session_serial#, sql_exec_id, sql_exec_start, sql_id
				order by inst_id, session_id, session_serial#,sql_id
			) event_sum
	from raw_data
), rpt_data as (
	select inst_id
		, sql_exec_start
		, sql_id
		, session_id
		, session_serial#
		, sql_exec_id
		, event
		, event_count
		, event_sum
		--, event_count / event_sum * 100 pct_of_db_time
	from summarized
)
select inst_id
	, sql_id
	, session_id
	, session_serial#
	, sql_exec_id
	, event
	, event_count
	, event_sum
from rpt_data
where event_sum > 5
order by inst_id, sql_id, session_id, session_serial#, sql_exec_id, event_count
/

