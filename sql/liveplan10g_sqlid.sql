
--liveplan10g_sqlid.sql
-- this is for 10g and later
-- see liveplan_10g.sql


@clears

col usql_id new_value usql_id noprint
prompt SQL_ID Value of SQL from V$SQL:
set echo off term off head off
select '&1' usql_id from dual;
set term on head on

var sqlidvar varchar2(20)
var childnumvar number

begin
	:sqlidvar := '&&usql_id';
end;
/

set linesize 220 trimspool on
col plan_table_output format a220

prompt SQL_ID: sqlidvar

prompt Child Cursors available
(using the min() )

select child_number
from v$sql_shared_cursor
where sql_id = :sqlidvar
order by child_number
/


begin
	select min(child_number) into :childnumvar
	from v$sql_shared_cursor
	where sql_id = :sqlidvar;
end;
/



select *
from TABLE(
   dbms_xplan.display_cursor(:sqlidvar,:childnumvar,'ALL ALLSTATS LAST')
   )
/


undef 1


