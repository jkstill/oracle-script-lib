
--liveplan10g_hash.sql
-- this is for 10g and later
-- see liveplan_10g.sql


@clears

col uhashvalue new_value uhashvalue noprint
prompt HASH_VALUE Value of SQL from V$SQL:
set echo off term off head off
select '&1' uhashvalue from dual;
set term on head on

var sqlidvar varchar2(20)
begin
	select sql_id into :sqlidvar
	from v$sql
	where hash_value = &&uhashvalue;
end;
/

set line 120

prompt
prompt !! Child cursor is set to 0 !!
prompt !! Change value if needed   !!
prompt

--select plan_table_output from table(dbms_xplan.DISPLAY('LIVEPLAN',:hashvar),'serial');


--select plan_table_output
select *
from TABLE(
   dbms_xplan.display_cursor(:sqlidvar,,'ALL ALLSTATS LAST')
   )
/


undef 1


