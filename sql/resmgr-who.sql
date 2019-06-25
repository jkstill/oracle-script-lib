
-- resmgr-who.sql

@clears
@resmgr-columns
@resmgr-setup

select sid,serial#,username,resource_consumer_group from v$session
/
