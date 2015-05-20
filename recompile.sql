-- recompile.sql
-- brute force recompile
-- may need to run more than once due to dependencies

@clear_for_spool

spool ./_recompile.sql
prompt set echo on
prompt spool _recompile.log

select 
	'alter '
		|| decode(object_type, 
			'PACKAGE BODY','PACKAGE',
			'TYPE BODY','TYPE',
			object_type
		) || ' '
		|| owner || '.' || '"' || object_name || '"'  || ' compile '
		|| decode(object_type, 
			'PACKAGE BODY','body;',
			'TYPE BODY','body;',
			';'
		)
	,'show error ' 
		|| object_type || ' '
		|| owner || '.' 
		|| object_name 
from dba_objects
where object_type in ('FUNCTION','PACKAGE','PROCEDURE','VIEW','TRIGGER','PACKAGE BODY','TYPE','TYPE BODY','INDEXTYPE')
and status = 'INVALID'
--and owner not in ('SYS','SYSTEM')
order by owner,
	decode(object_type,
		'VIEW', 1,
		'PACKAGE', 2,
		'PACKAGE BODY', 3,
		'PROCEDURE', 4,
		'FUNCTION', 5,
		'TRIGGER', 6,
		9
	)

/

prompt spool off
prompt set echo off
spool off

@clears

@@./_recompile

