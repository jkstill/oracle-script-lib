-- awr_blockers.sql
-- show historic blocking , sql_id and whether mode 4 (ITL) or mode 6 (rowlock)
-- Jared Still
-- 
-- jkstill@gmail.com

/*

As seen in an AWR report for 'Top Event P1/P2/P3 Values'

Event	                     % Event P1, P2, P3 Values	               % Activity  Parameter 1 Parameter 2   Parameter 3
enq: TX - index contention	22.52	  "1415053316","19529734","1548062"	1.65 	      name|mode   usn<<16|slot   sequence

P1 of 1415053316 is a mode 4 ITL wait
P1 of 1415053318 is a mode 6 ITL wait

This can be seen from the binary representation of these values

Mode 4
1415053316
0x54580004
1010100010110000000000000000100

$  perl -e 'print 1415053316 & 0xFFFF, "\n"'
4

Mode 6
1415053318
0x54580006
1010100010110000000000000000110

$  perl -e 'print 1415053318 & 0xFFFF, "\n"'
6

*/

@clears

@get_date_range

col lockmode format a20
col event_name format a40 head 'EVENT NAME'
set line 200 trimspool on
set pagesize 60

set tab off

-- d_date_format set by get_date_range.sql

with waits as (
   select
      sh.inst_id instance_number
      , sh.blocking_session
      , sh.sql_id
      , n.name event_name
		, chr(bitand(sh.p1,-16777216)/16777215)||
		       chr(bitand(sh.p1, 16711680)/65535) LOCKNAME
      , bitand(sh.p1,65535) lockmode
   from gv$active_session_history sh
   join v$event_name n on sh.event_id = n.event_id
   where sh.blocking_session is not null
   --and sh.event_id = ( select event_id from v$event_name where name like 'enq: TX - row lock contention')
   and sh.event_id in ( select event_id from v$event_name where name like 'enq:%')
)
select
   w.instance_number
   , w.event_name
   --, w.blocking_session
   --, w.sql_id
	, w.lockname
   --, decode(w.lockmode, 4,'ITL',6,'ROWLOCK','UNKNOWN') lockmode
	, case w.lockname
	when 'TX' then w.lockmode || '-' || decode(w.lockmode, 0,'None', 1,'No Lock', 2,'Row-S (SS)', 3,'Row-X (SX)',4,'ITL', 5, 'S/Row-X (SRX)', 6,'ROWLOCK','UNKNOWN') 
	when 'TM' then w.lockmode || '-' || decode(w.lockmode, 0,'None', 1,'No Lock', 2,'Row-S (SS)', 3,'Row-X (SX)',4,'Share', 5, 'S/Row-X (SRX)', 6,'Exclusive','UNKNOWN') 
	else w.lockmode || '-' || decode(w.lockmode, 0,'None', 1,'No Lock', 2,'Row-S (SS)', 3,'Row-X (SX)',4,'Share', 5, 'S/Row-X (SRX)', 6,'Exclusive','UNKNOWN') 
	end lockmode
   , count(*) waitcount
from waits w
group by
   w.instance_number
   , w.event_name
   --, w.blocking_session
   --, w.sql_id
	, w.lockname
   , w.lockmode
order by waitcount
/

