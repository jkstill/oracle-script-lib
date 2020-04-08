
-- resmgr-resource-plans.sql
-- resource plans

@clears
@resmgr-columns
@resmgr-setup

--spool resource_plans.txt

select plan, sub_plan, cpu_method, status from dba_rsrc_plans order by 1;

--spool off
