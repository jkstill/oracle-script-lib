
-- dynamic_plan_table.sql
-- Tom Kyte - http://asktom.oracle.com/pls/ask/f?p=4950:8:::::F4950_P8_DISPLAYID:10353453905351
-- 

create or replace view dynamic_plan_table
as
select
	rawtohex(address) || '_' || child_number statement_id,
	sysdate timestamp, operation, options, object_node,
	object_owner, object_name, 0 object_instance,
	optimizer,  search_columns, id, parent_id, position,
	cost, cardinality, bytes, other_tag, partition_start,
	partition_stop, partition_id, other, distribution,
	cpu_cost, io_cost, temp_space, access_predicates,
	filter_predicates
from v$sql_plan
/


create public synonym dynamic_plan_table for sys.dynamic_plan_table;

grant select on dynamic_plan_table to dba;


