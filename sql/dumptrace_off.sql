
-- dumptrace_off.sql
-- turn off tracing for a current session

@clears

@who2s

prompt
prompt Turn OFF SQL Trace for a current session
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

exec sys.dbms_system.set_ev(&&usid, &&userial, 10046, 0, '');


undef 1


