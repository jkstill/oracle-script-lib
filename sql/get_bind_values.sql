
-- get_bind_values.sql
-- 10g+

col username format a15
col sid format 9999

col datatype_string format a15 head 'DATA TYPE'
col child_nume format 999999 head 'CHILD|NUMBER'
col position format 999 head 'POS'
col name format a20
col value_string format a40

set line 200

col u_sql_id new_value u_sql_id noprint

set term on feed on echo off pause off verify off
prompt Which SQL_ID? :

set term off feed off
select '&1' u_sql_id from dual;
set term on feed on

var v_sql_id varchar2(30)
exec :v_sql_id := '&u_sql_id'

break on inst_id on child_address on child_number on plan_hash_value

with plans as (
   select distinct inst_id, address, sql_id, child_address, child_number, plan_hash_value
   from gv$sql_plan
   where sql_id = :v_sql_id
)
select
   b.inst_id
   , b.child_address
   , b.child_number
   , p.plan_hash_value
   , b.position
   , b.name
   , b.value_string
from GV$SQL_BIND_CAPTURE b
join plans p on p.address = b.address
   and p.inst_id = b.inst_id
   and p.sql_id = b.sql_id
   and p.child_address = b.child_address
   and p.child_number = b.child_number
where b.sql_id = :v_sql_id
order by b.inst_id, b.child_address, b.child_number, b.position
/


undef 1

