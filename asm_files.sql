
-- asm_files.sql
-- logon to ASM with sqlplus

col name format a60
set line 200 pagesize 60

select f.file_number, f.bytes, f.modification_date, fn.name
from v$asm_file f
join v$asm_alias fn on fn.file_number = f.file_number
join v$asm_diskgroup dg on f.group_number = f.group_number
order by modification_date asc
/



