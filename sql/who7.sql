
-- who7.sql
-- who with avg transaction size
-- only really useful on OLTP systems
-- since ROLLBACKS and COMMITS are used
-- to determine tx size

@clears
@columns

set term off feed off
col cblocksize noprint new_value ublocksize
select value cblocksize 
from v$parameter
where name = 'db_block_size'
/

set term on feed on

set line 200
set pages 60

break on username skip 1
col username format a10
col log_io format 99,999,999  head 'LOGICAL  I/O|BLOCKS'
col phy_io format 99,999,999  head 'PHYSICAL I/O|BLOCKS'
col blk_chgs format 99,999,999  head 'BLOCK|CHANGES'
col idle_time format a11 head 'IDLE TIME'
col tx_size format 999,999,999,999 head 'AVG TRX|BYTES'
col last_access_time format a20 head 'LAST ACCESS TIME'
col serial# format a10
col user_id format a8
col process format a7
col sys_id format a6


select
	b.username,
	substr(a.sid,1,6) sys_ID,
	substr(b.serial#,1,7) SERIAL#,
	substr(to_char(sysdate -(hsecs-a.value)/(24*3600*100),
		'MM/DD/YY:HH:MI:SS'),1,17) Last_Access_Time,
	substr(b.osuser,1,7) User_ID,
	substr(decode(b.osuser,'OraUser',d.spid,b.process),1,7) PROCESS,
	b.status,
	to_number(substr((e.consistent_Gets + e.block_Gets),1,7)) Log_IO,
	to_number(substr(e.Physical_reads,1,7)) Phy_IO,
	to_number(substr(e.block_changes,1,7)) blk_chgs,
	( ( e.block_changes + e.consistent_Gets + e.block_Gets ) * &&ublocksize ) / ( f.value + g.value + decode(f.value + g.value,0,1,0) ) tx_size
from 
	v$sesstat a,
	v$sesstat f,
	v$sesstat g,
	v$session b,
	v$statname c,
	v$statname f2,
	v$statname g2,
	v$process d,
	v$sess_io e,
	v$timer
where
	a.sid= b.sid
	and  a.statistic#=c.statistic#
	and  a.sid = e.sid
	and  a.value !=0
	and  f.statistic#=f2.statistic#
	and  f2.name = 'user commits'
	and  f.sid = e.sid
	and  g.statistic#=g2.statistic#
	and  g2.name = 'user rollbacks'
	and  g.sid = e.sid
	and  b.sid = e.sid
	and  b.paddr = d.addr
	and  b.username is not null
	and  c.statistic# = '14'
	and  c.class = '128'
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
         substr(to_char(sysdate -(hsecs-a.value)/(24*3600*100), 'MM/DD/YY:HH:MI:SS'),1,17),
         d.spid,
         b.process,
         b.status,
         e.consistent_Gets,
         e.block_Gets,
         e.Physical_reads
/


