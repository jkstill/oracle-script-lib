
-- showplan_last.sql
-- show execution plan for the most recently run SQL in your session
-- works with 9.2+

set pause off
set verify off
set trimspool on
set linesize 500 arraysize 1
clear break
clear compute


col plan_table_output format a500
set pagesize 200

select *
from table(dbms_xplan.display_cursor( null,null,'ADVANCED LAST ALLSTATS ALL'))
/


