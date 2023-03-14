
-- ash-blocker-waits.sql
-- show current blockers and SQL_ID
-- 
-- 2017-01-07

clear col 
clear break
ttitle off
btitle off

col v_event_filter new_value v_event_filter noprint

prompt
prompt Filter Blockers on event? (wildcard ok)
prompt
prompt

set feed off term off verify off
select '&1' v_event_filter from dual;
set feed on term on 

set echo off heading on feedback on
set linesize 200 trimspool on
set pagesize 60
set tab off

col blocking_sql_id format a12 head 'BLOCKING|SQL_ID'
col session_id format 999999 head 'SID'
col event format a40 head 'EVENT'
col session_state format a12 head 'SESSION|STATE'
col time_waited format 999,999.99 head 'TIME|WAITED|SECONDS'

col sample_time format a25 head 'SAMPLE TIME'


with blocked as (
	select distinct h.inst_id, h.sample_time, h.sample_id, h.session_id, h.session_serial#, h.blocking_session, h.blocking_session_serial#, h.sql_id, h.event, h.session_state
	from gv$active_session_history h
	where h.blocking_session is not null
	and h.event like '&v_event_filter'
),
blockers as (
	select distinct
		 max(b.sample_id) over (partition by b.inst_id, b.session_id, b.session_serial#) sample_id
		, max(b.sample_time) over (partition by b.inst_id, b.session_id, b.session_serial#) sample_time
		, count(b.sample_time) over (partition by b.inst_id, b.session_id, b.session_serial#) event_count
		, b.sql_id
		, b.inst_id
		, b.session_id
		, b.blocking_session
		, b.event
		, b.session_serial#
		, b.session_state
		-- NULL for top level blockers
		--, b.time_waited
	from blocked b
	left outer join gv$active_session_history bl
		on bl.sample_id = b.sample_id
		and bl.inst_id = b.inst_id
		and bl.sql_id = b.sql_id
		and bl.blocking_session = b.session_id
		and bl.blocking_session_serial# = b.blocking_session_serial#
)
select
	--sample_id
	sample_time
	, sql_id
	, session_id
	, blocking_session
	, inst_id
	, event_count
	, session_state
	, event
from blockers
order by sample_time, session_id
/
