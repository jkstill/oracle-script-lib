
col username heading 'USERS LOGGED ON' format a15
col sessions heading 'SESSIONS'

select username, count(*) sessions
	from v$session
	where username is not null
	group by username
	order by sessions desc, username
;

