
-- showplan9i.sql
-- works with 9.2+

SET PAUSE OFF
SET VERIFY OFF
set trimspool on
set line 200 arraysize 1
clear break
clear compute


select plan_table_output
from table(dbms_xplan.display( table_name=>'PLAN_TABLE', statement_id=>'&&1',format=>'ALL ALLSTATS'))
/

