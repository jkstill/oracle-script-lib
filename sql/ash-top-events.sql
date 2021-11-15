
-- ash-top-events.sql
-- Jared Still
-- 
-- jkstill@gmail.com


break on inst_id skip 1
set linesize 200 trimspool on
set pagesize 100

spool ash-top-events.log

prompt ==================================
prompt == ash-top-events.sql
prompt ==================================

prompt ==================================
prompt == top 10 ASH by instance
prompt ==================================

with rawdata as (
   select distinct inst_id, event, count(*) over (partition by inst_id,event order by inst_id, event) event_count
   from gv$active_session_history
   where event is not null
      and (event not in ('ges generic event' ))
   order by 3 desc
),
data as (
	select inst_id, event, event_count
	from (
		select  inst_id
			, event
			, event_count
			, rank() over (partition by inst_id order by inst_id, event_count desc) as event_rank
		from rawdata
	)
	where event_rank <= 10
)
select *
from data
/


prompt ==================================
prompt == top 10 ASH cluster wide
prompt ==================================

with data as (
	select distinct event, count(*) over (partition by event) event_count
	from gv$active_session_history
	where event is not null
		and (event not in ('ges generic event' ))
	order by 2 desc
)
select *
from data
where rownum <= 10
/

spool off

