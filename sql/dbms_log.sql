
-- dbms_log.sql
-- Jared Still
--  2018  jkstill@gmail.com
--
-- the alert_log fucntions from sys.dbms_system.ksdwrt are now available in dbms_log, available since 11.2.0.4
-- as reported by Jonathan Lewis
-- https://jonathanlewis.wordpress.com/2018/10/12/dbms_log
-- thanks to Cary Millsap
--

/*

Write messages to the alert log and/or current trace file

DBMS_LOG

PROCEDURE KSDDDT - write date
PROCEDURE KSDFLS - flush writes

PROCEDURE KSDIND - indent output
 Argument Name                  Type                    In/Out Default?
 ------------------------------ ----------------------- ------ --------
 LVL                            BINARY_INTEGER          IN

PROCEDURE KSDWRT - write to output
 Argument Name                  Type                    In/Out Default?
 ------------------------------ ----------------------- ------ --------
 DEST                           BINARY_INTEGER          IN
 TST                            VARCHAR2                IN


The value for DEST controls which files are writtent to 
1: write to trace file only
2: write to alert log only
3: write to both


The first call must be to KSDWRT, which will open the file

*/


-- create an easily identifiable trace file

alter session set tracefile_identifier = 'DBMS-LOG';
alter session set sql_trace=true;

-- could also use one of the following
--   dbms_monitor.session_trace_enable 
--   alter session set events '10046 trace name context forever, level 12';
--   dbms_system.set_ev


-- initialize both files
exec sys.dbms_log.ksdwrt(3,'Initialize log and trace file write')

-- write the date - goes to all open files

exec sys.dbms_log.ksdddt

-- write a line to trace file only
exec sys.dbms_log.ksdwrt(1,'Trace file only')

-- write a line to alert log only
exec sys.dbms_log.ksdwrt(2,'Alert log only')

-- write a line to the trace file and the alert log
exec sys.dbms_log.ksdwrt(3,'Write to both the alert log and the trace file');

-- flush the writes
exec sys.dbms_log.ksdfls

-- close the trace file
alter session set events '10046 trace name context off';


