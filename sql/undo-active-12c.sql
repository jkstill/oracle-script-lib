
-- undo-active-12c.sql
-- Jared Still -  
--  jkstill@gmail.com

select to_char(s.end_time,'yyyy-mm-dd hh24:mi:ss') end_time, t.con_id, s.inst_id, s.undotsn, t.name, sum(activeblks)
from gv$undostat s
join gv$tablespace t on t.ts# = s.undotsn
   and s.inst_id = t.inst_id
   and s.con_id = t.con_id
--join gv$pdbs c on c.inst_id = t.inst_id
   --and c.con_id = t.con_id
where s.end_time = ( select max(end_time) from gv$undostat)
group by to_char(s.end_time,'yyyy-mm-dd hh24:mi:ss'), t.con_id, s.inst_id, s.undotsn, t.name
order by 1,2
/
