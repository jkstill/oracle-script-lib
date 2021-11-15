
-- drcp_connection_monitor.sql
-- Jared Still 
-- 

var n_cpool_pct_threshold number

exec :n_cpool_pct_threshold := 85

with max_pools as (
	select maxsize max_pool_count from DBA_CPOOL_INFO
),
conn_info as (
	select distinct inst_id
		, count(*)  over (partition by inst_id) drcp_connection_count -- includes waiting, active, idle, etc
	from GV$CPOOL_CONN_INFO
	where connection_status not in ('NONE','IDLE')
	--where connection_status not in ('WAITING')
	--order by inst_id
),
cpool_used as (
	select ci.inst_id
		, mp.max_pool_count
		, ci.drcp_connection_count
		, round(ci.drcp_connection_count / mp.max_pool_count * 100,1 ) cpool_used_pct
	from max_pools mp
	cross join conn_info ci
	--order by 1
)
select inst_id, max_pool_count, drcp_connection_count, cpool_used_pct, :n_cpool_pct_threshold pct_threshold,
	case 
	when cpool_used_pct >= :n_cpool_pct_threshold then 'DRCP Needs more servers!'
	else 'DRCP Connection status is OK'
	end alert_status
from cpool_used cu
/

