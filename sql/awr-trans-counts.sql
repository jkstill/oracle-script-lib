

-- awr-trans-counts.sql
-- see: 'How to Calculate the Number of Transactions in a Database (Doc ID 1292114.1)'
-- Jared Still -  jkstill@gmail.com
--  
-- 2016-05-18 initial script
--
-- also included are redo log synch write waits, as that is the overhead wait caused by commit

set linesize 200 trimspool on
set pagesize 60

col instance_number head 'I#' format 999
col begin_interval_time format a30 
col end_interval_time format a30 


with deltas as (
select
	snap.instance_number
	, to_char(trunc(snap.begin_interval_time),'yyyy-mm-dd') snap_date
	--, snap.end_interval_time
	, stat.stat_name
	-- the stat.value and lag_value columns are used for data verification
	--, stat.value
	--, lag(stat.value)
		--over (partition by stat.stat_name order by  snap.instance_number, snap.snap_id)
	--lag_value
	, stat.value -
		lag(stat.value)
		over (partition by stat.stat_name order by  snap.instance_number, snap.snap_id)
	stat_delta
from dba_hist_snapshot snap, dba_hist_sysstat stat
where snap.instance_number = stat.instance_number
	and snap.snap_id = stat.snap_id
	and stat.stat_name in ('user commits','transaction rollbacks','redo synch writes')
	--and snap.begin_interval_time between timestamp '2016-05-16 00:00:00.000'
		--and timestamp '2016-05-16 23:59:59.999'
order by snap.instance_number, stat.stat_name, snap.snap_id
)
select
	p.instance_number
	, p.snap_date
	, p.user_commits
	, p.transaction_rollbacks
	, p.redo_sync_writes
from deltas d
pivot (
	sum(d.stat_delta)
	for stat_name in (
		'user commits' as "USER_COMMITS"
		, 'transaction rollbacks' as "TRANSACTION_ROLLBACKS"
		, 'redo synch writes' as "REDO_SYNC_WRITES"
	)
) p
order by p.snap_date, p.instance_number
/


