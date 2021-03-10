
-- see http://blog.tanelpoder.com/2009/03/03/the-full-power-of-oracles-diagnostic-events-part-1-syntax-for-ksd-debug-event-handling/

-- set_events.sql

-- set event to catch an error, 6502 in this case.
-- other error numbers may require a different level
-- or an alternate syntax

-- set event on
-- this will dump a trace on ORA-6502 error
-- alter system set events '6502 trace name errorstack level 10';

-- catch various ORA errors
--event="1555 trace name errorstack level 3"
--event="4031 trace name errorstack level 3"
--event="1652 trace name processstate level 10"


-- this syntax will not cause a trace file to be dumped
-- alter system set events '6502 trace name context forever, level 1';

-- off
--alter system set events '6502 trace name  context off';

-- alter system set events '947 trace name errorstack level 12, lifetime 5; name processstate level 2, lifetime 5'

-- dump errorstack and processtate for 5 events

-- alter system set events '4020 trace name errorstack level 12, lifetime 5; name processstate level 2, lifetime 5';

-- #########################################################
-- ## here's some test code to force the 6502 error and test
-- ## to see if a trace is dumped
-- #########################################################


--drop table x6502;

--create table x6502( test_col varchar2(20) );

--insert into x6502 values('this is a test');

--commit;


--declare
	--too_short varchar2(6);
--begin
	--select test_col into too_short
	--from x6502 
	--where rownum < 2;
--end;
--/

-- #########################################################
-- ## 11g - set events to trace a SQL statement 
-- ## regardless of the session that executes it
-- ## note: subsequent SQL may be included in the trace file
-- ## for the session as well
-- #########################################################

-- multiple sql_id traces may be specified

-- alter system set events 'sql_trace[SQL:015msjdtwmf65] plan_stat=all_executions,wait=true,bind=false';
-- alter system set events 'sql_trace[SQL:02hnhu3dv424q] plan_stat=all_executions,wait=true,bind=false';
-- alter system set events 'sql_trace[SQL:0ug54s8cg41up] plan_stat=all_executions,wait=true,bind=false';

-- alter system set events 'sql_trace[SQL:0ug54s8cg41up]plan_stat=all_executions,wait=true,bind=false; name processstate level 2, lifetime 5';

-- each must be turned off explicitly

-- alter system set events 'sql_trace[SQL:015msjdtwmf65] off';
-- alter system set events 'sql_trace[SQL:02hnhu3dv424q] off';
-- alter system set events 'sql_trace[SQL:0ug54s8cg41up] off';


-- ###############################
-- # PGA and SGA heap dump
-- ###############################
-- http://blog.tanelpoder.com/2009/06/24/oracle-memory-troubleshooting-part-3-automatic-top-subheap-dumping-with-heapdump/
-- http://dioncho.wordpress.com/2009/07/27/playing-with-ora-4030-error/
-- http://www.juliandyke.com/Diagnostics/Dumps/Dumps.html
-- http://juliandyke.com/Diagnostics/Dumps/HEAPDUMP.html
--alter system set events='4030 trace name heapdump level 0x20000001, lifetime 1';


