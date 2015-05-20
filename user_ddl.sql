
-- schema_ddl.sql

@clears

col cuser new_value Username noprint
prompt
prompt User to duplicate? :
prompt
set feed off term off 
select upper('&&1') cuser from dual;
set feed on term on


@clear_for_spool
set linesize 1000
set long 10000

col sqlfile new_value sqlfile noprint
col mydb noprint new_value mydb
set term off
select lower(name) mydb from v$database;
set term on

select '_gen_' || lower('&&Username') || '_' || '&&mydb'  sqlfile from dual;

-- dbms_metadata setup
begin
	dbms_metadata.set_transform_param(dbms_metadata.session_transform,'PRETTY',TRUE);
	dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SQLTERMINATOR',TRUE);
	dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SEGMENT_ATTRIBUTES',TRUE);
	dbms_metadata.set_transform_param(dbms_metadata.session_transform,'STORAGE', TRUE);
	dbms_metadata.set_transform_param(dbms_metadata.session_transform,'TABLESPACE',TRUE);
	dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SPECIFICATION',TRUE);
	dbms_metadata.set_transform_param(dbms_metadata.session_transform,'BODY',TRUE);
	dbms_metadata.set_transform_param(dbms_metadata.session_transform,'CONSTRAINTS',TRUE);
end;
/


spool &&sqlfile..sql

prompt set echo on
prompt spool &&sqlfile..log

select (case 
	when ((select count(*)
	       from   dba_users
	       where  username = '&&Username') > 0)
	then  dbms_metadata.get_ddl ('USER', '&&Username') 
	else  to_clob ('   -- Note: User not found!')
	end ) Extracted_DDL from dual
UNION ALL
select (case 
	when ((select count(*)
	       from   dba_ts_quotas
	       where  username = '&&Username') > 0)
	then  dbms_metadata.get_granted_ddl( 'TABLESPACE_QUOTA', '&&Username') 
	else  to_clob ('   -- Note: No TS Quotas found!')
	end ) from dual
UNION ALL
select (case 
	when ((select count(*)
	       from   dba_role_privs
	       where  grantee = '&&Username') > 0)
	then  dbms_metadata.get_granted_ddl ('ROLE_GRANT', '&&Username') 
	else  to_clob ('   -- Note: No granted Roles found!')
	end ) from dual
UNION ALL
select (case 
	when ((select count(*)
	       from   dba_sys_privs
	       where  grantee = '&&Username') > 0)
	then  dbms_metadata.get_granted_ddl ('SYSTEM_GRANT', '&&Username') 
	else  to_clob ('   -- Note: No System Privileges found!')
	end ) from dual
UNION ALL
select (case 
	when ((select count(*)
	       from   dba_tab_privs
	       where  grantee = '&&Username') > 0)
	then  dbms_metadata.get_granted_ddl ('OBJECT_GRANT', '&&Username') 
	else  to_clob ('   -- Note: No Object Privileges found!')
	end ) from dual
/

prompt spool off
prompt set echo off

spool off

@clears

undef 1

prompt
prompt ===========================================================================
prompt == &&sqlfile..sql contains DDL for tablespaces
prompt ===========================================================================
prompt

undef 1

