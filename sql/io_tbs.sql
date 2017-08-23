

set feed off 

var max_read number
var max_write number
var max_io number
var total_read number
var total_write number
var total_io number


begin

	select
		max(sum(phys_reads)), 
		max(sum(phys_writes)), 
		max(sum(phys_writes+phys_reads)) 
		into :max_read, :max_write, :max_io
	from stats$files
	group by table_space;

	select
		sum(phys_reads), 
		sum(phys_writes), 
		sum(phys_writes+phys_reads)
		into :total_read, :total_write, :total_io
	from stats$files;


end;
/

set echo off feed on line 60 pages 60

--spool io_tbs.txt

col physread head 'PHYS READS'
col physwrite head 'PHYS WRITES'
col physio head 'PHYS I/O'
col weight format 999.99 head 'WEIGHT'
col pct format 99.99 head 'PCT'

ttitle 'TABLESPACE READS BY FREQUENCY IN DESCENDING ORDER'

select
	sum(phys_reads) physread,
	table_space,
	( sum(phys_reads) / :max_read ) * 100 weight,
	( sum(phys_reads) / :total_read ) * 100 pct
from stats$files
group by table_space
order by 1 desc
/

ttitle 'TABLESPACE WRITES BY FREQUENCY IN DESCENDING ORDER'

select
	sum(phys_writes) physwrite,
	table_space,
	( sum(phys_writes) / :max_write ) * 100 weight,
	( sum(phys_writes) / :total_write ) * 100 pct
from stats$files
group by table_space
order by 1 desc
/

ttitle 'TABLESPACE READS+WRITES BY FREQUENCY IN DESCENDING ORDER'

select
	sum(phys_writes+phys_reads) physio,
	table_space,
	( sum(phys_writes+phys_reads) / :max_io ) * 100 weight,
	( sum(phys_writes+phys_reads) / :total_io ) * 100 pct
from stats$files
group by table_space
order by 1 desc
/

--spool off

