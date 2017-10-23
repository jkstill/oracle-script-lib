
-- who_protocol.sql
-- jared still
-- jkstill@gmail.com
-- show connection method for each session

@clears

set line 200
col username format a15
col sid format 999999
col serial# format 999999
col AUTHENTICATION_TYPE format a20
col osuser format a15
col NETWORK_SERVICE_BANNER format a80
col client_driver format a9 head 'CLIENT|DRIVER'

select
	s.username,
	s.sid,
	s.serial#,
	--p.pid ppid,
	si.osuser,
	si.client_driver,
	substr(si.NETWORK_SERVICE_BANNER,1,80) NETWORK_SERVICE_BANNER
from v$session s, v$process p, v$session_connect_info si
where s.username is not null
	-- use outer join to show sniped sessions in
	-- v$session that don't have an OS process
	and p.addr(+) = s.paddr
	and si.sid = s.sid
	-- uncomment to see only your own session
	--and userenv('SESSIONID') = s.audsid
	--/*
	and (
		si.network_service_banner like 'Windows NT TCP/IP%'  -- windows
		or si.network_service_banner like 'Oracle Bequeath%' -- windows and linux
		or si.network_service_banner like 'Windows NT Named Pipes%' -- windows
		or si.network_service_banner like 'Unix Domain Socket IPC%' -- linux, unix IPC
		or si.network_service_banner like 'TCP/IP%' -- linux, unix
	)
	--*/
order by username, sid
/



