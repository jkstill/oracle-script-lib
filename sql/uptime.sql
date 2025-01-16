
-- uptime.sql - show db uptime

col uptime format a40 head 'UPTIME'

select  to_char(sysdate,'hh:miam') 
	|| ' up ' || trunc( (sysdate - startup_time) ,0) || ' days, ' 
	|| trunc( (sysdate - trunc(sysdate)) *24 ,0)  || ':' -- hours
	|| trunc( (sysdate - trunc(sysdate,'hh')) *24*60 ,0 ) || ', ' -- minutes
	|| s.user_count || ' users' uptime
from v$instance i, ( 
	select count(*) user_count 
	from v$session 
	where username is not null
) s
/
