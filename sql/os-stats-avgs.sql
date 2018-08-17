
-- os-stats-avg.sql
-- averages after gathering OS stats
-- see gather_system_stats_iteratively.sql

/*

trying to eliminate SAN read ahead caching that makes mreadtim faster than sreadtim


As read activity increases (to a point) the efficiency of multiblock reads improves to the point where it appears that reading many blocks is faster then reading a single block.
As far as Oracle is concerned that is true.

Notice where the mreadtime increases to higher than sreadtime; this happens during periods of lower activity so that when multiblock read requests are made, they are not cached and the SAN must read them from disk.

There is a Catch 22 here; if Oracle were to be told that mreadtim is LT sreadtim then Oracle will stop cpu costing.
( this is supposedly 'common' knowledge - I have not yet been able to verify it	- certainly it was true for 9i )

In addition then multiblock reads (favoring full table/index scans) suddenly become more popular, even though probably not appropriate.

So, what can we do?

Determine to the extent possible the actual cost of multiblock reads.

Here's one way to get close to actual mreadtim times

Filter collected OS stats on:

- mbrc GT 0
- mreadtim at least 2x larger than sreadtim

*/


define stats_owner='AVAIL'
define stats_table='OS_STATS'


with parallel_io as(
	select statid
		, n1 maxthr
		, n2 slavethr
	from avail.os_stats
	where c4 = 'PARIO'
	and statid like 'OS%'
),
serial_io as (
	select statid
		, c2 start_time
		, c3 end_time
		, n1 sreadtim
		, n2 mreadtim
		, n3 cpuspeed
		, n11 mbrc
	from &stats_owner..&stats_table
	where c4 = 'CPU_SERIO'
	and statid like 'OS%'
),
data as (
	select  s.statid
		, s.start_time
		, s.end_time
		, s.sreadtim
		, nvl(s.mreadtim,0) mreadtim
		, s.cpuspeed
		, nvl(s.mbrc,0)  mbrc
		, nvl(p.maxthr,0)	 maxthr
		, nvl(p.slavethr,0) slavethr
	from parallel_io p, serial_io s
	where p.statid = s.statid
	and ( nvl(s.mreadtim,0) / 2)	> nvl(s.sreadtim,0)
	and nvl(s.mbrc,0) > 0
)
--select 
	--statid
	--, start_time
	--, end_time
	--, mreadtim
	--, sreadtim
	--, mbrc
	--, maxthr
	--, slavethr
--from data
--order by start_time
select 
	avg(cpuspeed) cpuspeed
	, min(cpuspeed) min_cpuspeed
	, max(cpuspeed) max_cpuspeed
	, avg(sreadtim) avg_sreadtim
	, min(sreadtim) min_sreadtim
	, max(sreadtim) max_sreadtim
	, avg(mreadtim) avg_mreadtim
	, min(mreadtim) min_mreadtim
	, max(mreadtim) max_mreadtim
	, avg(mbrc) avg_mbrc
	, min(mbrc) min_mbrc
	, max(mbrc) max_mbrc
	, avg(maxthr) avg_maxthr
	, min(maxthr) min_maxthr
	, max(maxthr) max_maxthr
	, avg(slavethr) avg_slavethr
	, min(slavethr) min_slavethr
	, max(slavethr) max_slavethr
from data

l

/

