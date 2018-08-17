
-- rman-recovery-scn.sql
-- determine minimum restore and recover SCN
-- based on what is available in the reccvery catalog
-- works for a single PDB
-- not quite there for CDB
-- need to test on Legacy single tenant

col name format a15
col filename format a80

set pagesize 100
set linesize 200 trimspool on


with  max_backup_sets as (
	select distinct
		p.name
		, f.file#
		, max(dt.bs_key) bs_key
	from v$backup_datafile f
	join v$pdbs p on p.con_id = f.con_id
		--and f.absolute_fuzzy_change# > 0
	join v$datafile df on df.con_id = f.con_id
		and df.file# =  f.file#
	join v$backup_set_details dt
		on dt.set_stamp = f.set_stamp
		--and dt.stamp = f.stamp
		and dt.con_id = f.con_id
		and dt.incremental_level = f.incremental_level
	group by p.name, f.file#
),
bkup_data as (
	select distinct
		p.name
		, p.con_id
		, dt.bs_key
		, dt.set_stamp
		, f.file#
		, df.name filename
		, f.checkpoint_change#
		, f.absolute_fuzzy_change#
	from v$backup_datafile f
	join v$pdbs p on p.con_id = f.con_id
		--and f.absolute_fuzzy_change# > 0
	join v$datafile df on df.con_id = f.con_id
		and df.file# =  f.file#
	join v$backup_set_details dt
		on dt.set_stamp = f.set_stamp
		--and dt.stamp = f.stamp
		and dt.con_id = f.con_id
		and dt.incremental_level = f.incremental_level
	join max_backup_sets m
		on m.name = p.name
		and m.bs_key = dt.bs_key
		and m.file# = f.file#
)
,backup_files as (
	select
		bd.name
		, bd.file#
		, bd.name
		, bf.bs_tag
		, bd.filename
		, bd.bs_key
		, p.handle backup_file
		, bd.checkpoint_change#
		, bd.absolute_fuzzy_change#
	from bkup_data bd
	join v$backup_files bf
		on bf.bs_key = bd.bs_key
		and bf.bs_stamp = bd.set_stamp
		and bf.con_id = bd.con_id
		and bf.df_file# = bd.file#
	join v$backup_piece p
		on p.set_stamp = bd.set_stamp
	--where bd.name = 'JS1'
	where bd.name not like 'PDB$SEED'
	order by bd.name, bd.file#
)
select 
	min(checkpoint_change#) min_restore_scn
	, max(absolute_fuzzy_change#) must_recover_beyond
from backup_files
/


