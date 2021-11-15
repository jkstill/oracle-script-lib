
-- index-correlate.sql
-- find indexes that appear in a list of plan_hash values
-- Jared Still  jkstill@gmail.com
-- 2016-12-13 

set pagesize 60
set linesize 200 trimspool on
set feed on feed on head on

with users2chk as (
	select
		username
	from dba_users
	where default_tablespace not in ('SYSTEM','SYSAUX')
	and username not in ('SQLTXPLAIN')
),
plan_hashes as (
	select rownum id, column_value plan_hash
	from (
		table(
			sys.odcinumberlist(
				1044433089
				,1101126240
				,1119050040
				,1246287821
				,156369042
				,1594083598
				,178464408
				,2018889510
				,2024897021
				,2059172706
				,2320338542
				,2548554218
				,2637045017
				,2833312816
				,2953906581
				,3147198717
				,328044147
				,3556278563
				,3712491855
				,3738344404
				,3826049868
				,4048453826
				,4118698134
				,4125701758
				,416178764
				,513533588
				,726715811
				,76869668
				,978612992
			)
		)
	)
)
select distinct
	object_owner owner
	, object_name index_name
from dba_hist_sql_plan sp
join plan_hashes ph on ph.plan_hash = sp.plan_hash_value
join users2chk u on u.username = sp.object_owner
and sp.object_type = 'INDEX'
order by 1,2
/
