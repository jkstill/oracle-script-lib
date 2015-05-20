
-- check_events.sql

-- reports on any events that are set

-- demo by setting some events:
--    alter session set events '10015 trace name context forever, level 3';
--    alter session set sql_trace=true;
 
set serveroutput on size 1000000

declare
	event_level number;
begin
	for i in 10000..10999 loop
		sys.dbms_system.read_ev(i,event_level);
		if (event_level > 0) then
			dbms_output.put_line('Event '||to_char(i)||' set at level '||
				to_char(event_level));
		end if;
	end loop;
end;
/


