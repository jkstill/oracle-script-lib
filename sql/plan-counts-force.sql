

-- plan-counts-force.sql
-- Jared Still 2016-02-21
-- 
-- jkstill@gmail.com
-- 
-- find the  number of plans per sql_id using force_matching_signature

with plans as (
	select distinct force_matching_signature , sql_id, plan_hash_value
	from dba_hist_sqlstat
),
plancounts as (
	select distinct force_matching_signature , sql_id,
		count(*) over (partition by force_matching_signature , sql_id) plan_count
	from plans
)
select force_matching_signature , sql_id, plan_count
from plancounts
where plan_count > 1
order by 1,2,3
/
