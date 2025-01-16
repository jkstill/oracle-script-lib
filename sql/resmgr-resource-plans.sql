
-- resmgr-resource-plans.sql
-- resource plans

@clears
@resmgr-columns
@resmgr-setup


col DB_MODE format a8

@legacy-exclude

--spool resource_plans.txt

prompt
prompt Legacy Plans
prompt

select plan, sub_plan, cpu_method, status from dba_rsrc_plans order by 1;

prompt
prompt CDB Plans
prompt

-- union all used to comment out the second half if not in 12c+db
-- cannot comment out an entire sql line or:
-- SP2-0734: unknown command beginning "&legacy_db..." - rest of line ignored.

select 
	null plan_id
	, null plan
	, null comments
	, null status
	, null mandatory
from dual where 0=1
&legacy_db union all
&legacy_db select plan_id, plan, comments, status, mandatory 
&legacy_db from dba_cdb_rsrc_plans 
order by plan
/

--spool off
