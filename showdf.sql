
-- showdf.sql
-- get from dba_data_files and dba_temp_files rather that v$ views
-- jkstill - 10/29/2008 - changed method of getting free TEMP space
--   it was incorrect.  currently still a compromise, but more correct
--   added pct_capacity
-- jkstill - 10/29/2008
-- 2 calculations had '/' on a line by itself
-- works in 9i, but not in 10g.

clear computes
clear breaks
clear columns

col status format a4 head 'STAT'
col file_name format a50
col tablespace_name format a10
col bytes format 9,999,999,999 head 'BYTES|(MEG)'
col maxbytes format 9,999,999,999 head 'MAX BYTES|(MEG)'
col maxfree format 99,999 head 'FREE SIZE|MAX MEG'
col totfree format 999,999,999,999 head 'FREE SPACE|TOTAL MEG'
col next_size format 99,999 head 'NEXT SIZE|MEG'
col autoextensible format a4 head 'AUTO|XTND'
col file_id format 99999 head 'FILE ID'
col relative_fno format 99999 head 'REL FNO'
col pct_capacity format 999.99 head 'PCT|FULL'
col tot_space_growth format 99,999,999 head 'TOTAL SPACE|FOR GROWTH'

break on tablespace_name skip 1 on report
compute sum of bytes on tablespace_name
compute sum of bytes on report
compute sum of maxbytes on tablespace_name
compute sum of maxbytes on report
compute sum of maxfree on tablespace_name
compute sum of maxfree on report
compute sum of totfree on tablespace_name
compute sum of totfree on report
compute sum of tot_space_growth on tablespace_name
compute sum of tot_space_growth on report

@@title 'Tablespaces and Data Files' 180

with tempfree as (
	select 
		file_id
		, relative_fno
		-- total and max free are the same for temp files
		, round(sum(bytes_free/1048576),2) TOTFREE
		, round(sum(bytes_free/1048576),2) MAXFREE
	from (
		select file_id
			, bytes_free
			, relative_fno
		from (
			select
				f.file_id
				, relative_fno
				, nvl(tu.blocks,0) * t.block_size bytes_used
				, (select bytes from dba_temp_files where file_id = f.file_id) bytes
				, (select bytes from dba_temp_files where file_id = f.file_id) - (nvl(tu.blocks,0) * t.block_size) bytes_free
			from  (
				select segrfno#, sum(tu.blocks) blocks
				from v$tempseg_usage tu
				group by segrfno#
			) tu
				right outer join dba_temp_files f on f.file_id = tu.segrfno#
				left outer join dba_tablespaces t on t.tablespace_name = f.tablespace_name
		)
	)
	group by file_id, relative_fno
),
df as (
	select
		f.tablespace_name,
		f.file_id,
		f.relative_fno,
		f.file_name,
		substr(f.status,1,4) status,
		f.bytes/1048576 bytes,
		--s.maxfree,
		s.totfree,
		f.autoextensible,
		(f.increment_by * t.block_size)/1048576 next_size,
		decode(f.autoextensible,'NO',f.bytes,f.maxbytes)/1048576 maxbytes,
			-- total space used
			-- total space available, including autoextend if available
			(((f.bytes/1048576)-nvl(s.totfree,0)))  / 
			(decode(f.maxbytes,0,f.bytes-s.totfree,f.maxbytes)/1048576) * 100 
		pct_capacity
		--f.file_id
	from dba_data_files f, (
		select
			file_id,
			relative_fno,
			round(sum(bytes/1048576),2) TOTFREE,
			round(max(bytes/1048576),2) MAXFREE
		from dba_free_space
		group by file_id, relative_fno
	)  s,
	dba_tablespaces t
	where f.file_id = s.file_id(+)
	and t.tablespace_name = f.tablespace_name
	and f.tablespace_name like '%'
), 
tf as (
	select
		f.tablespace_name,
		f.file_id,
		f.relative_fno,
		f.file_name,
		substr(f.status,1,4) status,
		f.bytes/1048576 bytes,
		--s.maxfree,
		s.totfree,
		f.autoextensible,
		(f.increment_by * t.block_size)/1048576 next_size,
		decode(f.autoextensible,'NO',f.bytes,f.maxbytes)/1048576 maxbytes,
			-- total space used
			-- total space available, including autoextend if available
			(((f.bytes/1048576)-nvl(s.totfree,0)))  / 
			(decode(f.maxbytes,0,f.bytes-s.totfree,f.maxbytes)/1048576) * 100 
		pct_capacity
		--f.file_id
	from dba_temp_files f
		,tempfree s
		,dba_tablespaces t
	where f.file_id = s.file_id(+)
	and t.tablespace_name = f.tablespace_name
	and f.tablespace_name like '%'
)
select
	tf.tablespace_name
	, tf.file_id
	, tf.relative_fno
	, tf.file_name
	, tf.status
	, tf.bytes
	, tf.totfree
	, tf.autoextensible
	, tf.next_size
	, tf.maxbytes
	, tf.maxbytes - tf.bytes + tf.totfree tot_space_growth
	, tf.pct_capacity
from tf
union all
select
	df.tablespace_name
	, df.file_id
	, df.relative_fno
	, df.file_name
	, df.status
	, df.bytes
	, df.totfree
	, df.autoextensible
	, df.next_size
	, df.maxbytes
	, df.maxbytes - df.bytes + df.totfree tot_space_growth
	, df.pct_capacity
from df
order by 1,2
/

