
-- cpu-stalled-ratio.sql
-- Show the ratio of sessions waiting for CPU to sessions on CPU
-- Jared Still 2024-10-20
-- two WITH clauses are used to get the list of profiles that are in use
-- due to the 12c limitation that listagg(distinct column) does not work 
-- listagg(distinct column) is allowed in 19c

set lines 200
set pages 100
set verify off

col event_count format 999,999,999
col session_status format a20
col stalled format 999,999,999
col on_cpu format 999,999,999
col "Stalled %" format 999.99
col "On CPU %" format 999.99
col profiles_stalled format a60
col profiles_on_cpu format a60

def period=10
def period_units='day'

with waiting_for_cpu as (
	select
		count(*) event_count
	from v$active_session_history
	where event = 'resmgr:cpu quantum'
		and session_state = 'WAITING'
		and sample_time > systimestamp - numtodsinterval(&period, '&period_units')
),
on_cpu as (
	select
		'On CPU' session_status,
		count(*) event_count
	from v$active_session_history
	where session_state = 'ON CPU'
		and sample_time > systimestamp - numtodsinterval(&period, '&period_units')
),
profiles_throttled_data as (
	select
		distinct u.profile
	from v$active_session_history h
	join dba_users u on h.user_id = u.user_id
	where h.event = 'resmgr:cpu quantum'
		and h.session_state = 'WAITING'
		and sample_time > systimestamp - numtodsinterval(&period, '&period_units')
),
profiles_throttled as (
	select
		listagg( profile, ', ') within group (order by profile) profiles_stalled
	from profiles_throttled_data
),
profile_data as (
	select
		distinct u.profile
	from v$active_session_history h
	join dba_users u on h.user_id = u.user_id
	where session_state = 'ON CPU'
		and sample_time > systimestamp - numtodsinterval(&period, '&period_units')
),
profiles_active as (
	select
		listagg(profile, ', ') within group (order by profile) profiles_on_cpu
	from profile_data
)
select
	w.event_count stalled
	, c.event_count on_cpu
	, ( w.event_count / (w.event_count + c.event_count)) * 100 "Stalled %"
	, ( c.event_count / (w.event_count + c.event_count)) * 100 "On CPU %"
	, p.profiles_stalled
	, a.profiles_on_cpu
from waiting_for_cpu w
, on_cpu c
, profiles_throttled p
, profiles_active a
/

