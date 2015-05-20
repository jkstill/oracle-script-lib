
col DBID new_value DBID

select dbid from v$database;

define v_dbid=&&dbid
define database_id=&&dbid


