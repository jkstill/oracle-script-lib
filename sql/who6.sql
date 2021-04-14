
-- who6.sql
-- jared still
-- jkstill@gmail.com

-- show system background processes, names, etc..

@clears

col username heading 'USERNAME' format a10
col bg_description heading 'BG Description' format a50
col sessions heading 'SESSIONS'
col sid heading 'SID' format 99999
col status heading 'STATUS' format a10
col machine format a20 head 'MACHINE'
col client_program format a20 head 'CLIENT PROGRAM'
col server_program format a20 head 'SERVER PROGRAM'
col spid format a5 head 'SRVR|PID'
col serial# format 99999 head 'SERIAL#'
col client_process format a11 head 'CLIENT PID'
col osuser format a7
col logon_time format a17 head 'LOGON TIME'
col idle_time format a11 head 'IDLE TIME'

set recsep off term on pause off verify off echo off
set line 220
set trimspool on

clear break
break on username skip 1

select
	b.name,
	b.description bg_description,
	s.sid,
	s.serial#,
	s.status,
	s.machine,
	s.osuser,
	substr(s.program,1,20) client_program,
	to_char(s.process) client_process,
	substr(p.program,1,20) server_program,
	to_char(p.spid) spid,
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
from v$session s, v$process p, v$bgprocess b
	-- use outer join to show sniped sessions in
	-- v$session that don't have an OS process
	where p.addr = s.paddr
	and s.paddr = b.paddr
order by b.name, sid
/

set recsep wrapped

