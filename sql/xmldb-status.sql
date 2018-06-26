
-- xmldb-status.sql


set echo on;
set pagesize 1000
col comp_name format a36
col version format a12
col status format a8
col owner format a12
col object_name format a35
col name format a25

-- Check status of XDB

select comp_name, version, status
from dba_registry
where comp_id = 'XDB';

-- Check for invalid objects

select owner, object_name, object_type, status
from dba_objects
where status = 'INVALID'
and owner in ('SYS', 'XDB');



