
-- dumptrace.sql
-- turn on tracing for a current session

@clears

@who2s

prompt
prompt Turn ON SQL Trace on for a current session
prompt

col csid noprint new_value usid
col cserial noprint new_value userial

prompt Session ID (SID) ? 
set term off  feed off
select '&1' csid from dual;

select serial# cserial 
from v$session
where sid = &&usid;

set term on feed on;

exec sys.dbms_system.set_ev(&&usid, &&userial, 10046, 12, '');

undef 1


