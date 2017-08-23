select
	s.inst_id,
	s.username username,
	e.event event,
	s.sid,
	s.sql_id,
	e.p1text,
	e.p1,
	e.p2text,
	e.p2,
	e.seq# seq,
	e.state,
	e.wait_time_micro,
	--case wait_time
	--when 0 (SECONDS_IN_WAIT - WAIT_TIME / 100)
	--else 0
	--end seconds_waited,
	e.state
from gv$session s, gv$session_wait e
where s.username is not null
	and s.sid = e.sid
	and s.inst_id = e.inst_id
	and s.username like upper('&uusername')
	-- skip sqlnet idle session messages
	and e.event not like '%message%client'
order by s.username, upper(e.event)
/
