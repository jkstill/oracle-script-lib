
-- who2.sql
-- jared still
-- jkstill@gmail.com
-- just a comment

@clears

@oversion_major

define v_10gopts = ''
var v_10gopts varchar2(10)

declare
	i_oversion integer := '&&v_oversion_major';
begin
	if i_oversion <10 then
		:v_10gopts := '--';
	else
		:v_10gopts := '';
	end if;
end;
/

-- enable or disable SQL_ID and other 10g+ stuff
set  term off feed off
col v_10gopts noprint new_value v_10gopts
select :v_10gopts v_10gopts from dual;
set term on feed on


col username heading 'USERNAME' format a10
col sessions heading 'SESSIONS'
col sid heading 'SID' format 99999
col status heading 'STATUS' format a10
col machine format a25 head 'MACHINE'
col client_program format a20 head 'CLIENT PROGRAM'
col server_program format a20 head 'SERVER PROGRAM'
col spid format a5 head 'SRVR|PID'
col serial# format 99999 head 'SERIAL#'
col client_process format a13 head 'CLIENT|PID'
col osuser format a10
col logon_time format a17 head 'LOGON TIME'
col idle_time format a11 head 'IDLE TIME'
col ppid format 99999 head 'PID'
col sql_id format a13 head 'SQL ID'
col block_changes format 99,999,999 head 'BLOCK|CHANGES'

set recsep off term on pause off verify off echo off
set line 200
set trimspool on

clear break
break on username skip 1


select
	s.username,
	s.sid,
	s.serial#,
	&&v_10gopts s.sql_id,
	p.pid ppid,
	s.status,
	i.block_changes,
	s.machine,
	s.osuser,
	p.spid spid,
	substr(s.program,1,20) client_program,
	s.process client_process,
	--substr(p.program,1,20) server_program,
	to_char(logon_time, 'mm/dd/yy hh24:mi:ss') logon_time,
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
	substr('0'||mod(mod(mod(LAST_CALL_ET,86400),3600),60),-2,2)  idle_time
from v$session s, v$process p, v$sess_io i
where s.username is not null
	and s.sid = i.sid
	-- use outer join to show sniped sessions in
	-- v$session that don't have an OS process
	and p.addr(+) = s.paddr
	-- uncomment to see only your own session
	--and userenv('SESSIONID') = s.audsid
order by username, sid
/

set recsep wrapped

