
-- rman-recovery-scn.sql
-- determine minimum restore and recover SCN
-- based on what is available in the reccvery catalog
-- works on Legacy and CDB/PDB
-- works for a single PDB
-- not quite there for CDB
-- need to test on Legacy single tenant

set term off feed off
@@oversion_major

col name format a15
col filename format a80

set pagesize 100
set linesize 200 trimspool on

col u_pdb_exclude noprint new_value PDB_EXCLUDE

select 
	case when to_number('&v_oversion_major') >= 12
		then ''
		else '--'
	end u_pdb_exclude
from dual;

set head on term on feed on verify off echo off


with  max_backup_sets as (
	select distinct
		&PDB_EXCLUDE nvl(p.name,'CDB') name
		&PDB_EXCLUDE , 
		f.file#
		, max(dt.bs_key) bs_key
	from v$backup_datafile f
	&PDB_EXCLUDE left outer join v$pdbs p on p.con_id = f.con_id
		--and f.absolute_fuzzy_change# > 0
	join v$datafile df on 
		&PDB_EXCLUDE df.con_id = f.con_id
		&PDB_EXCLUDE and 
		df.file# =  f.file#
	join v$backup_set_details dt
		on dt.set_stamp = f.set_stamp
		--and dt.stamp = f.stamp
		&PDB_EXCLUDE  and dt.con_id = f.con_id
		and dt.incremental_level = f.incremental_level
    &PDB_EXCLUDE where nvl(p.name,'CDB') != 'PDB$SEED' -- exclude default SEED
	group by 
		&PDB_EXCLUDE  p.name, 
		f.file#
),
bkup_data as (
	select distinct
		&PDB_EXCLUDE p.name
		&PDB_EXCLUDE , p.con_id
		&PDB_EXCLUDE , 
		dt.bs_key
		, dt.set_stamp
		, f.file#
		, df.name filename
		, f.checkpoint_change#
		, f.absolute_fuzzy_change#
	from v$backup_datafile f
	&PDB_EXCLUDE join v$pdbs p on p.con_id = f.con_id
		--and f.absolute_fuzzy_change# > 0
	join v$datafile df on 
		&PDB_EXCLUDE df.con_id = f.con_id
		&PDB_EXCLUDE and 
		df.file# =  f.file#
	join v$backup_set_details dt
		on dt.set_stamp = f.set_stamp
		--and dt.stamp = f.stamp
		&PDB_EXCLUDE and dt.con_id = f.con_id
		and dt.incremental_level = f.incremental_level
	join max_backup_sets m on
		&PDB_EXCLUDE m.name = p.name
		&PDB_EXCLUDE and 
		m.bs_key = dt.bs_key
		and m.file# = f.file#
)
,backup_files as (
	select
		&PDB_EXCLUDE bd.name
		&PDB_EXCLUDE , 
		bd.file#
		&PDB_EXCLUDE , bd.name
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
		&PDB_EXCLUDE and bf.con_id = bd.con_id
		and bf.df_file# = bd.file#
	join v$backup_piece p
		on p.set_stamp = bd.set_stamp
	--where bd.name = 'JS1'
	--where bd.name not like 'PDB$SEED'
	order by 
		&PDB_EXCLUDE bd.name, 
		bd.file#
)
select 
	min(checkpoint_change#) min_restore_scn
	, max(absolute_fuzzy_change#) must_recover_beyond
from backup_files
/


