
-- csv-split-bind.sql
-- pass a CSV bind variable and split into rows

col owner format a15
col object_name format a60
col object_type format a20

set pagesize 100
set linesize 200 trimspool on

var qualify_bind varchar2(2000)

begin
	:qualify_bind := 'HR,OE';
end;
/

select owner, object_name, object_type
from dba_objects
where owner in (
	select regexp_substr(:qualify_bind ,'[^,]+',1,level)
	from dual
	connect by regexp_substr(:qualify_bind ,'[^,]+',1,level) is not null
)
order by owner, object_name
/
