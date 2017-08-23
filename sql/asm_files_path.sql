-- asm_files_path.sql
-- from Oracle Note 470211.1

--spool asm<#>_full_path_alias_directory.html
-- ASM Versions 10.1, 10.2, 11.1  & 11.2

--SET MARKUP HTML ON
--set echo on

set pagesize 200 linesize 200
alter session set nls_date_format='YYYY-MM-DD HH24:MI:SS';

col full_path format a80
col db format a15

--select 'THIS ASM REPORT WAS GENERATED AT: ==)> ' , sysdate " "	from dual;

--select 'HOSTNAME ASSOCIATED WITH THIS ASM INSTANCE: ==)> ' , MACHINE " " from v$session where program like '%SMON%';

select
	substr(full_path,instr(full_path,'/')+1,instr(full_path,'/',1,2) - instr(full_path,'/',1,1) -1) db
	, full_path
	, system_created
	, alias_directory
	--, file_type
	, modification_date
from (
select
	concat('+'||gname, sys_connect_by_path(aname, '/')) full_path
	, system_created
	, alias_directory
	, file_type
	, modification_date
from
(
	select
		b.name gname
		, a.parent_index pindex
		, a.name aname
		, a.reference_index rindex
		, a.system_created, a.alias_directory
		, c.type file_type
		, c.modification_date
	from v$asm_alias a, v$asm_diskgroup b, v$asm_file c
	where a.group_number = b.group_number
	and a.group_number = c.group_number(+)
	and a.file_number = c.file_number(+)
	and a.file_incarnation = c.incarnation(+)
)
start with (mod(pindex, power(2, 24))) = 0
connect by prior rindex = pindex
)
where file_type = 'DATAFILE'
order by modification_date
/


--spool off

