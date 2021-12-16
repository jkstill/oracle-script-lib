
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
	select distinct blocking_session, blocking_session_serial#,  sample_id
	from v$active_session_history
	--from dba_hist_active_sess_history
	where blocking_session is not null
	and  event like '&v_event_filter'
), 
blockers as (
	select distinct
		max(blkr.sample_id) over (partition by blkr.session_id, blkr.session_serial#) sample_id
		, max(blkr.sample_time) over (partition by blkr.session_id, blkr.session_serial#) sample_time
		, blkr.session_id
		, blkr.session_serial#
		, blkr.session_state
		, blkr.event
		--, blkr.time_waited
	from v$active_session_history blkr 
	join blocked b on b.blocking_session = blkr.session_id
		and b.blocking_session_serial# = blkr.session_serial#
		and blkr.blocking_session is null
)
select * 
from blockers
order by 1
/
		 

