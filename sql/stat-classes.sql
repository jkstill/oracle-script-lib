
-- stat-classes
-- Jared Still 2022

/*

The values represented by v$statname.class

Statistics Descriptions
https://docs.oracle.com/en/database/oracle/oracle-database/21/refrn/statistics-descriptions-2.html#GUID-2FBC1B7E-9123-41DD-8178-96176260A639

*/

col class format 99999
col name format a70
col class_names format a80

set pagesize 100
set linesize 200 trimspool on

with class_values as
-- generate the stat class numbers and names
(
	select
		class_numbers.class#
		, class_names.name
	from
	(
		select rownum id, column_value name
		from (
			table(
				sys.odcivarchar2list(
					'User',
					'Redo',
					'Enqueue',
					'Cache',
					'OS',
					'RAC',
					'SQL',
					'Debug',
					'Instance level'
				)
			)
		)
	) class_names
	,
	(
		select rownum id, column_value class#
		from (
			table(
				sys.odcinumberlist(1,2,4,8,16,32,64,128,256)
			)
		)
	) class_numbers
	where class_numbers.id = class_names.id
),
-- bitmasks of 1-256
bitmask as (
	select 1 bit from dual
	union all
	select power(2,level) bit
	from dual
	connect by level <=15
),
classes as (
	select distinct class from v$statname
)
select
	c.class
	, listagg(v.name,',') within group ( order by b.bit) class_names
from classes c
	join bitmask b
		on bitand(c.class,b.bit) !=0
	join class_values v on v.class# = b.bit
group by class
order by class
/


