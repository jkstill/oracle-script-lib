
-- show_active_log_test.sql
-- show which archive log destinations are active

select name, value
from v$parameter
where name = 'log_archive_dest'
and value is not null
union all
select p.name, p.value
from v$parameter p where
name like 'log_archive_dest%'
and p.name not like '%state%'
and p.value is not null
and 'enable' = (
	select lower(p2.value)
	from v$parameter p2
	where p2.name =  substr(p.name,1,instr(p.name,'_',-1)) || 'state' || substr(p.name,instr(p.name,'_',-1))
)
union all
select p.name, p.value
from v$parameter p
where p.name like 'log_archive_dest_stat%'
and lower(p.value) = 'enable'
and (
	select p2.value
	from v$parameter p2
	where name = substr(p.name,1,16) || substr(p.name,instr(p.name,'_',-1))
) is not null
/

