
--spool err.txt

set feed off 

var max_read number
var max_write number
var max_io number
var total_read number
var total_write number
var total_io number


begin

	select
		max(sum(phyrds)), 
		max(sum(phywrts)), 
		max(sum(phywrts+phyrds)) 
		into :max_read, :max_write, :max_io
	from v$filestat x, sys.ts$ ts, v$datafile i, sys.file$ f
	where i.file#=f.file#
	and ts.ts# = f.ts#
	and x.file#=f.file#
	group by ts.ts#;

	select
		sum(phyrds), 
		sum(phywrts), 
		sum(phywrts+phyrds) 
		into :total_read, :total_write, :total_io
	from v$filestat x, sys.ts$ ts, v$datafile i, sys.file$ f
	where i.file#=f.file#
	and ts.ts# = f.ts#
	and x.file#=f.file#;

end;
/

set echo off feed on line 60 pages 60

spool ioweight.txt

col physread head 'PHYS READS'
col physwrite head 'PHYS WRITES'
col physio head 'PHYS I/O'
col weight format 999.99 head 'WEIGHT'
col pct format 99.99 head 'PCT'
col tbsname format a15 head 'TABLESPACE NAME'

@@title80 'TBS READS'
ttitle on

select
	sum(x.phyrds) physread,
	ts.name tbsname,
	( sum(x.phyrds) / :max_read ) * 100 weight,
	( sum(x.phyrds) / :total_read ) * 100 pct
from v$filestat x, sys.ts$ ts, v$datafile i, sys.file$ f
where i.file#=f.file#
and ts.ts# = f.ts#
and x.file#=f.file#
group by ts.name
order by 1 desc
/

@@title80 'TBS WRITES'
ttitle on

select
	sum(x.phywrts) physwrite,
	ts.name tbsname,
	( sum(x.phywrts) / :max_write ) * 100 weight,
	( sum(x.phywrts) / :total_write ) * 100 pct
from v$filestat x, sys.ts$ ts, v$datafile i, sys.file$ f
where i.file#=f.file#
and ts.ts# = f.ts#
and x.file#=f.file#
group by ts.name
order by 1 desc
/

@@title80 'TBS READS+WRITES'
ttitle on

select
	sum(x.phywrts+x.phyrds) physio,
	ts.name tbsname,
	( sum(x.phywrts+x.phyrds) / :max_io ) * 100 weight,
	( sum(x.phywrts+x.phyrds) / :total_io ) * 100 pct
from v$filestat x, sys.ts$ ts, v$datafile i, sys.file$ f
where i.file#=f.file#
and ts.ts# = f.ts#
and x.file#=f.file#
group by ts.name
order by 1 desc
/

spool off

