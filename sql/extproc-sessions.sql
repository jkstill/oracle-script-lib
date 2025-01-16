
-- extproc-sessions.sql
-- Jared Still 2023
-- HS: Hetergeneous Services


/* -- example 

@sesswait
																																																				 TIME
USERNAME	  EVENT										SID SQL_ID			P1TEXT						  P1 P2TEXT							 P2	  SEQ STATE								 MICRO
---------- ------------------------------ ------ ------------- --------------- ------------ --------------- ------------ ------- ---------------- ----------------
SYS		  OFS idle								  1465														0									  0	51121 WAITING						1,153,716

RUCKSACKS  External Procedure call			  1719					HS_SESSION_ID					2									  0	  154 WAITING					  98,435,034
														  1712					HS_SESSION_ID					1									  0	  909 WAITING					  98,748,681


@extproc-sessions

USERNAME					EVENT										  SID STARTTIME				 AGENT_ID PROCESS	  PROGRAM										 SEQ STATE					  WAIT_TIME_MICRO
-------------------- ------------------------------ ------- ------------------- ---------- --------- ------------------------------ ---------- ------------------- ----------------
RUCKSACKS				External Procedure call				 1712 2023-01-10 18:22:33			  1 3818		  extproc@hrprocserver						 909 WAITING						 27,813,484
RUCKSACKS				External Procedure call				 1719 2023-01-10 18:22:33			  2 3816		  extproc@hrprocserver						 154 WAITING						 27,499,793

2 rows selected.

Elapsed: 00:00:00.02

*/

set linesize 200 trimspool on
set pagesize 100

col username format a20
col event format a30
col sid format 999999
col sql_id format a13
col p1text format a15
col program format a30
col wait_time_micro format 999,999,999,999
col starttime format a20
col state format a15
col process format a9
col agent_id format 9999999 head 'AGENT ID'

select
	s.username username,
	e.event event,
	s.sid,
	--e.p1text,
	--mod(e.p1,16) p1,
	to_char(h.starttime,'yyyy-mm-dd hh24:mi:ss') starttime,
	h.agent_id,
	a.process,
	a.program,
	e.seq# seq,
	e.state,
	e.wait_time_micro
from v$session s, v$session_wait e, v$hs_session h, v$hs_agent a
where s.username is not null
	and s.sid = e.sid
	-- skip sqlnet idle session messages
	--and e.event not like '%message%client'
	--and s.wait_class != 'Idle'
	and e.state not like 'WAITED%'
	-- HS is extproc
	and e.p1text = 'HS_SESSION_ID'
	--and h.hs_session_id = s.p1
	and h.sid = s.sid
	and a.agent_id = h.agent_id
order by s.username, h.starttime
/

