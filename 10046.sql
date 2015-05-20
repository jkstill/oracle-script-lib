
-- level 4 is bind values
-- level 8 is waits
-- level 12 is both

--
-- see 10046_off.sql to end tracing

alter session set events '10046 trace name context forever, level 12';
--sys.dbms_system.set_ev(sid(n), serial(n), 10046, 8, '');

