

-- libcachepin_waits.sql
-- jared still - jkstill@gmail.com
-- if there are waits on Library Cache Pin in v$session_wait
-- this script will show what the waits are for, and which
-- session is causing them
-- keywords:  v$session library cache pin x$kglob x$kglpn
-- inspired by info from OraFaq.com
-- http://www.orafaq.com/wiki/Oracle_database_Internals_FAQ
--
-- see force_libcachepin_wait.sql on one method to force a 
-- library cache pin wait for testing this script.

@clears
set line 115

ttitle "Library Cache Waiters"

COL owner format a8
COL object format a30

select o.owner, o.object, s.username, b.sid, b.serial#, b.mode_held, b.request
from (
	SELECT kglnaown AS owner, kglnaobj as Object
	FROM sys.x$kglob
	WHERE kglhdadr in (
		select e.p1raw
		from v$session s, v$session_wait e
		where s.sid = e.sid
		and e.event like 'library cache pin'
	)
) o,
(
	SELECT 
		s.sid
		, s.serial#
		, kglpnmod mode_held
		, kglpnreq request
	FROM sys.x$kglpn p, sys.v_$session s
	WHERE p.kglpnuse = s.saddr
	AND kglpnhdl in (
		select e.p1raw
		from v$session s, v$session_wait e
		where s.sid = e.sid
		and e.event like 'library cache pin'
		and kglpnmod = 0 -- mode held - 0 indicates waiter
	)
) b,
v$session s
where b.serial# = s.serial#
and b.sid = s.sid
/


ttitle "Library Cache Blockers"

COL owner format a8
COL object format a30

select o.owner, o.object, s.username, b.sid, b.serial#, b.mode_held, b.request
from (
	SELECT kglnaown AS owner, kglnaobj as Object
	FROM sys.x$kglob
	WHERE kglhdadr in (
		select e.p1raw
		from v$session s, v$session_wait e
		where s.sid = e.sid
		and e.event like 'library cache pin'
	)
) o,
(
	SELECT 
		s.sid
		, s.serial#
		, kglpnmod mode_held
		, kglpnreq request
	FROM sys.x$kglpn p, sys.v_$session s
	WHERE p.kglpnuse = s.saddr
	AND kglpnhdl in (
		select e.p1raw
		from v$session s, v$session_wait e
		where s.sid = e.sid
		and e.event like 'library cache pin'
		and kglpnmod != 0 -- mode held - 0 indicates possible blocker
	)
) b,
v$session s
where b.serial# = s.serial#
and b.sid = s.sid
/




