-- indexes-not-used.sql
-- jared still 2016-12-07
-- still@pythian.com jkstill@gmail.com
--
-- not definitive, dependent on AWR data
-- the more AWR data, the better.

set linesize 200 trimspool on
set pagesize 50 

with users2chk as (
	select
		username
	from dba_users
	where default_tablespace not in ('SYSTEM','SYSAUX')
	and username not in ('SQLTXPLAIN')
),
indexes as (
	select owner, index_name
	from dba_indexes i
	join users2chk u on u.username = i.owner
),
indexes_used as (
	select distinct
		object_owner owner
		, object_name index_name
	from dba_hist_sql_plan sp
	join users2chk u on u.username = sp.object_owner
		and sp.object_type = 'INDEX'
)
select i.owner, i.index_name, iu.index_name
from indexes i
full outer join indexes_used iu on iu.owner = i.owner
	and iu.index_name = i.index_name
where iu.index_name is null
order by 1,2
/
