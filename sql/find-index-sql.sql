
-- find-index-sql.sql
-- find SQL where an index has been used
-- parameters currently hardcoded
-- Jared Still  jkstill@gmail.com
-- 2017-11-01

def v_index_owner='SCOTT'
def v_index_name='EMP_PK'

var b_index_owner varchar2(30)
var b_index_name varchar2(30)

begin
   :b_index_owner := '&&v_index_owner';
   :b_index_name := '&&v_index_name';
end;
/

with live_plans as (
   select distinct sql_id, plan_hash_value
   from gv$sql_plan
   where object_type = 'INDEX'
      and object_owner = :b_index_owner
      and object_name = :b_index_name
),
hist_plans as (
   select distinct sql_id, plan_hash_value
   from dba_hist_sql_plan
   where object_type = 'INDEX'
      and object_owner = :b_index_owner
      and object_name = :b_index_name
),
all_plans as (
   select distinct sql_id, plan_hash_value
   from (
      select sql_id, plan_hash_value
      from live_plans
      union
      select sql_id, plan_hash_value
      from hist_plans
   )
)
select sql_id, plan_hash_value
from all_plans
/

