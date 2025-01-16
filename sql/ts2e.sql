
-- ts2e.sql
-- convert a timestamp to highres (usec) epoch value 
-- 
-- Jared Still 2017-05-16
--  jkstill@gmail.com


prompt Convert a timestamp to a lowres (seconds) epoch value 
prompt
prompt Valid timezone values can be offsets or names
prompt Examples Time Zones: 'PST', '-7:00', 'US/Pacific', 'US/Eastern'
prompt
prompt Example: @ts2e '19-DEC-16 04.02.10.838000000 PM' 'US/Eastern'



col u_timestamp new_value u_timestamp noprint
col u_tz new_value u_tz noprint
col epoch_lores  format  999999999999999999999 new_value v_epoch_lores
col local_time format a45

prompt Timestamp: 
ttitle off
btitle off
set term off feed off echo off head on
select '&1' u_timestamp from dual;

set term on 
prompt Timezone: 
set term off
select '&2' u_tz from dual;

set term on head on feed on

-- this was a lot of work...

with data as (
	select
		to_timestamp('1970-01-01 00:00:00','yyyy-mm-dd hh24:mi:ss') at time zone '&u_tz'
		+
		numtodsinterval (
			(
				floor((cast((to_timestamp('&u_timestamp') at time zone '&u_tz') as date)
				-
				to_date('1970-01-01', 'YYYY-MM-DD')
				)) * 86400
			)
			+ (to_number(to_char(to_timestamp('&u_timestamp'), 'SSSSS')) / 1)
		, 'second'
		) work_date
	from dual
),
utc_data as (
	select work_date at time zone 'UTC' utc_time
	from data
),
utc_components as (
	select 
		extract( day from utc_time - to_timestamp('1970-01-01','yyyy-mm-dd') ) days
		, extract( hour from utc_time ) hours
		, extract( minute from utc_time ) minutes
		, extract( second from utc_time ) seconds
	from utc_data
)
select 
	(days*86400) + (hours * 60 * 60) + (minutes * 60) + seconds epoch_lores
from utc_components
/


undef 1 2


