
@clears
@columns


col ctabowner noprint new_value utabowner
prompt Table Owner:
set term off feed off
select upper('&1') ctabowner from dual;
set term on feed on

@title 'Table Analyzed Dates' 80

break on owner skip 1
col last_analyzed head 'DATE ANALYZED' format a20

select 
	c.owner,
	table_name,
	nvl(to_char(last_analyzed,'mm/dd/yyyy hh24:mi:ss'),'NOT ANALYZED') last_analyzed
from all_tab_columns c, all_objects o
where c.owner like '&&utabowner%'
	and o.owner = c.owner
	and o.object_name = c.table_name
	and o.object_type = 'TABLE'
	and c.column_id = 1
order by owner, table_name
/

undef 1

