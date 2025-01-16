
-- ua-session.sql
-- report of session logon/logoff from unified auditing
-- create audit policy connection_policy actions logon,logoff when 'sys_context(''userenv'',''session_user'')=''TEST01''' evaluate per session;
-- or
-- create audit policy connection_policy actions logon,logoff;
-- 
-- enable
-- audit policy connection_policy;
--
-- enable the logon failure policy
-- audit policy ORA_LOGON_FAILURES;



col dbusername format a20
col os_username format a20
col event_timestamp format a29
col action_name format a15
col return_code format 99999 head 'RETURN|CODE'
col userhost format a20
col terminal format a15
col instance_id format 9999 head 'INST'
col authentication_type format a50
col unified_audit_policies format a30

set linesize 200 trimspool on
set pagesize 100

select
	dbusername
	, to_char(event_timestamp,'yyyy-mm-dd hh24:mi:ss') event_timestamp
	, unified_audit_policies
	, action_name
	, return_code
	, os_username
	, userhost
	, terminal
	, instance_id
	--, authentication_type
from unified_audit_trail ua
where action_name like 'LOGO%'
order by 1,2
/


