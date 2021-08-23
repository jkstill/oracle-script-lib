
-- cores.sql
-- report the number of cores
-- may show hyperthread cores

col value format 9999

select inst_id,stat_name, value
from gv$osstat
where stat_name in ('NUM_CPU_CORES','NUM_CPU_SOCKETS')
order by inst_id, stat_name
/

