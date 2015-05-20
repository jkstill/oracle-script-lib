
-- who5.sql
-- taken from OraMag Code Depot ( and slightly modified )
-- 04/17/2000 - jks
-- removed a column, and 2 tables to account for difference in 8.1.7
-- shows physical IO per session

@clears
@columns
set line 200
set pages 60

break on username skip 1
col username format a10
col log_io format 9,999,999,999  head 'LOGICAL READ|BLOCKS'
col phy_io format 9,999,999,999  head 'PHYSICAL READ|BLOCKS'
col blk_chgs format 9,999,999,999  head 'BLOCK|CHANGES'
col idle_time format a11 head 'IDLE TIME'
col serial# format 99999 head 'SERIAL #'
col sid format 99999 head 'SID'
col osuser format a20 head 'OS USER'
col hitratio format 999.99 head 'HIT|RATIO'


select
	b.username,
	b.sid SID,
	b.serial# SERIAL#,
	b.osuser,
	--substr(decode(b.osuser,'OraUser',d.spid,b.process),1,7) PROCESS,
	b.process,
	b.status,
	to_number(substr((e.consistent_Gets + e.block_Gets),1,9)) Log_IO,
	to_number(substr(e.Physical_reads,1,9)) Phy_IO,
	to_number(substr(e.block_changes,1,9)) blk_chgs,
   -- idle time
   -- days added to hours
   --( trunc(LAST_CALL_ET/86400) * 24 ) || ':'  ||
   -- days separately
   substr('0'||trunc(LAST_CALL_ET/86400),-2,2)  || ':'  ||
   -- hours
   substr('0'||trunc(mod(LAST_CALL_ET,86400)/3600),-2,2) || ':' ||
   -- minutes
   substr('0'||trunc(mod(mod(LAST_CALL_ET,86400),3600)/60),-2,2) || ':' ||
   --seconds
   substr('0'||mod(mod(mod(LAST_CALL_ET,86400),3600),60),-2,2)  idle_time,
	to_number(substr
		(round(100 * ((e.consistent_Gets + e.block_Gets - e.Physical_reads) /
		(e.consistent_Gets + e.block_Gets + 0.0000001)),2),1,8)) HitRatio
from v$session b,
     v$process d,
     v$sess_io e,
     v$timer
where
	b.sid = e.sid
	and  b.paddr = d.addr
	and  b.username is not null
	-- added 0.0000001 to the division above to
	-- avoid divide by zero errors
	-- this is to show all sessions, whether they
	-- have done IO or not
	--and  (e.consistent_Gets + e.block_Gets) > 0
	-- uncomment to see only your own session
	--and userenv('SESSIONID') = b.audsid
order by
         b.username,
         b.osuser,
         b.serial#,
         d.spid,
         b.process,
         b.status,
         e.consistent_Gets,
         e.block_Gets,
         e.Physical_reads
/
