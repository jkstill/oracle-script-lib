
-- tracefile.sql
-- Jared Still
-- get the full tracefile name for your session

-- an alternative
-- select value from v$diag_info where name  = 'Default Trace File';
-- 
-- the method used following allows plugging in the SID for another session

select tracefile from v$process where addr = (
  select paddr from v$session where sid = sys_context('userenv','sid')
)
/


