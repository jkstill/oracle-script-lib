
-- tron.sql
-- turn on tracing for all current sessions of a user

@clears

prompt
prompt Turn ON SQL Trace on for all sessions of a user
prompt includes bind vars
prompt

col cuser noprint new_value uuser

prompt USERNAME ? 
set term off  feed off
select '&1' cuser from dual;
set term on feed on

set serveroutput on size 1000000

declare
	cursor sessCurs
	is
	select sid, serial#
	from v$session
	where username = upper('&&uuser');
begin
	for srec in sessCurs
	loop
		dbms_output.put_line(srec.sid || '.' || srec.serial# );
		sys.dbms_system.set_sql_trace_in_session(srec.sid, srec.serial#, TRUE);
		sys.dbms_system.set_ev(srec.sid, srec.serial#, 10046, 4, '');
	end loop;

end;
/


undef 1


