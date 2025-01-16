
-- awr-top-10-daily.sql
-- list top 10 events per day from AWR
-- event count is multiplied by 10 due to 10 second snapshot

@clears
set linesize 200 trimspool on
set pagesize 100

break on workday skip 1

with data as (
	select trunc(sample_time) workday, event, count(*) * 10 event_count
	from dba_hist_active_sess_history
	where
		--trunc(sample_time) = to_date('2023-03-09','yyyy-mm-dd')
		sample_time > = cast(trunc(sysdate - 10) as timestamp)
		and event is not null
	group by trunc(sample_time), event
),
ranked as (
	select distinct
		workday
		, event
		, event_count
		, rank()  over ( partition by workday order by event_count ) event_rank
	from data
	order by  workday, event_rank
),
max_ranked as (
	select
		workday
		, event
		, event_count
		, event_rank
		, max(event_rank) over (partition by workday) max_rank
	from ranked
)
select
	to_char(workday,'yyyy-mm-dd') workday
		, event
		, event_count
		, event_rank
		--, max_rank
from max_ranked
where event_rank > max_rank - 10
order by workday, event_rank
/

