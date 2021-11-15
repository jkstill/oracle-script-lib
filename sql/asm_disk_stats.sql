
-- asm_disk_stats.sql
-- 2016-05-17
-- Jared Still -  jkstill@gmail.com


set term off feed off verify off
@oversion_major.sql

col v_timeouts_available new_value v_timeouts_available noprint

select
case 
   when '&v_oversion_major' >= 12 
		then ''
   else '--'
end v_timeouts_available
from dual;

set term on feed on

set linesize 200 trimspool on

col inst_id head 'I#' format 99
col path format a80
col diskgroup_name format a10
col disk_name format a15
col disk_number head 'D#' format 999
col avg_read_time head 'AVG|READ|MS' format 9999.99
col avg_write_time head 'AVG|WRITE|MS' format 9999.99
col write_timeout head 'WRITE|TIMEOUTS' format 999999
col read_timeout head 'READ|TIMEOUTS' format 999999

with iostats as (
select 
	io.inst_id
	, dg.name diskgroup_name
	, io.disk_number
	, d.name disk_name
	--, d.label
	, d.read_time / d.reads * 1000 avg_read_time
	, d.write_time / d.writes * 1000 avg_write_time
	&v_timeouts_available, d.read_timeout -- 12c+ only
	&v_timeouts_available, d.write_timeout -- 12c+ only
	, d.path
from gv$ASM_DISK_IOSTAT io
	join gv$asm_diskgroup dg on dg.inst_id = io.inst_id
		and dg.group_number = io.group_number
	join gv$asm_disk d on d.inst_id = io.inst_id
		and d.group_number = io.group_number
)
select *
from iostats
order by avg_read_time + avg_write_time
/


