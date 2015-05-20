col avg_write_time format 999.99999 head 'AVG|WRITE|SECONDS'
col avg_read_time format 999.99999 head 'AVG|READ|SECONDS'

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
