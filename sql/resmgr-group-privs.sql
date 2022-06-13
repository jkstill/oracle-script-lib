
-- resmgr-group-privs.sql
-- consumer group privs

@clears
@resmgr-columns
@resmgr-setup

col DB_MODE format a8

@legacy-exclude

select 
	&legacy_db 'LEGACY' db_mode, 
	grantee, granted_group, grant_option, initial_group
from dba_rsrc_consumer_group_privs
&legacy_db union all
&legacy_db select 'CDB' db_mode, grantee, granted_group, grant_option, initial_group
&legacy_db from cdb_rsrc_consumer_group_privs
order by 1,2
/

