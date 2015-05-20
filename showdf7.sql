
clear computes
clear breaks
clear columns

set line 132 pagesize 60  heading on

col file_name format a50
col tablespace_name format a10
col bytes format 999,999,999,999

break on tablespace_name skip 1 on report
compute sum of bytes on tablespace_name
compute sum of bytes on report

@@title 'Tablespaces and Data Files' 100


select
	f.tablespace_name,
	f.file_name,
	f.status,
	f.bytes,
	s.maxfree
from dba_data_files f, (
	select
		file_id,
		round(max(bytes/1048576),2) MAXFREE
	from dba_free_space
	group by file_id
)  s
where f.file_id = s.file_id(+)
and f.tablespace_name like '%'
order by tablespace_name, file_name
/

