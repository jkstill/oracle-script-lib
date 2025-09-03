
-- dumptracem_on.sql
-- turn 10046 tracing on for all sessions of a user
-- and set max_dump_file_size to unlimited

alter system set max_dump_file_size = unlimited;

clear col
clear break
clear computes

btitle ''
ttitle ''

btitle off
ttitle off

set newpage 1
set tab off

set pause off
set echo off
set timing off
set verify off

set feed on
set term on
set head on

set linesize 200 trimspool on
set pagesize 100

col wuser new_value wuser noprint

prompt Set event 10046 for all sessions of which user?  
set head off term off feed off
select '&1' wuser from dual;
set head on term on feed on

declare

	cursor c_session
	is
	select
		s.sid,
		s.serial#,
		p.pid pid
	from v$session s, v$process p
	where s.username = upper('&&wuser')
		and p.addr = s.paddr
	order by sid;

begin
	for srec in c_session
	loop
		dbms_output.put_line(srec.sid || '.' || srec.serial# );
		sys.dbms_system.set_ev(srec.sid, srec.serial#, 10046, 8, '');
		--dbms_support.start_trace_in_session(srec.sid, srec.serial#,waits=>true,binds=>true);
	end loop;
end;
/


