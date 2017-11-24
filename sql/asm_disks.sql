

clear break
set linesize 200 pagesize 60

col path format a60
col name format a15
col compatibility format a15
col database_compatibility format a15 head 'DATABASE|COMPATIBILITY'
col usable_file_mb format 999,999,999 head 'USABLE|FILE MB'
col required_mirror_free_mb format 999,999,999 head 'REQUIRED MIRROR|FREE MB'
col failgroup_type format a10 head 'FAILGROUP|TYPE'
col voting_file format a4 head 'VOTE|DISK'
col failgroup format a15
col dg_state format a12
col dsk_state format a10


select
	dg.name
	, dg.con_id
	, d.total_mb
	, d.free_mb
	, dg.state dg_state
	, d.state dsk_state
	, dg.type
	, d.failgroup
	, d.failgroup_type
	, d.voting_file
	, d.name
	, d.path
from v$asm_diskgroup dg
join v$asm_disk d on d.group_number = dg.group_number
order by dg.name, d.name
/

