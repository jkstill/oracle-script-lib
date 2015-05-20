
/*

SQL_ID         PLAN_HASH ACTION CPU WAIT   IO TOTAL P_IO TOP_OBJ
------------- ---------- ------ --- ---- ---- ----- ---- -------- 
a22dcjdxfra19 3173797817 SELECT  50    0   10   60   100
8szmwam7fysa3 2976124318 INSERT   0    0   26   26    31 ORDERS
7jycxu86n60qh 1128103955 SELECT  15    0    0   15
7wgks43wrjtrz 3327148973 SELECT   0    0   10   10    60 ORDERS
fz2g0vsbq9j8m 1334423612 SELECT   7    0    0    7
5dfmd823r8dsp  646114857 INSERT   3    0    3    6   100

*/




define v_dbid=NULL;
select &v_dbid from dual;
col f_dbid new_value v_dbid
select &database_id f_dbid from dual;
select &v_dbid from dual;
select nvl(&v_dbid,dbid) f_dbid from v$database;
select &v_dbid from dual;

col PCT_IO_OBJ for a25
col aud_action for a11
with master as  (
   select
        sql_id,
        sql_plan_hash_value,
        sql_opcode,
        sum(cpu) cpu,
        sum(wait) wait,
        sum(io) io,
        sum(total) total,
        decode(sum(io),0,null, decode(objn,-1,NULL,objn)) objn,  
        row_number() over ( partition by sql_id order by io desc ) seq,
        ratio_to_report( sum(io)) over ( partition by sql_id ) pct
   from (
     select
        ash.SQL_ID , ash.SQL_PLAN_HASH_VALUE , sql_opcode,
        current_obj# objn,
        sum(decode(ash.session_state,'ON CPU',1,0)) cpu,
        sum(decode(ash.session_state,'WAITING',1,0)) -
        sum(decode(ash.session_state,'WAITING', decode(wait_class, 'User I/O',1,0),0)) wait ,
        sum(decode(ash.session_state,'WAITING', decode(wait_class, 'User I/O',1,0),0)) io ,
        sum(decode(ash.session_state,'ON CPU',1,1)) total
     from dba_hist_active_sess_history ash
     where  SQL_ID is not NULL
       and  dbid=&v_dbid
     group by sql_id, SQL_PLAN_HASH_VALUE , sql_opcode, current_obj#
   )
group by sql_id, SQL_PLAN_HASH_VALUE , sql_opcode, objn,io
)
select * from (
select
        sql_id,
        sql_plan_hash_value,
        aud.name aud_action,
        sum(cpu) cpu,
        sum(wait) wait,
        sum(io) io,
        sum(total) total,
        round(max(decode(seq,1,pct,null)),2)*100  pct_io,
        max(decode(seq,1,o.object_name,null)) pct_io_obj
--from master,audit_actions aud , dba_objects o
from master,audit_actions aud , DBA_HIST_SEG_STAT_OBJ o
where
    --    objn=o.object_id(+) 
        objn=o.obj#(+) 
    and sql_opcode=aud.action
group by sql_id,sql_plan_hash_value,aud.name
order by total desc )
where rownum < 10
/
-- and ash.dbid=&DBID
-- and ash.sample_time > sysdate - &minutes /( 60*24)

