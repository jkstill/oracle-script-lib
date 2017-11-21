
-- showplan_awr.sql
-- this is for 10g and later


@clears

col usql_id new_value usql_id noprint
prompt SQL_ID Value of SQL from V$SQL:
set echo off term off head off
select '&1' usql_id from dual;
set term on head on

set linesize 250 trimspool on
set pagesize 200

var sqlidvar varchar2(20)
var childnumvar number

begin
	:sqlidvar := '&&usql_id';
end;
/

set line 180
col plan_table_output format a180


select *
from TABLE(
   dbms_xplan.display_awr(sql_id => :sqlidvar, format => 'ALL ALLSTATS LAST')
   )
/


undef 1


