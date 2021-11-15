
-- asm_disk_errors.sql
-- 2016-05-17
-- Jared Still -  jkstill@gmail.com

set linesize 200 trimspool on

col inst_id head 'I#' format 99
col path format a80
col diskgroup_name format a10
col disk_name format a15
col disk_number head 'D#' format 999

select 
	io.inst_id
	, dg.name diskgroup_name
	, io.disk_number
	, d.name disk_name
	--, d.label
	, d.read_errs
	, d.write_errs
	, d.path
from gv$ASM_DISK_IOSTAT io
	join gv$asm_diskgroup dg on dg.inst_id = io.inst_id
		and dg.group_number = io.group_number
	join gv$asm_disk d on d.inst_id = io.inst_id
		and d.group_number = io.group_number
-- use the where clause if too many rows
--where d.read_errs + d.write_errs > 0
/
