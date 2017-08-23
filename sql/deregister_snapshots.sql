

-- deregister_snapshots.sql
-- Why might you need this?
-- If a database is copied/restored to another database,
-- the snapshot/materialized view objects will go along
-- with it, even though they are now totally useless.
-- this is how you get rid of them in the new database.
-- 
-- just modify this script as needed

/* 

use this query to determine site name and snapshot_owner

select
	snapshot_site
	, owner
	, name
from dba_registered_snapshots
order by snapshot_site, owner, name

*/


define site_name='SITE NAME HERE'
define snapshot_owner='SNAP OWNER HERE'

begin

	for drec in (
		select name
		from dba_registered_snapshots
		where snapshot_site = upper('&&site_name')
		-- the owner can be seen in select * from dba_registered_snapshots
		and owner = upper('&&snapshot_owner')
	)
	loop	
		dbms_snapshot.unregister_snapshot('&&snapshot_owner',drec.name,'&&site_name');
	end loop;

end;
/
