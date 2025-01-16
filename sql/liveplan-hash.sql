
--liveplan-hash.sql
-- this is for 10g and later
-- see liveplan_10g.sql

@clears

col uhashvalue new_value uhashvalue noprint
prompt HASH_VALUE Value of SQL from V$SQL:
set echo off term off head off
select '&1' uhashvalue from dual;
set term on head on

var childnumvar number
var sqlidvar varchar2(20)

begin

	select sql_id into :sqlidvar
	from v$sql
	where plan_hash_value = &&uhashvalue
		and rownum < 2;


	select min(child_number) into :childnumvar
	from v$sql
	where sql_id = :sqlidvar
		and executions is not null;
end;
/

set linesize 200 trimspool on
set pagesize 100

--select plan_table_output from table(dbms_xplan.DISPLAY('LIVEPLAN',:hashvar),'serial');


--select plan_table_output
select *
from TABLE(
	dbms_xplan.display_cursor(:sqlidvar,:childnumvar,'ALL ALLSTATS LAST')
	)
/
