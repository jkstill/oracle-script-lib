col avg_write_time format 999.99999 head 'AVG|WRITE|SECONDS'
col avg_read_time format 999.99999 head 'AVG|READ|SECONDS'

/*

Yes, summing and averaging TIME_WAITED from ASH/AWR is "wrong"

This is because not all waits are captured in ASH, and AWR is a 10% sample

However, if a significant amount of time appears, I believe it is good to know that.

Just keep in mind that the amount of time is not accurate, it is lower than the real amount of time

*/


select 
	ww.disk_write_wait_seconds / pw.physical_writes avg_write_time
	, rw.disk_read_wait_seconds /  pr.physical_reads avg_read_time
from
(
	select
		value physical_writes
	from v$sysstat
	where name = 'physical writes'
) pw,
(
	select
		value physical_reads
	from v$sysstat
	where name = 'physical reads'
) pr,
(
	select
		sum(time_waited/100) disk_write_wait_seconds
	from v$system_event
	where event like 'db file%write'
) ww,
(
	select
		sum(time_waited/100) disk_read_wait_seconds
	from v$system_event
	where event like 'db file%read'
) rw
/
