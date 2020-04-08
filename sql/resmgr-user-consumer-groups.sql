
-- resmgr-user-consumer-groups.sql
-- Default consumer groups for users:

@clears
@resmgr-columns
@resmgr-setup

select username, initial_rsrc_consumer_group from dba_users order by username;

