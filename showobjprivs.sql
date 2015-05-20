
@@clears
@columns
col owner_name format a10 head 'OWNER'
col grantor format a10 head 'GRANTOR'
col grantee format a15 head 'GRANTEE'
col object_name format a25 head 'OBJECT_NAME'
col privname format a10 head 'PRIVILEGE'

col cowner new_value uowner noprint
prompt owner/object name:
set term off feed off 
select '&1' cowner from dual;
set term on feed on

clear break
break on owner_name skip 1 on object_name

select
	owner.name owner_name,
	object.name object_name,
	--grantor.name grantor,
	grantee.name grantee,
	tpm.name privname
from 
	sys.user$ grantee,
	--sys.user$ grantor,
	sys.user$ owner,
	sys.obj$ object, 
	sys.objauth$ auth, 
	table_privilege_map tpm
where 
	--owner.name = 'CAP'
	--tpm.name = 'EXECUTE'
	--and
	--grantor.user# = auth.grantor#
	--and
	grantee.user# = auth.grantee#
	and owner.user# = object.owner#
	and object.obj# = auth.obj#
	and tpm.privilege = auth.privilege#
	and
	(  
		owner.name like upper('&&uowner%')  
		or object.name like upper('&uowner%') 
		or grantee.name like upper('&uowner%') 
	)
order by
	owner.name,
	object.name,
	--grantor.name,
	grantee.name,
	tpm.privilege
/
	


undef 1 2



