
-- asm_diskgroup_templates.sql

set linesize 200 pagesize 60

col dg_name format a20 head 'DISK GROUP'
col template_name format a50 head 'TEMPLATE NAME'
col entry_number format 99999 head 'ENTRY|NUMBR'
col redundancy format a6
col stripe format a6
col system format a6 head 'SYSTEM|GEN'
col primary_region format a7 head 'PRIMARY|REGION'
col mirror_region format a7 head 'MIRROR|REGION'

break on dg_name skip 1

select
	dg.name dg_name
	, dt.name template_name
	, dt.entry_number
	, dt.redundancy
	, dt.stripe
	, dt.system
	, dt.name
	, dt.primary_region
	, dt.mirror_region
from v$asm_diskgroup dg
join v$asm_template dt on dt.group_number = dg.group_number
order by dg.name, dt.entry_number
/

