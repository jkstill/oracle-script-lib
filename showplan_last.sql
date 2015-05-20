
-- showplan9i.sql
-- works with 9.2+

SET PAUSE OFF
SET VERIFY OFF
set trimspool on
set line 500 arraysize 1
clear break
clear compute


select *
--from table(dbms_xplan.display_cursor( null,null,'ALL ALLSTATS LAST'))
--
-- show estimated and elapsed timings
from table(dbms_xplan.display_cursor( null,null,'ALL ALLSTATS LAST'))
--from table(dbms_xplan.display_cursor( null,null,'ADVANCED LAST'))
--from table(dbms_xplan.display_cursor( null,null,'TYPICAL LAST'))
/


