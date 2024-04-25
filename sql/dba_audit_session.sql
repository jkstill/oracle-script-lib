

@columns

col os_username format a15
col terminal format a15
set pages 6000
set linesize 200 trimspool on

col which_user noprint new_value which_user

prompt Get Audit Records for Which User? (wildcard ok) 
set feed off term off
select '&1' || '%' which_user from dual;
set feed on term on


select
	username
	, os_username
	, terminal
	, action_name
	, max(timestamp) timestamp
from dba_audit_session
where username like upper('&&which_user')
--and rownum < 100
group by  username, os_username, terminal, action_name
order by  username, timestamp
/

undef 1

