
-- sys-context-all.sql
-- get all sys_context values for userenv
-- could be enhanced to be version aware
-- Jared Still
-- jkstill@gmail.com 2022

col parm_name format a30
col parm_value format a80

set linesize 200 trimspool on
set pagesize 100


with data as (
	select column_value parm_name
	from 
	(
		table(
			sys.odcivarchar2list(
				'action', 'audited_cursorid', 'authenticated_identity', 'authentication_data', 'authentication_method', 
				'bg_job_id', 
					--'cdb_domain', -- 19c
				'cdb_name', 'client_identifier', 'client_info', 'client_program_name', 'con_id', 'con_name', 'current_bind', 
				'current_edition_id', 'current_edition_name', 'current_schema', 'current_schemaid', 'current_sql', 'current_sql_length', 
				'current_user', 'current_userid', 
				'database_role', 'db_domain', 'db_name', 'db_supplemental_log_level', 'db_unique_name', 'dblink_info', 
					--'drain_status',  -- 19c
				'entryid', 'enterprise_identity', 
				'fg_job_id', 
				'global_context_memory', 'global_uid',
				'host', 
				'identification_type', 'instance', 'instance_name', 'ip_address', 'is_apply_server', 
				'is_application_root', 'is_application_pdb', 'is_dg_rolling_upgrade', 'isdba', 
				'lang', 'language', 'ldap_server_type', 
				'module', 
				'network_protocol', 'nls_calendar', 'nls_currency', 'nls_date_format', 
				'nls_date_language', 'nls_sort', 'nls_territory', 
				'oracle_home', 'os_user',
					--'pid' -- server pid - 21c - why so long?
				'platform_slash', 'policy_invoker', 'proxy_enterprise_identity', 'proxy_user', 'proxy_userid',
				'scheduler_job', 'server_host', 'service_name', 'session_default_collation', 'session_edition_id', 
				'session_edition_name', 'session_user', 'session_userid', 'sessionid', 'sid', 'statementid', 
				'terminal', 
				'unified_audit_sessionid'
)
		)
	)
)
select parm_name
	, nvl(sys_context('userenv',parm_name),'NULL') parm_value 
from data
order by parm_name
/


