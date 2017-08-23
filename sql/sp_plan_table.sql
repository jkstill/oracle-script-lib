
-- sp_plan_table.sql
-- create a view stats_plan_table
-- for use with dbms_xplan.display and stats$sql_plan

create or replace view stats_plan_table
as 
select
plan_hash_value || '_stats'  statement_id
, id
, operation
, options
, object_node
, object#
, object_owner
, object_name
, object_alias
, object_type
, optimizer
, parent_id
, depth
, position
, search_columns
, cost
, cardinality
, bytes
, other_tag
, partition_start
, partition_stop
, partition_id
, other
, distribution
, cpu_cost
, io_cost
, temp_space
, access_predicates
, filter_predicates
, projection
, time
, qblock_name
, remarks
, snap_id
, 0 object_instance
, sysdate timestamp
, '' other_xml 
, plan_hash_value plan_id
from stats$sql_plan
/

