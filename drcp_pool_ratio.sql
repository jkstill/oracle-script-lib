
prompt
prompt higher number is better
prompt

select num_requests / (select count(*) from (select distinct cclass_name from V$CPOOL_CC_STATS)) connections_per_pool
from V$CPOOL_STATS
/
