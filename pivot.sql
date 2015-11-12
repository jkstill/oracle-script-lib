with data as (
	select 'A' id, level rid
	from dual
	connect by level <= 10
	union all
	select 'B' id, level rid
	from dual
	connect by level <= 10
)
select  a,b
from data
pivot (
	count(rid)
	for id in (
		'A' as A
		, 'B' as B
	)
)
/
