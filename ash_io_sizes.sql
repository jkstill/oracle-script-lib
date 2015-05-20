

/* 
  
  get I/O sizes  from dba_hist_active_sess_history
  
  output looks like

    EVENT                             MN         AV         MX        CNT
    ------------------------- ---------- ---------- ---------- ----------
    db file scattered read             2         16         16        892
    db file sequential read            1          1          1        105
    direct path read                   1          1          1          1
    direct path write                  1          1          1          2
    direct path write temp             4         29         31         17

   see: https://sites.google.com/site/oraclemonitor/dba_hist_active_sess_history

*/
col event for a25
select event,round(min(p3)) mn,
round(avg(p3)) av,
round(max(p3)) mx,
count(*)  cnt
from dba_hist_active_sess_history
--from v$active_session_history
where  (event like 'db file%' or event like 'direct %')
and event not like '%parallel%'
and dbid=&DBID
group by event
order by event
/

