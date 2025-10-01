
-- asm-diskgroup-stat.sql
-- Show same output as 'asmcmd lsdg' command

@clears

set linesize 200 trimspool off
set pagesize 100
set feed on
set echo off pause off

col name                    format a20 head 'Name'
col sector_size             format 99999 head 'Sector|Size'
col logical_sector_size     format 99999 head 'Logical|Sector|Size'
col block_size              format 99999 head 'Block|Size'
col state                   format a15 head 'State'
col type                    format a10 head 'Diskgroup|Type'
col total_mb                format 99,999,999,999 head 'Total Mb'
col free_mb                 format 99,999,999,999 head 'Free Mb'
col usable_file_mb          format 99,999,999,999 head 'Usable|File Mb'
col database_compatibility  format a20 head 'DB Compatibiity'

select
   name
   , sector_size
   , logical_sector_size
   , block_size
   , state
   , type
   , total_mb
   , free_mb
   , usable_file_mb
   , database_compatibility
from v$asm_diskgroup_stat
order by name
/

