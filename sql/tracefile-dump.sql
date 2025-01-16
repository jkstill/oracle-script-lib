
--- tracefile-dump.sql
-- Jared Still
--
-- if your session has generated a tracefile,
-- you can dump it to trace/tracefile-name
-- 
-- you may also plug in the SID of another session
-- instead of sys_context()

set pagesize 0
set linesize 2000 trimspool on

col u_trace_filename new_value u_trace_filename noprint
set feed off term off

select substr(tracefile,instr(tracefile,'/',-1)+1) u_trace_filename
	from v$process where addr = (
  	select paddr from v$session where sid = sys_context('userenv','sid')
)
/

set feed on term on

host mkdir -p trace

spool trace/&u_trace_filename

select payload
from v$diag_trace_file_contents t
where trace_filename = '&u_trace_filename'
order by line_number
/

spool off


set pagesize 100
set linesize 200 trimspool on

