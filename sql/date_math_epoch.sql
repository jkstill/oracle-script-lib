

-- date_math_epoch.sql
-- convert current timestamp to epoch (UTC)
-- convert epoch to timestamp
-- Jared Still - 2017-05-16
--   jkstill@gmail.com
--

col u_epoch new_value u_epoch head 'epoch'

-- convert current system timestamp to epoch
-- the first extract could be a constant of 1617321600
select 
	(
		(extract(day from(systimestamp - to_timestamp('1970-01-01', 'YYYY-MM-DD'))) * 86400)
		+ to_number(to_char(sys_extract_utc(systimestamp), 'SSSSS'))
	) u_epoch
from dual
/


-- convert epoch back to timestamp

select
	-- epoch in UTC
	to_timestamp('1970-01-01', 'YYYY-MM-DD SSSSSFF3') + numtodsinterval( &u_epoch / 86400,'DAY')
	-- current local time
	, from_tz(to_timestamp('1970-01-01', 'YYYY-MM-DD SSSSSFF3') + numtodsinterval( &u_epoch / 86400,'DAY'),'UTC') at time zone sessiontimezone
	-- user specified time zone
	, ((to_timestamp('1970-01-01', 'YYYY-MM-DD SSSSSFF3') + numtodsinterval( &u_epoch / 86400,'DAY')) at time zone 'UTC') at time zone 'US/Pacific'
from dual
/

