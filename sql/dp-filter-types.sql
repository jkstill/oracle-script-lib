
-- dp-filter-types.sh
-- Jared Still 2022
--
-- find the types of filters that may be used by expdp

SET lines 200 pages 20000
COL object_path FOR a60
COL comments FOR a110

-- for database level export/import:
SELECT 'DATABASE' obj_type, named, object_path, comments
  FROM database_export_objects
 WHERE object_path NOT LIKE '%/%'
union all
-- for table schema export/import:
SELECT 'SCHEMA' obj_type, named, object_path, comments
  FROM schema_export_objects
 WHERE object_path NOT LIKE '%/%'
union all
-- for table level export/import:
SELECT 'TABLE' obj_type, named, object_path, comments
  FROM table_export_objects
 WHERE object_path NOT LIKE '%/%'
order by obj_type, object_path
/


