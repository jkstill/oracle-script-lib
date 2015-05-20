
-- showdistrg.sql
-- show disabled triggers

@clears
@columns

select 
	owner
	, trigger_name
	, status
from dba_triggers
where status = 'DISABLED'
/

