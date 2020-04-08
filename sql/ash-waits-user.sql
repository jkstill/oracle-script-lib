-- ash-waits-user.sql

/*

 summarize ASH all wait time for a user
 call with username, start time and end time
 format for time is 'YYY-MM-DD HH24:MI'
 use literal BEGIN and END to get all rows

 use ash-sessions.sql to get the time period

 examples:

 @ash-waits-user SCOTT '2016-03-16 16:52:00' '2016-03-16 17:21:00'

 @ash-waits-user SCOTT BEGIN '2016-03-16 17:21:00'

 @ash-waits-user SCOTT '2016-03-16 16:52:00' END

 @ash-waits-user SCOTT BEGIN END


*/


set linesize 200 trimspool on
set pagesize 60

col target_user new_value target_user noprint

col end_interval_time format a22
col name format a30
col username format a20 head 'USERNAME'

col total_wait_seconds new_value total_wait_seconds
col elapsed_seconds new_value elapsed_seconds
col cpu_time new_value cpu_time

col snap_begin_time new_value snap_begin_time noprint
col snap_end_time new_value snap_end_time noprint

col wait_seconds format 999,999 head 'WAIT|SECONDS'
col pct_elapsed format a10 head 'PERCENT|ELAPSED'

prompt 
prompt Target User: 
prompt

set feed off term off echo off verify off
select upper('&&1') target_user from dual;
set term on 

prompt
prompt Start Time: 
prompt 

set feed off term off echo off verify off
select upper('&&2') snap_begin_time from dual;
set term on 

prompt
prompt End Time: 
prompt 

set feed off term off echo off verify off
select upper('&&3') snap_end_time from dual;
set term on 


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


	select
		max(sample_time) - min(sample_time) into ash_interval
	from v$active_session_history
	where sample_time 
	between
		decode('&&snap_begin_time',
			'BEGIN',
			to_timestamp('1900-01-01 00:00:00','yyyy-mm-dd hh24:mi:ss'),
			to_timestamp('&&snap_begin_time','yyyy-mm-dd hh24:mi:ss')
		)
		AND
		decode('&&snap_end_time',
			'END',
			to_timestamp('4000-12-31 23:59:00','yyyy-mm-dd hh24:mi:ss'),
			to_timestamp('&&snap_end_time','yyyy-mm-dd hh24:mi:ss')
		);

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
