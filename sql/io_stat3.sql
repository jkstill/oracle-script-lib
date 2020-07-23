
-- first run 'io_begin.sql'
-- after a period of time, run 'io_end.sql'
-- then run 'io_stat.sql' for a breakdown of file_io

-- 05/25/1999 jkstill
--    modified to only show active files


clear col
clear break
clear compute

set pause off  pages 60
set verify off echo off line 200
set trimspool on
col name format a60
col rw_ratio format 99999.9 head 'R/W|RATIO'
--col disk noprint
col stime new_value start_time noprint
col etime new_value end_time noprint
col sectime new_value seconds noprint
col global_name new_value dbname noprint

ttitle off
set feed off term on

-- get db
select 'Database: ' || global_name from global_name;
-- set the start_time
select to_char(min(io_date),'mm/dd/yyyy hh24:mi:ss') stime from io_begin;
-- set the end_time
select to_char(max(io_date),'mm/dd/yyyy hh24:mi:ss') etime from io_end;

-- get the difference in seconds ( end_time - start_time )
select 
		round((max(e.io_date) - min(b.io_date)) / ( 1/(24*60*60))) sectime
from io_end e, io_begin b
/

set feed on term on

ttitle 'Filesystem I/O report for &dbname' skip 'Start Time:  &start_time' skip 'End Time  :  &end_time' skip 'Seconds: &seconds' skip 2

break on disk  skip 1 on report
compute sum of rdtot on disk
compute sum of wrtot on disk
compute sum of rdtot on report
compute sum of wrtot on report
compute sum of rpsecond on disk
compute sum of wpsecond on disk
compute sum of iopsecond on disk
compute sum of rpsecond on report
compute sum of wpsecond on report
compute sum of iopsecond on report


col rpsecond format 9999.99 head 'RDS|PER|SEC'
col wpsecond format 9999.99 head 'WRT|PER|SEC'
col iopsecond format 9999.99 head 'IOS|PER|SEC'


select io.inst_id
	, io.name
	, io.rdtot
	, io.wrtot
	, io.rpsecond
	, io.wpsecond
	, io.iopsecond
	, io.rw_ratio
from (
	SELECT
		b.inst_id inst_id,
		b.disk disk,
		substr(b.NAME,instr(b.name,'/',-1)+1) name,
		e.blockreads - b.blockreads rdtot,
		e.blockwrites - b.blockwrites wrtot,
		--decode(e.blockreads-b.blockreads,0,&&seconds, e.blockreads-b.blockreads) / &&seconds rpsecond,
		(e.blockreads-b.blockreads) / decode(e.blockreads-b.blockreads, 0, 1, &&seconds) rpsecond,
		(e.blockwrites-b.blockwrites) / decode(e.blockwrites-b.blockwrites, 0, 1, &&seconds) wpsecond,
		((e.blockreads-b.blockreads) + (e.blockwrites-b.blockwrites)) /
			decode(
				(e.blockreads-b.blockreads) + (e.blockwrites-b.blockwrites),
				0,
				1,
				&&seconds
			)iopsecond,
		round(
			(e.blockreads - b.blockreads) / decode((e.blockwrites - b.blockwrites),0,1,(e.blockwrites - b.blockwrites))
			,2) rw_ratio
	FROM   io_end e, io_begin b
	WHERE b.inst_id = e.inst_id 
		and b.file# = e.file# and b.global_name = e.global_name
	-- only show active files
	and ( ( e.blockreads-b.blockreads != 0 ) or ( e.blockwrites-b.blockwrites != 0 ) )
) io
ORDER BY io.iopsecond
/

ttitle off

