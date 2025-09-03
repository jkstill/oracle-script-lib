
-- metrics-not-saved-in-awr.sql
-- show metrics that appear in gv$sysmetric_history,
-- but have not been recorded in dba_hist_sysmetric_history
--

set pagesize 100
set linesize 200 trimspool on
col metric_name format a60
col source_id format 999999 head 'ASH ID'
col hist_id format a7 head 'AWR|HIST ID'

with sm as (
	select distinct metric_id from gv$sysmetric_history
)
,h as (
	select distinct metric_id
	from dba_hist_sysmetric_history
)
,n as (
	select distinct metric_id, metric_name
	from v$metricname
)
select 
	sm.metric_id "source_id"
	, nvl(to_char(h.metric_id),'NA') "hist_id"
	, n.metric_name
from sm
left outer join h
	on h.metric_id = sm.metric_id
join n on n.metric_id = sm.metric_id
order by 1
/
