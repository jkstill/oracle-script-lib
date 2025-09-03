

-- dba_audit_session_recent.sql
-- display most recent logon of each user in database
-- grouped by username, osusername, terminal and action

@columns

col os_username format a15
col terminal format a15
col returncode head 'EXIT|CODE' format 999999
col logon format a20 head 'LOGON TIME'
col logoff format a20 head 'LOGOFF TIME'

set pagesize 60
set linesize 120

select
	username
	, max(timestamp) logon
	--, os_username
	--, terminal
	, action_name
	--, returncode
from dba_audit_session
group by  username, action_name
order by  username, logon
/

