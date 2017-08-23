
col tablespace_name format a25
col instance_number format 999 head 'INST'
col con_id format 999 head 'CON'
set linesize 200 trimspool on
set pagesize 60

set term off
spool awr_file_io_times.log

with iotimes as (
	select f.snap_id
		, f.instance_number
		--, f.con_id
		, tbs.name tablespace_name
		, f.file#
		, f.phyrds - lag(f.phyrds) over(partition by f.file#,f.instance_number order by f.snap_id,f.file#) phyrdstot
		, f.phywrts - lag(f.phywrts) over(partition by f.file#,f.instance_number order by f.snap_id,f.file#) phywrtstot
		, f.readtim - lag(f.readtim) over(partition by f.file#,f.instance_number order by f.snap_id,f.file#) readtimtot
		, f.writetim - lag(f.writetim) over(partition by f.file#,f.instance_number order by f.snap_id,f.file#) writetimtot
	from DBA_HIST_FILESTATXS f,
		v$tablespace tbs
	where tbs.ts# = f.ts#
		--and tbs.con_id = f.con_id
)
select
	to_char(s.end_interval_time,'yyyy-mm-dd hh24:mi:ss') end_interval_time
	, io.file#
	, io.instance_number
	--, io.con_id
	, io.tablespace_name
	, io.phyrdstot
	, trunc(io.readtimtot * 10,1) readtimtot_ms
	, trunc(io.readtimtot / decode(io.phyrdstot,0,0.000001,io.phyrdstot) *10,1) avg_read_tim_ms
	, io.phywrtstot
	, trunc(io.writetimtot * 10,1) writetimtot_ms
	, trunc(io.writetimtot / decode(io.phywrtstot,0,0.000001,io.phywrtstot) * 10,1) avg_write_tim_ms
from iotimes io
join dba_hist_snapshot s on s.snap_id = io.snap_id
	and s.instance_number = io.instance_number
	--and s.con_id = io.con_id
	--and DATE'2016-01-13' = trunc(s.end_interval_time)
order by end_interval_time, io.file#, io.instance_number
	--, io.con_id
/

spool off

set term on

