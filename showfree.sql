-- showfree.sql
-- show all free space

col tbs format a15
col fid format 999999
col bid format 999999
col MEG format 99999.99
col blocks format 9999999

clear break
clear compute

break on tbs skip 1 on report 
compute sum of MEG on tbs
compute sum of MEG on report

@@title80 'Show All Free Space'
--ttitle center 'All Free Space' right 'Page ' SQL.PNO skip 2
--btitle right 'showfree.sql' 

select 
	tablespace_name tbs,
	file_id fid,
	block_id bid,
	(bytes/1048576) MEG,
	blocks
from dba_free_space
where tablespace_name like '%'
order by tbs,meg desc,fid,bid

/

btitle off


