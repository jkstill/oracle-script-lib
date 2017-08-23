select min(snap_id), max(snap_id)
from stats$snapshot
where snap_time between to_date('03/13/2003 10:00','mm/dd/yyyy hh24:mi')
and to_date('03/13/2003 14:00', 'mm/dd/yyyy hh24:mi')
/
