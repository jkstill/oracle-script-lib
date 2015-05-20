

col constraint_name format a30
col table_name format a30
col constype format a10
set line 110 
set trimspool on

set echo off
set verify off

col cuser noprint new_value uuser
set term on
PROMPT "Show disabled constraints for which user? - ";
set term off feed off
select '&1' cuser from dual;
set term on feed on

@@getdb
ttitle "Disabled Constraints Report For &&_dbname_"
break on owner skip 1 on table_name

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
from dba_constraints
where owner like upper('&&uuser%')
	and status = 'DISABLED'
order by table_name, constraint_name
/

undef 1

