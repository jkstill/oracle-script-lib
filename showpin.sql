
-- show objects that are pinned in the shared pool

col owner format a10
col name format a30
col type format a15
col memory format 999.99  heading "MEGS"
col kept noprint

	
@@title80 'Objects That Are Pinned In Shared Pool'

break on owner skip 1
compute sum of memory on owner report

select owner,
	name,
	type,
	(sharable_mem / 1048576) memory,
	kept
from v$db_object_cache
where kept = 'YES'
order by owner,name,type

spool $HOME/tmp/&dbname/showpin.txt
/
spool off

--@@sel_exit 'dummy'

