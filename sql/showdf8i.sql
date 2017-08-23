
-- showdf8i.sql
-- shows autoextend features
-- displays sizes in meg

clear computes
clear breaks
clear columns

set pagesize 60  heading on 

col file_name format a50
col tablespace_name format a15
col bytes format 999,999.99 head "BYTES|MEG"
col autoextensible format a4 head "AUTO|XTND"
col maxbytes format 999,999.99 head "MAX|BYTES|MEG"
col increment_by format 999,999.99 head "INCR|BYTES|MEG"
col maxfree format 999,999.99 head "MAX|MEG|FREE"

col cblocksize noprint new_value ublocksize
set term off feed off
select value cblocksize
from v$parameter
where name = 'db_block_size';
set term on feed on

break on tablespace_name skip 1 on report
compute sum of bytes on tablespace_name
compute sum of bytes on report
compute sum of maxfree on tablespace_name
compute sum of maxfree on report

@@title 'Tablespaces and Data Files' 140

select
	ts.name tablespace_name,
	f.name file_name,
	f.status,
	round(f.bytes/1048576,2) bytes,
	s.maxfree,
	df.autoextensible,
	round(df.maxbytes/1048576,2) maxbytes,
	round((df.increment_by * &ublocksize) / 1048576,2) increment_by,
	f.file# file_id
from v$datafile f, (
	select
		file_id,
		round(max(bytes/1048576),2) MAXFREE
	from dba_free_space
	group by file_id
)  s,
	v$tablespace ts,
	dba_data_files df
where f.file# = s.file_id(+)
	and f.name like '%'
	and ts.ts# = f.ts#
	and df.file_id = f.file#
	--and df.autoextensible = 'YES'
union all
select
	ts.name tablespace_name,
	t.name file_name,
	t.status,
	round(t.bytes/1048576,2) bytes,
	s.maxfree,
	dt.autoextensible,
	round(dt.maxbytes/1048576,2) maxbytes,
	round((dt.increment_by * &ublocksize) / 1048576,2) increment_by,
	t.file# file_id
from v$tempfile t, (
	select
		file_id,
		round(max(bytes/1048576),2) MAXFREE
	from dba_free_space
	group by file_id
)  s,
	v$tablespace ts,
	dba_temp_files dt
where t.file# = s.file_id(+)
	and t.name like '%'
	and ts.ts# = t.ts#
	and dt.file_id = t.file#
	--and dt.autoextensible = 'YES'
order by tablespace_name, file_id
/

