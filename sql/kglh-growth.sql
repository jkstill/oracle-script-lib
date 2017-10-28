
-- kglh-growth.sql
-- continued growth of kglh[d0] (gigabytes) is evidence of a memory leak

col bytes format 999,999,999,999

select inst_id, name, pool, bytes 
from gv$sgastat
where name like 'KGLH%'
--and pool='shared pool'
/
