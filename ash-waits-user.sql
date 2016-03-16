-- ash-waits-user.sql
-- summarize ASH all wait time for a user

set linesize 200 trimspool on
set pagesize 60

col target_user new_value target_user noprint

col end_interval_time format a22
col name format a30
col username format a20 head 'USERNAME'

col total_wait_seconds new_value total_wait_seconds
col elapsed_seconds new_value elapsed_seconds
col cpu_time new_value cpu_time

col wait_seconds format 999,999 head 'WAIT|SECONDS'
col pct_elapsed format 99.9 head 'PERCENT|ELAPSED'

prompt 
prompt Target User: 
prompt


set feed off term off echo off verify off

select upper('&&1') target_user from dual;

select  
	count(*) cpu_time
from v$active_session_history h
	join dba_users u on u.user_id = h.user_id
where u.username = '&&target_user'
	and h.session_state = 'ON CPU'
/

select  
	count(*) total_wait_seconds
from v$active_session_history h
	join dba_users u on u.user_id = h.user_id
where u.username = '&&target_user'
	and h.session_state = 'WAITING'
/

select  &&cpu_time + &&total_wait_seconds  elapsed_seconds from dual;

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

--prompt
--prompt "	 Wait Time: &&total_wait_seconds"
--prompt "	  CPU Time: &&cpu_time"
--prompt "Elapsed Time: &&elapsed_seconds"
--prompt 

with waits as (
select  distinct
	h.event
	, count(*) over (partition by event) wait_seconds
from v$active_session_history h
	join dba_users u on u.user_id = h.user_id
where u.username = '&&target_user'
	and h.session_state = 'WAITING'
) 
select 
	event
	, wait_seconds
	, to_char(wait_seconds / &&elapsed_seconds * 100, '09.9') pct_elapsed
from waits
order by 2
/

prompt
prompt "   Wait Time: &&total_wait_seconds"
prompt "		CPU Time: &&cpu_time"
prompt "Elapsed Time: &&elapsed_seconds"
prompt "Wall Seconds: &&wall_seconds"
prompt 

undef 1
