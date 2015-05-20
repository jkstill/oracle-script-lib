
-- gen_fk_from-11.1.sql
-- for oracle <= 11.1
-- generate fk references from table


with cols as (
	select owner,table_name, constraint_name,
		substr(max(sys_connect_by_path(column_name, ',' )),2) column_list
		from (
			select c.owner,c.table_name, c.constraint_name, cc.column_name,
			row_number() over (partition by c.constraint_name order by cc.position) rn
			from dba_constraints c
			join dba_cons_columns cc on cc.table_name = c.table_name
				and cc.constraint_name = c.constraint_name
		)
	start with rn = 1
	connect by prior rn = rn-1 and prior constraint_name = constraint_name
	group by owner,table_name, constraint_name
),
fk as (
	select
		cn.owner
		, cn.table_name
		, cc.constraint_name
		-- listagg available in 11.2+
		--, listagg(cc.column_name,',') within group (order by cc.position) column_list
		, cols.column_list
		, delete_rule
		, deferrable
		, r_owner
		, r_constraint_name
	from dba_constraints cn
	join  dba_cons_columns cc
		on cc.owner = cn.owner
		and cc.constraint_name = cn.constraint_name
		and cc.table_name = cn.table_name
	join cols on cols.owner = cn.owner
		and cols.table_name = cn.table_name
		and cols.constraint_name = cc.constraint_name
	where cn.owner = 'JKSTILL'
	and cn.table_name = 'CHILD1'
	and cn.constraint_type = 'R'
	group by  cn.owner, cn.table_name, cc.constraint_name,column_list,delete_rule, deferrable, r_owner, r_constraint_name
	order by cc.constraint_name
),
refs as (
	select
		cn.owner
		, cn.table_name
		, cn.constraint_name
		-- listagg available in 11.2+
		--, listagg(cc.column_name,',') within group (order by cc.position) column_list
		, cols.column_list
	from dba_constraints cn
	join cols on cols.owner = cn.owner
		and cols.table_name = cn.table_name
		and cols.constraint_name = cn.constraint_name
	group by  cn.owner, cn.table_name, cn.constraint_name, cols.column_list
	order by cn.constraint_name
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
