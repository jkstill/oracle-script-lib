
-- sp_io_stat_drive.sql
-- get statspack data on physical IO per drive
-- and date range
-- aggregated per hour

@clears
set line 200

@sp_get_date_range

@clear_for_spool

spool sp_io_stat_drive.csv

select 
	to_char(snap_time,'mm/dd/yyyy hh24:mi') || ','
	|| drive || ','
	|| phyblkrd || ','
	||  phyblkwrt
from (
	select
		trunc(s.snap_time,'hh24') snap_time
		, substr(a.filename,1,1) drive
		, sum(a.PHYRDS) phyrds
		, sum(a.PHYWRTS) phywrts
		, sum(a.READTIM) readtim
		, sum(a.WRITETIM) writetim
		, sum(a.PHYBLKRD) phyblkrd
		, sum(a.PHYBLKWRT) phyblkwrt
		, sum(a.WAIT_COUNT) wait_count
		, sum(a.time) time
	from ( 
		SELECT 
			snap_id
			, tsname
			, filename
			, PHYRDS - LAG(PHYRDS,1) OVER (ORDER BY filename, snap_id) AS PHYRDS
			, PHYWRTS - LAG(PHYWRTS,1) OVER (ORDER BY filename, snap_id) AS PHYWRTS
			, READTIM - LAG(READTIM,1) OVER (ORDER BY filename, snap_id) AS READTIM
			, WRITETIM - LAG(WRITETIM,1) OVER (ORDER BY filename, snap_id) AS WRITETIM
			, PHYBLKRD - LAG(PHYBLKRD,1) OVER (ORDER BY filename, snap_id) AS PHYBLKRD
			, PHYBLKWRT - LAG(PHYBLKWRT,1) OVER (ORDER BY filename, snap_id) AS PHYBLKWRT
			, WAIT_COUNT - LAG(WAIT_COUNT,1) OVER (ORDER BY filename, snap_id) AS WAIT_COUNT
			, TIME - LAG(TIME,1) OVER (ORDER BY filename, snap_id) AS TIME
		from STATS$FILESTATXS
	) a,
	stats$snapshot s
	where a.PHYRDS >= 0
	and a.snap_id = s.snap_id
	and a.snap_id between :v_snap_id_low and :v_snap_id_high
	group by trunc(s.snap_time,'hh24'), substr(a.filename,1,1)
	order by 1,2
)
/

spool off
@clears

