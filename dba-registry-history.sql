
-- dba-registry-history.sql

set linesize 200 trimspool on
set pagesize 60
col action_time format a10 head 'ACTION|TIME'
col action format a15
col namespace format a15
col version format a10
col comments format a60

select to_char(action_time,'yyyy-mm-dd') action_time
	, action
	, namespace
	, version
	, comments
from DBA_REGISTRY_HISTORY
order by action_time
/
