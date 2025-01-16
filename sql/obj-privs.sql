
-- Jared Still 2022
-- jkstill@gmail.com

/*

usage: @obj-privs <object-type> <object-name>

object-type can be any type of object; table, directory, index, etc.
case does not matter

object-name can be any legal name - case matters

Wild cards work for both object-type and object-name


@obj-privs dir% MYDIR
@obj-privs table INV%
@obj-privs synonym %


*/


set pagesize 100
set linesize 200 trimspool off

col grantor format a15
col grantee format a30
col table_schema format a30 head 'OWNER'
col table_name format a30 head 'OBJECT_NAME'
col privilege format a15

col  v_object_name new_value v_object_name noprint
col  v_object_type new_value v_object_type noprint

set feed off term off echo off pause off verify off
select upper('&1') v_object_type from dual;
select '&2' v_object_name from dual;

set feed on term on feed on


select
	p.table_name
	, p.table_schema
	, p.privilege
	, p.grantee
	, p.grantor
	, o.object_type
from all_tab_privs p
join all_objects o on o.owner = p.table_schema
	and o.object_name = p.table_name
	and p.table_name like '&v_object_name'
	and o.object_type like '&v_object_type'
order by p.table_name, p.table_schema, p.grantee
/


