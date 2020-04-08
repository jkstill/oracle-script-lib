
-- resmgr-consumer-groups.sql
-- consumer groups

@clears
@resmgr-columns
@resmgr-setup

select consumer_group,cpu_method, status from dba_rsrc_consumer_groups order by 1;

