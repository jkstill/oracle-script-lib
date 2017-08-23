
-- dumptracem_on.sql
-- turn 10046 tracing on for all sessions of a user
-- and set max_dump_file_size to unlimited


alter system set max_dump_file_size = unlimited;

@clears
col wuser new_value wuser noprint

prompt Set event 10046 for all sessions of which user?  
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
		sys.dbms_system.set_ev(srec.sid, srec.serial#, 10046, 12, '');
		--dbms_support.start_trace_in_session(srec.sid, srec.serial#,waits=>true,binds=>true);
	end loop;
end;
/


