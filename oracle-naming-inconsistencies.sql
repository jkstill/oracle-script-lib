
-- oracle-naming-inconsistencies.sql
-- highlight some of the inconsistencies oracle data dictionary column names
-- names with underscores vs exact same name without underscores

with underscores as (
	select distinct column_name u1, replace(column_name,'_','') u2
	from dba_tab_columns
	where owner = 'SYS'
	and column_name like '%\_%' escape '\'
),
no_underscores as (
	select distinct column_name n1
	from dba_tab_columns
	where owner = 'SYS'
	and column_name not like '%\_%' escape '\'
)
select u.u1, u.u2, n.n1
from underscores u
join no_underscores n on n.n1 = u.u2
order by u.u1
/

