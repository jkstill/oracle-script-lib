

/* wait event latency  last minute

   output looks like

   AVG_IO_MS
  ----------
       8.916

*/

select 10*time_waited/nullif(wait_count,0) avg_io_ms -- convert centi-seconds to milliseconds
from   v$waitclassmetric  m
       where wait_class_id= 1740759767 --  User I/O
/

