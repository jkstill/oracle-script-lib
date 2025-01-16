
-- stat-names.sql
-- Jared Still 2022

set linesize 200 trimspool on
set pagesize 100
col class format 99999
col name format a70
col class_names format a80

with class_values as
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
bitmask as (
	select 1 bit from dual
	union all
	select power(2,level) bit
	from dual
	connect by level <=15
), 
classes as (
	select class, stat_id, name
	from v$statname 
)
select 
	c.class
	, c.stat_id
	, c.name
	, listagg(v.name,',') within group ( order by b.bit) class_names
from classes c
	join bitmask b 
		on bitand(c.class,b.bit) !=0 
	join class_values v on v.class# = b.bit
where c.name like '%'
group by c.class,c.stat_id,c.name
order by class_names,c.name
/

