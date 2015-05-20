

/* wait event latency  last minute

   output looks like

   NAME                      TIME_WAITED WAIT_COUNT      AVGMS
   ------------------------- ----------- ---------- ----------
   log file parallel write         2.538          4      6.345
   log file sync                   2.329          1     23.287
   db file sequential read             0          0
   db file scattered read              0          0
   direct path read                    0          0
   direct path read temp               0          0
   direct path write                   0          0
   direct path write temp              0          0

*/

col name for a25
select -- m.intsize_csec,
       n.name ,
       round(m.time_waited,3) time_waited,
       m.wait_count,
       round(10*m.time_waited/nullif(m.wait_count,0),3) avgms
from v$eventmetric m,
     v$event_name n
where m.event_id=n.event_id
  and n.name in (
                  'db file sequential read',
                  'db file scattered read',
                  'direct path read',
                  'direct path read temp',
                  'direct path write',
                  'direct path write temp',
                  'log file sync',
                  'log file parallel write'
)
/
