
-- ua-audit-log-cleanup-job.sql
-- Retention is 30 days

create or replace procedure ua_log_purge (retention_days integer) 
is
	
begin

	dbms_audit_mgmt.set_last_archive_timestamp (
		audit_trail_type	=> dbms_audit_mgmt.audit_trail_unified,
		last_archive_time => systimestamp - retention_days
	);
	
	dbms_audit_mgmt.clean_audit_trail(
		audit_trail_type			=> dbms_audit_mgmt.audit_trail_unified,
		use_last_arch_timestamp => true
	);

end;
/


begin
	dbms_scheduler.create_job (
		job_name				=> 'UA_LOG_PURGE_JOB',
		job_type				=> 'PLSQL_BLOCK',
		job_action			=> 'begin sys.ua_log_purge(30); end;',
		start_date			=>	 systimestamp + interval '1' Hour,
		repeat_interval	=> 'FREQ=DAILY',
		enabled				=> true
	);
end;
/


