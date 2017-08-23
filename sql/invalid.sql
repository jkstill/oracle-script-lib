

@clears

col owner format a12
col object_type format a15
col object_name format a30

break on owner skip 1 on object_type

col spoolout new_value spoolfile 
set verify off

@title 'Invalid Objects' 70

select owner, object_type, object_name , status
from dba_objects
where status = 'INVALID'
--and (
	-- jkstill - 11/30/2006
	-- comment out this bit - causes problems when
	-- they are really invalid on 9i/10g
	-- this was a problem in 8i
	-- MV always appears as invalid
	-- public synonyms as well - do not know why
	--object_type != 'MATERIALIZED VIEW'
	--and 
	--(
		--owner not in ('PUBLIC') 
		--and object_type not in ('SYNONYM')
	--)
--)
order by owner, object_type, object_name
/


