
-- ash-top-events.sql
-- Jared Still
-- 
-- jkstill@gmail.com


set linesize 200 trimspool on
set pagesize 100

col event format a60
col event_count format 99,999,999,990
-- top N events to show
def event_rank_limit = 20

-- AWR
--def data_source=dba_hist_active_sess_history
--def instance_indicator=instance_number

-- ASH
def data_source=gv$active_session_history
def instance_indicator=inst_id

clear break
break on &instance_indicator skip 1


--spool ash-top-events.log

prompt ==================================
prompt == ash-top-events.sql
prompt ==================================

prompt ==================================
prompt == top &event_rank_limit ASH by instance
prompt ==================================

with rawdata as (
   select distinct &instance_indicator, event, count(*) over (partition by &instance_indicator,event order by &instance_indicator, event) event_count
   from &data_source
   where event is not null
      and (event not in ('ges generic event' ))
   order by 3 desc
),
data as (
	select &instance_indicator, event, event_count
	from (
		select  &instance_indicator
			, event
			, event_count
			, rank() over (partition by &instance_indicator order by &instance_indicator, event_count desc) as event_rank
		from rawdata
	)
	where event_rank <= &event_rank_limit
)
select *
from data
/


prompt ==================================
prompt == top &event_rank_limit ASH cluster wide
prompt ==================================

with data as (
	select distinct event, count(*) over (partition by event) event_count
	from &data_source
	where event is not null
		and (event not in ('ges generic event' ))
	order by 2 desc
)
select *
from data
where rownum <= &event_rank_limit
/

--spool off

