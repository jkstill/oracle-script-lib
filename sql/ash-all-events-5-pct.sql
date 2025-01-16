
-- ash-all-events-5-pct.sql
-- Jared Still 2021
-- jkstill@gmail.com 
-- pct_of_db_time column refers to the % of time 
-- each event consumed for the duration of the sql execution

col event format a40
set linesize 200 trimspool on
set pagesize 200

col pct_of_db_time format 999.99

with raw_data as (
	select inst_id,
		decode(session_state,'ON CPU','ON CPU',h.event) event
	from gv$active_session_history h
), summarized as(
	select distinct inst_id, event
		,count(*) over ( partition by inst_id, event ) event_count
		,count(*) over ( partition by inst_id order by inst_id ) event_sum
	from raw_data
	where event not in ('ges generic event')
), rpt_data as (
	select inst_id
		, event
		, event_count
		, event_sum
		, event_count / event_sum * 100 pct_of_db_time
	from summarized
)
select inst_id
	, event
	, event_count
	, event_sum
	, pct_of_db_time
from rpt_data
where	pct_of_db_time >5
or event = 'ON CPU'
order by event_count
/


