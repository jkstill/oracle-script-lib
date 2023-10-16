
--liveplan.sql
-- this is for 9i and earlier
-- see liveplan_10g.sql


@clears

col which_hash new_value which_hash noprint
prompt Hash Value of SQL from V$SQLTEXT:
set echo off term off head off
select '&1' which_hash from dual;
set term on head on

var hashvar number
begin
	:hashvar := &&which_hash;
end;
/

set line 120

--select plan_table_output from table(dbms_xplan.DISPLAY('LIVEPLAN',:hashvar),'serial');


select plan_table_output
from TABLE(
   dbms_xplan.display('liveplan',
     	:hashvar,
      'serial'
   )
)
/


undef 1


