
-- resmgr-plan-directives.sql
-- plan directives

@clears
@resmgr-columns
@resmgr-setup

col DB_MODE format a8

@legacy-exclude

prompt
prompt Legacy DB
prompt 

select 
	plan, group_or_subplan, type, mgmt_p1, mgmt_p2, mgmt_p3, mgmt_p4, status
from dba_rsrc_plan_directives;

prompt
prompt CDB DB
prompt 


select null plan
	, null pluggable_database
	, null shares
	, null utilization_limit
	, null parallel_server_limit
from dual
where 1=2
&legacy_db union all
&legacy_db select plan, pluggable_database, shares, utilization_limit, parallel_server_limit
&legacy_db from dba_cdb_rsrc_plan_directives
order by 1,2;

