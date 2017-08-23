

@clears

set pages 0

-- col name format 
col value format 999,999,999,999
col bytes format 999,999,999,999
break on report
compute sum of value on report
compute sum of bytes on report

select * 
from v$sgastat
order by upper(name)
/

select pool, sum(bytes) bytes
from v$sgastat
group by pool
order by pool
/

select * from v$sga
order by name
/

@clears

