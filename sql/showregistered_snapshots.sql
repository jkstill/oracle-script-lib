

-- show all registered snapshots at master site
--

set line 100
col snapshot_site format a20
col query_text format a40

select
	snapshot_site
	, owner
	, name
	, can_use_log
	, updatable
	, refresh_method
	--, snapshot_id
	, version
	--, query_text
from dba_registered_snapshots
order by snapshot_site, owner, name
/

