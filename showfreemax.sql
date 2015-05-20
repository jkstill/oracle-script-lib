-- showmaxfree.sql
-- shows max contigous free space from each tablespace/file

@clears

col tbs format a15
col fid format 999999
col space_free_meg format 9999999.99 head 'FREE|MEG'
col file_size_meg format 99999.99 head 'FILE|MEG'
col file_name format a40 head 'DATA FILE'

@title 'Show Max Free Space' 90

break on tbs skip 1 on report

compute sum of space_free_meg on tbs
compute sum of space_free_meg on report


select tbs, file_name, space_free_meg, file_size_meg
from  (
	select
		f.tablespace_name tbs,
		f.file_name,
		max((s.bytes/1048576)) space_free_meg,
		max((f.bytes/1048576)) file_size_meg
	from dba_free_space s, dba_data_files f
	where s.file_id(+) = f.file_id
	group by f.tablespace_name, file_name
) a
order by tbs, file_name
/



