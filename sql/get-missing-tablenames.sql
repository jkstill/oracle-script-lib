

-- get-missing-tablenames.sql
-- given a list of tablenames and a schema, check for the existence of the tables
-- this could be useful when requested export a list of tables
-- if the list has very many entries, plug them in to the sys.odcivarchar2list and run the query
-- the list of tables in this SQL all exist, except for the MAYBE_MISSING table
-- Jared Still

def schema_name='SCHEMA_NAME_HERE'

/*

SQL# @get-missing-tablenames

TABLE_NAME
------------------------------
MAYBE_MISSING

1 row selected.

*/


col table_name format a30
col varchar2_data format a30
col number_data format 99999
col date_data format a22

-- plug in a list of tables
-- plug in a schema name

with tabnames as (
	select rownum id, column_value table_name
	from (
		table(
			sys.odcivarchar2list(
				'ANYDATA_TEST',
				'CONFIG',
				'DUMP_TYPES',
				'GENTEST',
				'MY_OBJECTS',
				'NULL_DATA',
				'MAYBE_MISSING',  -- <<== this table does not exist
				'NULL_TAB_1',
				'NULL_TAB_2',
				'P1',
				'P2',
				'PARTSTEST',
				'STDDEV_TEST',
				'SYS_IMPORT_FULL_01',
				'T',
				'TEMP1',
				'TZ_CONVERT'
			)
		)
	)
),
schema_tables as (
	select table_name
	from dba_tables
	where owner = '&schema_name'
)
select tn.table_name -- , s.table_name
from tabnames tn
left outer join schema_tables s
	on s.table_name = tn.table_name
where s.table_name is null
/



