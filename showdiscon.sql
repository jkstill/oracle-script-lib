
@clears

col constraint_name format a30
col table_name format a30
col constype format a10
col owner format a15 head 'OWNER'

set line 100

set echo off
set verify off

col cowner new_value uowner noprint
prompt
prompt Show disabled constraints for which user? 
prompt ( partial names ok )
prompt
set feed off term off
select '&1' cowner from dual;
set term on feed on


break on owner skip 1 on table_name skip 1

select	
	owner,
	table_name ,
constraint_name,
decode(constraint_type,
	'C','CHECK',
	'P','PRIMARY',
	'U','UNIQUE',
	'R','REFERENCE',
	'V','VIEW/CHK',
	'!ERR!'
	) constype
from all_constraints
where owner like upper('%&uowner%')
	and status = 'DISABLED'
order by owner, table_name, constraint_name
/


undef 1

