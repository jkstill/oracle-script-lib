
-- asm_files.sql
-- logon to ASM with sqlplus
-- currently shows DATAFILES only
-- does not show aliases for filenames
-- if system_created = 'N' then it is not a datafile
-- not using GV view as datafiles are the same between instances

col bytes format 99,999,999,999
col name format a60
set line 200 pagesize 60

select f.file_number, f.bytes, f.modification_date, fn.name
from v$asm_file f
join v$asm_alias fn on fn.file_number = f.file_number
	and fn.group_number = f.group_number
	and f.type = 'DATAFILE'
	and fn.system_created = 'Y' -- discriminate datafile from alias
join v$asm_diskgroup dg on f.group_number = dg.group_number
order by file_number
/

