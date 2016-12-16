
-- dba-registry.sql
-- show current components and versions
-- see dba-registry-history.sql for upgrades

set linesize 200 trimspool on
set pagesize 60

col comp_name head 'Component' format a40
col modified format a10 head 'Modified'
col namespace format a15 head 'Namespace'
col version format a15 head 'Version'

select comp_name
	, namespace
	, to_char(to_date(modified,'dd-mon-yyyy hh24:mi:ss'),'yyyy-mm-dd') modified
	, version 
from dba_registry 
order by comp_name, modified
/

