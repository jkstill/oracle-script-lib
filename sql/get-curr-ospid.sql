
-- get-curr-ospid.sql
--
-- get the server OS Pid for the current session
-- Jared Still jkstill@gmail.com 
col username format a20

select
	s.username,
	s.sid,
	p.spid
from v$session s, v$process p
where s.sid = sys_context('userenv','sid')
	and p.addr = s.paddr
order by username, sid
/
