
-- asm_failgroup_members.sql

set pagesize 100
col diskgroup format a10
col failgroup format a10
col group_members format a30

select
	g.name diskgroup
	, d.failgroup
   , listagg(disk_number, ',') within group (order by d.failgroup, d.disk_number) group_members
from v$asm_disk d
join v$asm_diskgroup g on g.group_number = d.group_number
group by g.name, d.failgroup
/
