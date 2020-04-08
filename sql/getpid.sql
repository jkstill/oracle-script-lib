
col upid new_value upid noprint

-- set term and feed off then back on when calling

select p.spid upid
from v$session s, v$process p
where p.addr = s.paddr and userenv('SESSIONID') = s.audsid
/


