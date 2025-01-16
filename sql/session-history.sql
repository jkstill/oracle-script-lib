
-- session-history.sql
-- Jared Still 2015-10-21
-- 
-- jk

col vinstance new_value vinstance
select lower(instance_name) vinstance from v$instance;

@clear_for_spool
set line 400 trimspool on
--set pagesize 60

col start_time format a30
col end_time format a30
col username format a20

set term off

spool session-hist-&&vinstance..csv

prompt USERNAME,SESSION ID,SESSION SERIAL#,START TIME,END TIME,DURATION

with data as (
select distinct
	u.username
	, m.snap_id
	, session_id
	, m.session_serial#
	--, s.begin_interval_time
	--, s.end_interval_time
	, first_value(s.begin_interval_time) over (partition by u.user_id,session_id,session_serial# order by s.begin_interval_time) start_time
	, last_value(s.end_interval_time) over (partition by u.user_id,session_id,session_serial# order by s.end_interval_time) end_time
from dba_hist_active_sess_history m
join dba_hist_snapshot s on s.snap_id = m.snap_id
join dba_users u on u.user_id = m.user_id
)
select 
/*
	username
	, session_id
	, session_serial#
	, to_char(start_time,'yyyy-mm-dd hh24:mi:ss') start_time
	, to_char(end_time,'yyyy-mm-dd hh24:mi:ss') end_time
	, end_time - start_time duration
*/
	username
	|| ',' || session_id
	|| ',' || session_serial#
	|| ',' || to_char(start_time,'yyyy-mm-dd hh24:mi:ss')
	|| ',' || to_char(end_time,'yyyy-mm-dd hh24:mi:ss')
	|| ',''' || to_char(end_time - start_time)
from data
order by username, start_time
/

spool off
set term on

@clears


ed session-hist-&&vinstance..csv
