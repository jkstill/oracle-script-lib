

set term off verify off feed off

@oversion_minor

col use_12_2_features noprint new_value use_12_2_features

select case when to_number('&v_oversion_minor') >= 12.2 then '' else '--'  end use_12_2_features from dual;
set term on feed on

set linesize 200 trimspool on
set pagesize 100

col name format a15
col compatibility format a15
col database_compatibility format a15 head 'DATABASE|COMPATIBILITY'
col usable_file_mb format 999,999,999 head 'USABLE|FILE MB'
col required_mirror_free_mb format 999,999,999 head 'REQUIRED MIRROR|FREE MB'
col logical_sector_size format 999999 head 'LOGICAL|SECTOR|SIZE'
col sector_size format 999999 head 'SECTOR|SIZE'
col allocation_unit_size format 99,999,999 head 'AU SIZE'
col offline_disks format 99999 head 'OFFLINE|DISK|COUNT#'
col total_mb format 99,999,999 head 'TOTAL MEG'
col free_mb format 99,999,999 head 'FREE MEG'

select
	name
	, state
	, sector_size
	&use_12_2_features , logical_sector_size
	, block_size
	, allocation_unit_size
	, type
	, offline_disks
	, total_mb
	, free_mb
	, required_mirror_free_mb
	, usable_file_mb
	, compatibility
	, database_compatibility
from v$asm_diskgroup dg
order by name
/


