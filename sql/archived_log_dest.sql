
@clears

set linesize 150
set pagesize 60

col dest_name format a30
col destination format a60

select dest_name, status , target, archiver, schedule, destination
from  V$ARCHIVE_DEST
where status != 'INACTIVE'
order by dest_name
/


