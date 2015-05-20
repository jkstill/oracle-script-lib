
-- gen_fk_from-11.2.sql
-- for oracle >= 11.2
-- generate fk references from table

with fk as (
	select
		cn.owner
		, cn.table_name
		, cc.constraint_name
		, listagg(cc.column_name,',') within group (order by cc.position) column_list
		, delete_rule
		, deferrable
		, r_owner
		, r_constraint_name
	from dba_constraints cn
	join  dba_cons_columns cc
		on cc.owner = cn.owner
		and cc.constraint_name = cn.constraint_name
		and cc.table_name = cn.table_name
	where cn.owner = 'JKSTILL'
	and cn.table_name = 'CHILD1'
	and cn.constraint_type = 'R'
	group by  cn.owner, cn.table_name, cc.constraint_name,delete_rule, deferrable, r_owner, r_constraint_name
	order by cc.constraint_name
),
refs as (
	select
		cn.owner
		, cn.table_name
		, cc.constraint_name
		, listagg(cc.column_name,',') within group (order by cc.position) column_list
	from dba_constraints cn
	join  dba_cons_columns cc
		on cc.owner = cn.owner
		and cc.constraint_name = cn.constraint_name
		and cc.table_name = cn.table_name
	group by  cn.owner, cn.table_name, cc.constraint_name
	order by cc.constraint_name
)
select
	'alter table ' || fk.table_name
	|| ' add constraint '
	|| substr(fk.constraint_name,1,29) || '2 '
	|| 'foreign key (' || fk.column_list  || ') '
	|| 'references ' || r.table_name || '('
	|| r.column_list || ') '
	|| decode(fk.delete_rule,'CASCADE','ON DELETE CASCADE ','')
	|| fk.deferrable 
from fk
join refs r
on r.owner = fk.r_owner
	and r.constraint_name = fk.r_constraint_name
/
