
-- undo_blocks_required.sql
-- calculate the number bytes of UNDO space required
-- to satisfy the undo requirements based on the
-- UNDO_RETENTION paramter (seconds), block size
-- and UNDO block requests per second
-- See ML Note 262066.1

col bytes format 999,999,999,999

with undo_retention as (
	SELECT value AS UR
	FROM v$parameter
	WHERE name = 'undo_retention'
),
undo_blks_per_second as (
	SELECT (SUM(undoblks)/SUM(((end_time - begin_time)*86400))) AS UPS
	FROM v$undostat
),
undo_blk_size as (
	select block_size as DBS
	from dba_tablespaces
	where tablespace_name=(
		select upper(value)
		from v$parameter
		where name = 'undo_tablespace'
	)
)
SELECT (ur.ur * ups.ups * ubs.DBS) + (ubs.DBS * 24) AS "Bytes"
FROM undo_retention ur,
	undo_blks_per_second ups,
	undo_blk_size ubs
/
