
-- object-types.sql
-- Description: This script will list all the object types in the database.

column object_type format a30
column type# format 999999
column object_type format a30

set linesize 200 trimspool on
set pagesize 100

set feedback on term on verify off echo off

select distinct o.type#, b.object_type
from sys.obj$ o, dba_objects b
where b.object_id = o.obj#
order by 1
/

