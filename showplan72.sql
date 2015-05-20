
-- showplan72.sql
-- 'position' in 7.2 is actually 'cost'
-- commented it out because 'I don't think so'

SET PAUSE OFF
SET VERIFY OFF
set line 100
clear break
clear compute

break on report
compute sum of position on report

col operation format a35
col options format a12
col object_name format a30
col position format 9999 heading '-COST-'
col optimizer format a10

SELECT 
	lpad('  ',2*(level-1))||operation operation, 
	options, 
	object_name, 
	--position ,
	optimizer
FROM plan_table
START WITH id = 0 and statement_id = '&1'
CONNECT BY PRIOR id = parent_id AND statement_id = '&1'
ORDER BY id
/

UNDEF StatementID

