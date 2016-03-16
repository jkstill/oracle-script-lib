

col name format a15
col compatibility format a15
col database_compatibility format a15 head 'DATABASE|COMPATIBILITY'
col usable_file_mb format 999,999,999 head 'USABLE|FILE MB'
col required_mirror_free_mb format 999,999,999 head 'REQUIRED MIRROR|FREE MB'

select 
	name
	, state
	, type
	, total_mb
	, free_mb
	, required_mirror_free_mb
	, usable_file_mb
	, compatibility
	, database_compatibility
from v$asm_diskgroup dg
order by name
/


