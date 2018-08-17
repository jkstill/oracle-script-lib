
-- ash masters - Kyle Hailey

/*

Output looks like

SQL_ID          COUNT(*)      MX        AV        MIN
------------- ---------- ------- --------- ----------
0fvrpk7476b7y         26    3068     133.1          0
1pjp66rxcj6tg         15    3106     767.7         57
8r5wuxk1dprhr         39    3510     841.0         24
0w5uu5kngyyty         21    3652     442.3          0
0hbv80w9ypy0n        161    4089    1183.9          0
71fwb4n6a92fv         49    4481     676.9         30
0bujgc94rg3fj        604    4929      24.7          0
64dqhdkkw63fd       1083    7147       7.2          0
990m08w8xav7s        591    7681      51.8          0
2n5369dsuvn5a         16   10472    5726.8        303
2spgk3k0f7quz        251   29607     546.1          0
36pd759xym9tc         12   37934   23861.9       1391
497wh6n7hu14f         49   69438    5498.2          0

*/


--col f_minutes new_value v_minutes
--select &minutes f_minutes from dual;
--select &v_minutes from dual;

-- use set_dbid.sql to set dbid
--define v_dbid=NULL;
select &v_dbid from dual;
col f_dbid new_value v_dbid
select &database_id f_dbid from dual;
select &v_dbid from dual;
select nvl(&v_dbid,dbid) f_dbid from v$database;
select &v_dbid from dual;


col mx for 999999
col mn for 999999
col av for 999999.9
 
select
       sql_id,
       count(*),
       max(tm) mx,
       avg(tm) av,
       min(tm) min
from (
   select
        sql_id,
        sql_exec_id,
        max(tm) tm
   from ( select
              sql_id,
              sql_exec_id,
              ((cast(sample_time  as date)) -
              (cast(sql_exec_start as date))) * (3600*24) tm
           from
              dba_hist_active_sess_history
           where sql_exec_id is not null
             and dbid=&v_dbid
    )
   group by sql_id,sql_exec_id
   )
group by sql_id
having count(*) > 10
order by mx,av
/


