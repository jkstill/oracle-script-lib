
set pagesize 200
set linesize 200

col username format a20
col machine format a35
col MAX_OPEN_CURSOR format a20
col MAX_OPEN_CURSORs format a20
col program format a40

		with ses as (
			select
				s.inst_id
				, s.sid
				, s.serial#
				, b.name username
				, s.program
				, s.status
				, s.machine
			from gv$session s
				join gv$process p on p.addr = s.paddr
					and p.inst_id = s.inst_id
				join gv$bgprocess b on b.paddr = s.paddr
					and b.inst_id = s.inst_id
			union all
			select
				s.inst_id
				, s.sid
				, s.serial#
				, s.username
				, s.program
				, s.status
				, s.machine
			from gv$session s
				join gv$process p on p.addr = s.paddr
					and p.inst_id = s.inst_id
			where s.username is not null
			order by inst_id,username,sid
		)
		select ses.inst_id
			, ses.sid, ses.serial#
			, ses.username
			, ses.program
			, ses.machine
			, ss.value cursor_count
			, p.value max_open_cursors
		--from gv$session ses, gv$sesstat ss, gv$statname sn, gv$parameter p
		from ses, gv$sesstat ss, gv$statname sn, gv$parameter p
		where 
			ss.inst_id = ses.inst_id and ss.sid = ses.sid
			and sn.inst_id = ss.inst_id and sn.statistic# = ss.statistic#
			and p.inst_id = sn.inst_id
			and sn.name = 'opened cursors current'
			and p.name= 'open_cursors'
			--and ses.username = 'JKSTILL'
		order by ss.value
/


