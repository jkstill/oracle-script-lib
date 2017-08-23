
@clears

set line 200 trimspool on

col db_link format a30 head 'DATA BASE LINK'
col host format a60  head 'HOST'
col username format a10 head 'CONNECTING|USER'
col owner format a10 head 'OWNER'
col created format a20 head 'CREATE DATE'
col password format a10 head 'PASSWORD'


break on owner skip 1

select 
	owner,
	db_link,
	host,
	username,
	to_char(created,'mm/dd/yyyy hh24:mi:ss') created
from dba_db_links
order by owner, db_link
/

