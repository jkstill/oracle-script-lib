-- ash-sessions.sql
-- frequency of sessions for a user

set linesize 200 trimspool on
set pagesize 60

col target_user new_value target_user noprint

col end_interval_time format a22
col name format a30
col username format a20 head 'USERNAME'

prompt 
prompt Target User: 
prompt


set feed off term off echo off verify off

select upper('&&1') target_user from dual;

var v_wall_seconds number
col wall_seconds new_value wall_seconds noprint

declare
	ash_interval interval day to second;
begin

	select max(sample_time) - min(sample_time) into ash_interval from v$active_session_history;

	:v_wall_seconds := 
		(extract(hour from ash_interval) * 3600 )
		+ (extract(second from ash_interval) * 60 )
		+ extract(second from ash_interval) ;
end;
/


select round(:v_wall_seconds,0) wall_seconds from dual;

set feed on term on

with sessions as (
select  distinct
	to_char(h.sample_time,'yyyy-mm-dd hh24:mi') sample_time
	, min(session_id) over (partition by to_char(h.sample_time,'yyyy-mm-dd hh24:mi'), session_id, session_serial# order by session_id, session_serial#) session_id
from v$active_session_history h
join dba_users u on u.user_id = h.user_id
where u.username = '&&target_user'
)
select 
	sample_time
	, count(*) session_count
from sessions
group by sample_time
order by 1,2
/

prompt
prompt "Wall Seconds: &&wall_seconds"
prompt 

undef 1
