-- asm_diskgroup_attributes.sql

set linesize 200 pagesize 60

col dg_name format a20 head 'DISK GROUP'
col attrib_name format a50 head 'ATTRIB NAME'
col attrib_value format a50 head 'ATTRIB VALUE'
col attrib_index format 99999 head 'ATTRIB|INDEX'
col attrib_incarnation format 99999 head 'INCAR'
col read_only format a7 head 'READ|ONLY'
col system_created format a7 head 'SYSTEM|CREATED'

break on name skip 1

select
	dg.name dg_name
	, da.name attrib_name
	, da.value attrib_value
	, da.attribute_index attrib_index
	, da.attribute_incarnation attrib_incarnation
	, da.read_only
	, da.system_created
from v$asm_diskgroup dg
join v$asm_attribute da on da.group_number = dg.group_number
order by dg.name, da.name
/
