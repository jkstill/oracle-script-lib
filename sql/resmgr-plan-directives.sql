
-- resmgr-plan-directives.sql
-- plan directives

@clears
@resmgr-columns
@resmgr-setup

select plan, group_or_subplan, type, mgmt_p1, mgmt_p2, mgmt_p3, mgmt_p4, status
from dba_rsrc_plan_directives order by 1,2,3,4,5,6;

