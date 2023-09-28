
-- showplan_last.sql
-- works with 9.2+

SET PAUSE OFF
SET VERIFY OFF
set trimspool on
set linesize 500 arraysize 1
clear break
clear compute


col plan_table_output format a500
set pagesize 200

select *
--from table(dbms_xplan.display_cursor( null,null,'ALL ALLSTATS LAST'))
--
-- show estimated and elapsed timings
--from table(dbms_xplan.display_cursor( null,null,'ALL ALLSTATS LAST'))
-- shows outline data - query block names that may be used for hints
from table(dbms_xplan.display_cursor( null,null,'ADVANCED LAST ALLSTATS ALL'))
--from table(dbms_xplan.display_cursor( null,null,'TYPICAL LAST'))
/


