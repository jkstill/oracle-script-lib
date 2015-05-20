
-- dumptracem_off.sql
-- turn 10046 tracing off for all sessions of a user
-- and reset max_dump_file_size to 5 meg




@clears
col wuser new_value wuser noprint
col 

prompt Unset event 10046 for all sessions of which user?
set head off term off feed off
select '&1' wuser from dual;
set head on term on feed on

declare

	cursor c_session
	is
	select sid, serial#
	from v$session
	where username = upper('&&wuser');

begin
	for srec in c_session
	loop
		dbms_output.put_line(srec.sid || '.' || srec.serial# );
		sys.dbms_system.set_ev(srec.sid, srec.serial#, 10046, 0, '');
		--sys.dbms_system.set_sql_trace_in_session(srec.sid, srec.serial#, false);
		--dbms_support.stop_trace_in_session(srec.sid, srec.serial#);
	end loop;
end;
/


alter system set max_dump_file_size = 10240;

