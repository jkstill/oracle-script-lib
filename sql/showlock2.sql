
-- showlock2.sql
-- Jared Still 2023
-- replaces showlock.sql

/*

This script showlock2.sql replaces showlock.sql

There may be some features of showlock.sql that are missing from this script.

Some of those may be incorporated at some time. Feel free to issue a pull request.

showlock.sql was first checked into a repo on April 19, 1997 at 2:50:17 PM

So, it has been awhile since showlock.sql was first used.

In that time, the locking model used by Oracle has changed quite a bit.

There are now multiple rows appearing for each lock in v$lock.

For a simple test case with 9 sessions waiting on locks, showlock.sql reports 1166 rows.

I made an attempt to just fix showlock.sql, but after a while I needed to start over.

Here is an report from showlock2.sql for the aforementioned test case:

SQL# @showlock2

                     BLKING  CON  INST                      BLKING LOCK MODE
LOCK_SID               SESS   ID    ID USERNAME               INST TYPE HELD            MY_SQL
-------------------- ------ ---- ----- -------------------- ------ ---- --------------- --------------------------------------------------------------------------------
   00406                       3     2 SCOTT                       TM   Row-X (SX)      NA
     00413              406    3     2 SCOTT                     2 TM   Row-X (SX)      select * from SCOTT.LOCK_TEST where rowid = 'AAAkirAAOAAAhOFAAD'
     00415              406    3     2 SCOTT                     2 TM   Row-X (SX)      select * from SCOTT.LOCK_TEST where rowid = 'AAAkirAAOAAAhOFAAD'
     00788              406    3     2 SCOTT                     2 TM   Row-X (SX)      select * from SCOTT.LOCK_TEST where rowid = 'AAAkirAAOAAAhOFAAD'
   00780                       3     2 SCOTT                       TM   Row-X (SX)      NA
     00033              780    3     2 SCOTT                     2 TM   Row-X (SX)      select * from SCOTT.LOCK_TEST where rowid = 'AAAkirAAOAAAhOFAAA'
       01160             33    3     2 SCOTT                     2 TM   Row-X (SX)      select * from SCOTT.LOCK_TEST where rowid = 'AAAkirAAOAAAhOFAAC'
     00407              780    3     2 SCOTT                     2 TM   Row-X (SX)      select * from SCOTT.LOCK_TEST where rowid = 'AAAkirAAOAAAhOFAAA'
     00779              780    3     2 SCOTT                     2 TM   Row-X (SX)      select * from SCOTT.LOCK_TEST where rowid = 'AAAkirAAOAAAhOFAAA'
     00795              780    3     2 SCOTT                     2 TM   Row-X (SX)      select * from SCOTT.LOCK_TEST where rowid = 'AAAkirAAOAAAhOFAAA'

10 rows selected.

Tested on Oracle RAC 19.13

See this Oracle note for basic v$lock queries
SCRIPT: FULLY DECODED LOCKING (Doc ID 1020008.6)

*/

clear columns
clear break

set linesize 250 trimspool on
set pagesize 100

col username format a20
col blocking_instance format 99999 head 'BLKING|INST'
col blocking_session format 99999 head 'BLKING|SESS'
col lock_sid format a20
col my_level format a20
col connect_by_iscycle format a25 head 'CONNECT-BY|LOOP INFO'
col mode_held format a15 head 'MODE|HELD'
col mode_requested format a15 head 'MODE|REQUESTED'
col lock_type format a4 head 'LOCK|TYPE'
col con_id format 999 head 'CON|ID'
col inst_id format 9999 head 'INST|ID'
col lock_object format a45
col my_sql format a80 wrap

with waiters as (
	select
		'WAITER' lock_participant
		, blocking_session
		, sid
		, con_id
		, inst_id
		, username
		--, lockwait
		, p1, p2, p3
		, blocking_instance
		, final_blocking_session
		, row_wait_block#
		, row_wait_file#
		, row_wait_obj#
		, row_wait_row#
	from gv$session
	where blocking_session is not null
),
blockers as (
	select
		'BLOCKER' lock_participant
		, blocking_session
		, sid
		, con_id
		, inst_id
		, username
		--, lockwait
		, p1, p2, p3
		, blocking_instance
		, final_blocking_session
		, row_wait_block#
		, row_wait_file#
		, row_wait_obj#
		, row_wait_row#
	from gv$session
	where (sid,con_id) in (select holding_session, con_id from dba_blockers)
),
rawdata as (
	select *
	from waiters
	union all
	select *
	from blockers
),
data as (
	select distinct
		--lock_participant
		r.sid
		, l.kaddr
		, l.id1
		, l.id2
		, r.blocking_session
		, r.con_id
		, r.inst_id
		, r.username
		--, p1, p2, p3
		, r.blocking_instance
   	, l.type lock_type
   	, decode
   	(
      	l.lmode,
      	0, 'None',           /* Mon Lock equivalent */
      	1, 'No Lock',           /* N */
      	2, 'Row-S (SS)',     /* L */
      	3, 'Row-X (SX)',     /* R */
      	4, 'Share',          /* S */
      	5, 'S/Row-X (SRX)',  /* C */
      	6, 'Exclusive',      /* X */
      	to_char(l.lmode)
   	) mode_held
   	, decode
   	(
      	l.request,
      	0, 'None',           /* Mon Lock equivalent */
      	1, 'No Lock',           /* N */
      	2, 'Row-S (SS)',     /* L */
      	3, 'Row-X (SX)',     /* R */
      	4, 'Share',          /* S */
      	5, 'S/Row-X (SSX)',  /* C */
      	6, 'Exclusive',      /* X */
      	to_char(l.request)
   	) mode_requested
		, r.row_wait_block#
		, r.row_wait_file#
		, r.row_wait_obj#
		, r.row_wait_row#
	from rawdata r
	join gv$lock l 
		on  r.sid = l.sid
		and r.inst_id = l.inst_id
		and r.con_id = l.con_id
		-- see 'select * from gv$lock' as per this query
		/*
				select s.username, l.*
				from gv$lock l
				join gv$session s
					on s.inst_id = l.inst_id
					and s.con_id = l.con_id
					and s.sid = l.sid
				where s.username = 'SCOTT'
					--and l.id2 = 0
					and l.type = 'TM'
				order by l.kaddr, l.sid
		*/
		-- id2=0 appears to always be the TM lock, which is what we want to see here
		--and l.id2=0
		and l.type = 'TM'
	order by 
		--lock_participant
		blocking_session nulls first
		, sid
)
select 
	lpad(' ',level*2,' ') || to_char(d.sid,'09999') lock_sid
	--, level
	--, d.sid
	, d.blocking_session
	--, d.kaddr
	, d.con_id
	, d.inst_id
	, d.username
	--, p1, p2, p3
	, d.blocking_instance
   , d.lock_type 
	, d.mode_held
	--, o.owner || '.' || o.object_name lock_object
	, case when row_wait_obj# >1 
		then 'select * from ' || o.owner || '.' || o.object_name || ' where rowid = ''' ||  dbms_rowid.rowid_create(1,row_wait_obj#,row_wait_file#,row_wait_block#,row_wait_row#) || ''''
		else 'NA'
	end my_sql
	--, d.row_wait_block#
	--, d.row_wait_file#
	--, d.row_wait_obj#
	--, d.row_wait_row#
	--, d.mode_requested
	--, case connect_by_iscycle
	--when 0 then 'OK'
	--else 'CONNECT BY LOOP SOURCE'
	--end connect_by_iscycle
from data d
join dba_objects o on o.object_id = d.id1
connect by nocycle blocking_session = prior sid
start with blocking_session is null
/


