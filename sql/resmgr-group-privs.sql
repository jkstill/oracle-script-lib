
-- resmgr-group-privs.sql
-- consumer group privs

@clears
@resmgr-columns
@resmgr-setup

select grantee, granted_group, grant_option, initial_group
from dba_rsrc_consumer_group_privs
order by 1
/

