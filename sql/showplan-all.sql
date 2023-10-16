
-- showplan_all.sql
-- works with 9.2+
-- show all execution plans for a SQL_ID

set serveroutput off
set pause off
set verify off
set echo off 
set trimspool on
clear break
clear compute
btitle off
ttitle off

prompt
prompt SQL_ID: 
prompt

col u_sql_id new_value u_sql_id noprint
set feed off term off
select '&1' u_sql_id from dual;
set feed on term on

col plan_table_output format a200
set linesize 400 trimspool on
set pagesize 200

select t.*
from v$sql s,
	table(dbms_xplan.display_cursor(s.sql_id,s.child_number,'ADVANCED LAST ALLSTATS ALL')) t 
where s.sql_id = '&u_sql_id' 
/



