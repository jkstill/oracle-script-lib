

-- undo-active.sql
-- Jared Still -  
--  jkstill@gmail.com


select to_char(s.end_time,'yyyy-mm-dd hh24:mi:ss') end_time, s.inst_id, s.undotsn, t.name, sum(activeblks)
from gv$undostat s
join gv$tablespace t on t.ts# = s.undotsn
   and s.inst_id = t.inst_id
where s.end_time = ( select max(end_time) from gv$undostat)
group by to_char(s.end_time,'yyyy-mm-dd hh24:mi:ss'), s.inst_id, s.undotsn, t.name
order by 1,2
/
