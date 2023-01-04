


-- oracle-data-types.sql
-- Jared Still 
-- jkstill at gmail.com
-- use the sys.odci*list data types
-- requires 10g+
-- similar to data found in OH/rdbms/admin/cdobj.sql, dbmsany.sql, dbmstf.sql

col data_type_name format a60 head 'DATA TYPE'
col data_type_id format 99999 head 'DATA|TYPE|ID'

set pagesize 100
set linesize 200 trimspool on

with data_types as
(
	select rownum id, column_value data_type_name 
	from (
		table(
			sys.odcivarchar2list(
				'NULL'
				, 'VARCHAR2'
				, 'NUMBER'
				, 'NATIVE INTEGER'
				, 'LONG'
				, 'VARCHAR'
				, 'ROWID'
				, 'DATE'
				, 'RAW'
				, 'LONG RAW'
				, 'BINARY_INTEGER'
				, 'ROWID'
				, 'CHAR'
				, 'BINARY_FLOAT'
				, 'BINARY_DOUBLE'
				, 'REF CURSOR'
				, 'UROWID'
				, 'MLSLABEL'
				, 'MLSLABEL'
				, 'REF'
				, 'REF'
				, 'CLOB'
				, 'BLOB'
				, 'BFILE'
				, 'CFILE'
				, 'OBJECT'
				, 'TABLE'
				, 'VARRAY'
				, 'TIME'
				, 'TIME WITH TIME ZONE'
				, 'TIMESTAMP'
				, 'TIMESTAMP WITH TIME ZONE'
				, 'TIMESTAMP WITH LOCAL TIME ZONE'
				, 'INTERVAL YEAR TO MONTH'
				, 'INTERVAL DAY TO SECOND'
				, 'INTERVAL DAY TO SECOND: AnyData - dbms_types package'
				, 'PL/SQL RECORD'
				, 'PL/SQL TABLE'
				, 'PL/SQL BOOLEAN'
			)
		)
	)
),
data_type_id as 
(
	select rownum id, column_value data_type_id 
	from (
		table(
			sys.odcinumberlist(
				0
				, 1
				, 2
				, 3
				, 8
				, 9
				, 11
				, 12
				, 23
				, 24
				, 29
				, 69
				, 96
				, 100
				, 101
				, 102
				, 104
				, 105
				, 106
				, 110
				, 111
				, 112
				, 113
				, 114
				, 115
				, 121
				, 122
				, 123
				, 178
				, 179
				, 180
				, 181
				, 231
				, 182
				, 183
				, 190
				, 250
				, 251
				, 252
			)
		)
	)
)
select i.data_type_id, t.data_type_name
from data_types t, data_type_id i
where i.id = t.id
order by i.data_type_id
/








