
/*
   TOP SQL from dba_hist_active_sess_history no v$active_session_history
   filter by DBID

   output looks like

   SQL_ID         PLAN_HASH TYPE                 CPU         WAIT      IO        TOTAL
   ------------- ---------- ---------------- ------- ------------ ------- ------------
   fgzp9yqqjcjvm  707845071 UPDATE                25           95    4081         4201
   8u8y8mc1qxd98  131695425 SELECT                18           57    3754         3829
   cfk8gy594h42s 3743737989 SELECT              2021           17      82         2120
   cnx6ht8bdmf4c          0 PL/SQL EXECUTE       546          367     868         1781
   gyj8wh7vx960y 1736948211 SELECT               197           11    1227         1435
   1wmz1trqkzhzq 1384060092 SELECT               639           20     679         1338
   5vjzz8f5ydqm7 1375932572 SELECT               538            0     541         1079
   8w08jp8urfj6t 3134135242 SELECT               118           10     945         1073

*/
col type for a10
col "CPU" for 999999
col "IO" for 999999
select * from (
select
     ash.SQL_ID , ash.SQL_PLAN_HASH_VALUE Plan_hash, aud.name type,
     sum(decode(ash.session_state,'ON CPU',1,0))     "CPU",
     sum(decode(ash.session_state,'WAITING',1,0))    -
     sum(decode(ash.session_state,'WAITING', decode(wait_class, 'User I/O',1,0),0))    "WAIT" ,
     sum(decode(ash.session_state,'WAITING', decode(wait_class, 'User I/O',1,0),0))    "IO" ,
     sum(decode(ash.session_state,'ON CPU',1,1))     "TOTAL"
from dba_hist_active_sess_history ash,
     audit_actions aud
where SQL_ID is not NULL
   -- and ash.dbid=&DBID
   and ash.sql_opcode=aud.action
   -- and ash.sample_time > sysdate - &minutes /( 60*24)
group by sql_id, SQL_PLAN_HASH_VALUE   , aud.name
order by sum(decode(session_state,'ON CPU',1,1))   desc
) where  rownum < 10
/

