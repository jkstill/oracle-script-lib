
-- nls_date_format.sql
-- set the default date format
-- can be run interactively or run from the command line
-- e.g. '@nls_date_format 1' will set the format to MM/DD/YYYY HH24:MI:SS
--
-- jkstill 10/27/99 - use DBMS_SQL rather than spooled script

@clears

select sysdate from dual;

prompt Which Date Format Should I Use?

prompt 1.  2012-02-27 14:25:52
prompt
prompt 2.  2012-02-27
prompt
prompt 3.  20-MAR-98
prompt
prompt 4.  20-MAR-1998
prompt

set term off feed off
col cdateformat noprint new_value udateformat 
select '&1' cdateformat from dual;


-- uncomment to see dbms_output output
set feed on term on
declare
	d_sql_cursor integer;
	v_sqlcmd varchar2(2000);
	retval integer;
begin

	select 'alter session set nls_date_format = ' || '''' ||
	decode('&&udateformat',
		'1', 'yyyy-mm-dd hh24:mi:ss',
		'2', 'yyyy-mm-dd', 
		'3', 'DD-MON-YY',
		'4', 'DD-MON-YYYY'
	) || '''' into v_sqlcmd
	from dual;

	dbms_output.put_line('SQLCMD: ' || v_sqlcmd);
	d_sql_cursor := dbms_sql.open_cursor;
	begin
		dbms_sql.parse(d_sql_cursor,v_sqlcmd, dbms_sql.native);
		retval := dbms_sql.execute(d_sql_cursor);
	exception
	when others then
		raise_application_error(-20999,'Error parsing NLS_DATE format');
	end;
	dbms_sql.close_cursor(d_sql_cursor);

end;
/

set pages 24 term on 
select sysdate from dual;
set feed on
prompt

undef 1



