
-- e2ts.sql
-- convert a lowres (msec) epoch value to a timestamp
-- 
-- Jared Still 2017-05-16
--  jkstill@gmail.com


prompt Convert a lowres epoch value with seconds to a timestamp with time zone
prompt
prompt Valid timezone values can be offsets or names
prompt Examples Time Zones: 'PST', '-7:00', 'US/Pacific'
prompt
prompt Example:  @e2ts 1482181330 US/Eastern



col u_epoch new_value u_epoch noprint
col u_tz new_value u_tz noprint
col utc format a35
col local_time format a45

prompt epoch: 
ttitle off
btitle off
set term off feed off echo off head on
select '&1' u_epoch from dual;

set term on 
prompt Timezone: 
set term off
select '&2' u_tz from dual;

set term on head on feed on

select
	-- epoch in UTC
	--to_timestamp('1970-01-01', 'YYYY-MM-DD SSSSSFF3') + numtodsinterval( &u_epoch / 86400000000,'DAY') UTC
	--,  ((to_timestamp('1970-01-01', 'YYYY-MM-DD SSSSSFF3') + numtodsinterval( &u_epoch / 86400000000,'DAY')) at time zone 'UTC') at time zone '&u_tz' local_time
	to_timestamp('1970-01-01', 'YYYY-MM-DD SSSSSFF3') + numtodsinterval( &u_epoch / 86400,'DAY') UTC
	,  ((to_timestamp('1970-01-01', 'YYYY-MM-DD SSSSSFF3') + numtodsinterval( &u_epoch / 86400,'DAY')) at time zone 'UTC') at time zone '&u_tz' local_time
from dual
/


undef 1 2


