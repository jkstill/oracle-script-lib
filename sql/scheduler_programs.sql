
set line 200 pagesize 60 trimspool on
col program_action format a80

select owner, program_name,program_type, program_action
from dba_scheduler_programs
where program_name like '%STATS%'
/
