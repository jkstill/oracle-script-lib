
-- ashdump-summary.sql
-- Jared Still - 
--  jkstill@gmail.com
--
-- this example is focused on finding blocked sessions
-- 
-- see ashdump.sql for creating an ASH dump

col session_id format 99999
col blocking_session format 99999
col min_sample_time format a27
col max_sample_time format a27
col event_name format a30
col parameter1 format a20
col parameter2 format a20
col parameter3 format a20
col instance_number format 999 head 'INST'
col per_pdb format 999 head 'PDB'
col duration_seconds format 999999.00009 head 'DURATION'

with data as (
	select distinct
		a.session_id
		, a.instance_number
		, min(a.sample_time) over ( partition by a.blocking_session, a.blocking_session_serial# order by  e.parameter1, e.parameter2, e.parameter3 ) min_sample_time
		, max(a.sample_time) over ( partition by a.blocking_session, a.blocking_session_serial# order by  e.parameter1, e.parameter2, e.parameter3 ) max_sample_time
		, a.blocking_session
		, a.per_pdb
		--, a.event_id
		, e.name event_name
		, e.parameter1
		, e.parameter2
		, e.parameter3
	from ashdump a
	join v$event_name e on a.event_id = e.event_id
),
duration_calc as (
	select  d.*
		,  max_sample_time - min_sample_time duration
	from data d
),
calc_seconds as (
	select d.*,
	extract(second from duration)
		+ ( extract(minute from duration) * 60 )
		+ ( extract(hour from duration) * 3600 )
		+ ( extract(day from duration) * 86400 )
	duration_seconds
	from duration_calc d
)
select
	session_id
	, instance_number
	, per_pdb
	, min_sample_time
	, max_sample_time
	, duration_seconds
	, event_name
	, parameter1
	, parameter2
	, parameter3
from calc_seconds
--order by session_id
order by duration
/

