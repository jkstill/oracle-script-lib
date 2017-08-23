
-- timestamp-diff-seconds-2.sql
-- another example of extracting the  number of seconds between two timestamps
--

with prev as (
	select cast(systimestamp - 45.3 as timestamp) ptime from dual
),
curr as (
	select systimestamp ctime from dual
),
times as (
	select c.ctime, p.ptime
		, c.ctime - p.ptime difftime
from prev p, curr c
)
select difftime,
	  (extract( day from difftime ) * 86400)
	+ (extract( hour from difftime) * 3600)
	+ (extract( minute from difftime) * 60)
	+ extract( second from difftime)
from times
/
