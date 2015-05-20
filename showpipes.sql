
@clears
@columns

set line 100

col ownerid format a10 head 'PIPE OWNER'
col name format a30 head 'PIPE NAME'
col type format a10 head 'PIPE TYPE'
col size format 9,999,999 head 'PIPE SIZE'

break on username skip 1

select
	u.username,
	p.name,
	p.type
	--p.size 
from v$db_pipes p, dba_users u
where u.user_id = p.ownerid
order by username, name
/

