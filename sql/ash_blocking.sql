
-- ash_blocking.sql
-- show recent blockers and SQL_ID
-- 
-- 2013-09-09

clear col 
clear break
ttitle off
btitle off

set echo off heading on feedback on
set linesize 200 trimspool on
set pagesize 60

col blocking_sql_id format a12 head 'BLOCKING|SQL_ID'
col session_id format 999999 head 'SID'
col event format a40 head 'EVENT'
col session_state format a12 head 'SESSION|STATE'
col time_waited format 999,999.99 head 'TIME|WAITED|SECONDS'

col sample_time format a25 head 'SAMPLE TIME'

with blockers as (
	select distinct blocking_session session_id, blocking_session_serial# session_serial#, sample_id
	from v$active_session_history
	--from dba_hist_active_sess_history
	where blocking_session is not null
),
blocked as (
	select distinct 
		ash.sample_id
		, ash.session_id 
		, ash.session_serial#
		, ash.blocking_session
		, ash.blocking_session_serial#
		, ash.time_waited
		, max(ash.time_waited) over ( partition by ash.session_id, ash.session_serial#)	max_time_waited
	from v$active_session_history ash
	--from dba_hist_active_sess_history ash
	join blockers blkr on ash.blocking_session = blkr.session_id
		and ash.blocking_session_serial# = blkr.session_serial#
		and ash.sample_id = blkr.sample_id
	where ash.session_state = 'WAITING'
		and ash.event = 'enq: TX - row lock contention'
	--group by ash.session_id, ash.session_serial#, ash.blocking_session, ash.blocking_session_serial#
) 
select blkd.sample_id
	, blkr.sample_time
	, blkd.session_id
	, blkd.session_serial#
	, blkd.blocking_session
	, blkd.blocking_session_serial#
	, blkd.time_waited / 100 time_waited
	, blkr.sql_id
	, blkr.session_state
	, blkr.event
from blocked blkd
join v$active_session_history blkr 
	on blkr.session_id = blkd.blocking_session 
	and blkr.session_serial# = blkd.blocking_session_serial#
	and blkr.session_id = blkd.blocking_session
	and blkr.session_serial# = blkd.blocking_session_serial#
	and blkr.sample_id = blkd.sample_id
-- a kludge to get the sample id from blocked() query
where blkd.time_waited = blkd.max_time_waited
order by blkd.sample_id, blkd.session_id
/
		 

