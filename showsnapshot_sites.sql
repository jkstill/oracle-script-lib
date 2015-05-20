
-- showsnapshot_sites.sql
-- run from the master site
-- shows databases that have snapshots based on
-- tables/logs in master database

select distinct snapshot_site from dba_registered_snapshots
/

