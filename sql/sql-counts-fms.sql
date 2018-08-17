
-- sql-counts-fms.sql
-- show SQL_ID for force_matching_signature when there are
-- two or more SQL_IDs associated to the FMS

-- which ever is an empty string indicates the mode used
break on force_matching_signature

define ash_mode='--'
define awr_mode=''

with fms as (
	-- get distinct list of force matching signatures and sql_id
	select distinct
		force_matching_signature
		, sql_id
	from 
		&ash_mode v$active_session_history
		&awr_mode dba_hist_sqlstat
),
fms_multi as (
-- now get data where there are 2+ fms
	select force_matching_signature
	from fms
	where force_matching_signature is not null 
		and force_matching_signature != 0
	group by force_matching_signature
	having count(*) > 1
)
-- now join back to ASH to get the SQL_IDs per FMS
select
	m.force_matching_signature
	, s.sql_id
from fms_multi m
join fms s on s.force_matching_signature = m.force_matching_signature
order by 1,2
/

