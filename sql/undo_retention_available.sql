-- undo_retention_available.sql
-- calculate how long undo retention should be good for
-- based on the the bytes available in the UNDO tablespace
-- block size and UNDO block requests per second
-- this is a modification of the query in the oracle note
-- See ML Note 262066.1

-- UndoSpace = (UR * UPS * DBS) + (DBS * 24)
-- UndoRetention = ( UndoSpace - ( DBS * 24 )) / ( UPS * DBS )
--
-- testing however shows this estimate to be overly optimistic
-- testing with this query 
-- select count(*) from dba_tables as of TIMESTAMP (SYSTIMESTAMP - INTERVAL '20' hour)
-- shows the actual available undo is very close to undo_retention, which in this case as 64800
-- the und0_retention was set to 64800 (18 hrs) , and the query would work at up to 20 hrs

col retention_seconds format 999,999,999,999

with undo_tbs as (
		select upper(value) undo_tablespace
		from v$parameter
		where name = 'undo_tablespace'
),
undo_bytes as (
	select
		sum( decode(f.autoextensible,'YES',f.maxbytes,f.bytes )) undo_bytes
	from dba_data_files f
	join undo_tbs ut on f.tablespace_name = ut.undo_tablespace
),
undo_blks_per_second as (
	SELECT (SUM(undoblks)/SUM(((end_time - begin_time)*86400))) AS UPS
	FROM v$undostat
),
undo_blk_size as (
	select dt.block_size as DBS
	from dba_tablespaces dt
	join undo_tbs ut on dt.tablespace_name = ut.undo_tablespace
)
select ( ub.undo_bytes - (ubs.DBS * 24)) / (ups.ups * ubs.DBS) retention_seconds
FROM undo_blks_per_second ups,
	undo_blk_size ubs,
	undo_bytes ub
/
