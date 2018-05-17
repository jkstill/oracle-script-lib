
-- ash masters - Kyle Hailey


/*
OUTPUT looks like

SQL_ID                CT         MX         MN       AV      1      2     3     4     5
------------- ---------- ---------- ---------- -------- ------ ------ ----- ----- -----
5k7vccwjr5ahd       2653       1963          0     33.4   2623     15     8     4     3
ds8cz0fb8w147        161       2531         13    273.8    136     18     5     1     1
bzyny95313u12        114       2599          0     46.5    113      0     0     0     1
0hbv80w9ypy0n        161       4089          0   1183.9     27    116     9     6     3
71fwb4n6a92fv         49       4481         30    676.9     38      6     2     2     1
0bujgc94rg3fj        604       4929          0     24.7    601      1     1     0     1
64dqhdkkw63fd       1083       7147          0      7.2   1082      0     0     0     1
990m08w8xav7s        591       7681          0     51.8    587      0     0     2     2
2spgk3k0f7quz        251      29607          0    546.1    247      2     0     0     2
497wh6n7hu14f         49      69438          0   5498.2     44      1     0     1     3

*/



--col f_minutes new_value v_minutes
--select &minutes f_minutes from dual;
--select &v_minutes from dual;

define v_dbid=NULL;
select &v_dbid from dual;
col f_dbid new_value v_dbid
select &database_id f_dbid from dual;
select &v_dbid from dual;
select nvl(&v_dbid,dbid) f_dbid from v$database;
select &v_dbid from dual;


col 1 for 99999
col 2 for 99999
col 3 for 9999
col 4 for 9999
col 5 for 9999
col av for 99999.9
with pivot_data as (
select
      sql_id,
      ct,
      mxdelta mx,
      mndelta mn,
      avdelta av,
      width_bucket(delta,0,mxdelta+.1,5) as bucket
from (
select
   sql_id,
   delta,
   count(*) OVER (PARTITION BY sql_id) ct,
   max(delta) OVER (PARTITION BY sql_id) mxdelta,
   min(delta) OVER (PARTITION BY sql_id) mndelta,
   avg(delta) OVER (PARTITION BY sql_id) avdelta
from (
   select
        sql_id,
        sql_exec_id,
        max(delta) delta
     from ( select
                 sql_id,
                 sql_exec_id,
              ((cast(sample_time    as date)) -
               (cast(sql_exec_start as date))) * (3600*24) delta
           from
              dba_hist_active_sess_history
           where sql_exec_id is not null
            and  dbid=&v_dbid
    )
     group by sql_id,sql_exec_id
)
)
)
select * from pivot_data
PIVOT ( count(*) FOR bucket IN (1,2,3,4,5))
order by mx,av
/

