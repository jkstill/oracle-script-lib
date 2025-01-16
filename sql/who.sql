
col username heading 'USERS LOGGED ON' format a15
col sessions heading 'SESSIONS'
clear break

break on report
compute sum of sessions on report

select username, count(*) sessions
	from v$session
	where username is not null
	group by username
	order by sessions desc, username
;

