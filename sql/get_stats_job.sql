select owner, program_name, program_type, program_action
from DBA_SCHEDULER_PROGRAMS
where program_name = 'GATHER_STATS_PROG'
order by 1,2
/
