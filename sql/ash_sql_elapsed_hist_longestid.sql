
-- ash masters - Kyle Hailey


/*

OUTPUT looks like:

SQL_ID            CT         MX   MN       AV MAX_RUN_TIME                        LONGEST_SQ      1      2     3    4   5
------------- ------ ---------- ---- -------- ----------------------------------- ---------- ------ ------ ----- ---- ---
2spgk3k0f7quz    251      29607    0    546.0 11-04-12 12:11:47 11-04-12 20:25:14 16781748      247      2     0    0   2
990m08w8xav7s    591       7681    0     52.0 11-04-13 00:39:27 11-04-13 02:47:28 16786685      587      0     0    2   2
64dqhdkkw63fd   1083       7147    0      7.0 11-03-07 04:01:01 11-03-07 06:00:08 16777218     1082      0     0    0   1
0bujgc94rg3fj    604       4929    0     25.0 11-04-08 10:53:34 11-04-08 12:15:43 16814628      601      1     1    0   1
0hbv80w9ypy0n    161       4089    0   1184.0 11-03-02 04:36:10 11-04-12 23:34:18 16777290       27    116     9    6   3
bzyny95313u12    114       2599    0     47.0 11-03-03 03:06:18 11-03-03 03:49:37 16781191      113      0     0    0   1
ds8cz0fb8w147    161       2531   13    274.0 11-03-01 23:11:48 11-04-12 16:10:37 16777285      136     18     5    1   1
5k7vccwjr5ahd   2653       1963    0     33.0 11-03-01 23:10:12 11-04-12 09:06:12 16778244     2623     15     8    4   3
4d6m2q3ngjcv9    320       1701    3    485.0 11-03-01 23:10:53 11-04-10 18:01:26 16777261       92    168    50    9   1
g5u58zpg0tuk8     97       1359    1     62.0 11-04-12 02:23:37 11-04-13 02:51:09 16777217       92      3     1    0   1
34cgtc9xkgxny     61       1272  978   1163.0 11-03-02 10:06:24 11-03-02 10:27:36 16777250        4      4    14


*/


set linesize 150

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
col 4 for 999
col 5 for 99
col av for 99999
col ct for 99999
col mn for 999
col av for 99999.9
col longest_sql_exec_id for A10
col max_run_time for A35
 
WITH pivot_data AS (
SELECT
      sql_id,
      ct,
      mxdelta mx,
      mndelta mn,
      round(avdelta) av,
      WIDTH_BUCKET(delta_in_seconds,mndelta,mxdelta+.1,5) AS bucket  ,
      SUBSTR(times,12) max_run_time,
      SUBSTR(longest_sql_exec_id, 12) longest_sql_exec_id
FROM (
SELECT
   sql_id,
   delta_in_seconds,
   COUNT(*) OVER (PARTITION BY sql_id) ct,
   MAX(delta_in_seconds) OVER (PARTITION BY sql_id) mxdelta,
   MIN(delta_in_seconds) OVER (PARTITION BY sql_id) mndelta,
   AVG(delta_in_seconds) OVER (PARTITION BY sql_id) avdelta,
   MAX(times) OVER (PARTITION BY sql_id) times,
   MAX(longest_sql_exec_id) OVER (PARTITION BY sql_id) longest_sql_exec_id
FROM (
   SELECT
        sql_id,
        sql_exec_id,
        MAX(delta_in_seconds) delta_in_seconds ,
        LPAD(ROUND(MAX(delta_in_seconds),0),10) || ' ' ||
        TO_CHAR(MIN(start_time),'YY-MM-DD HH24:MI:SS')  || ' ' ||
        TO_CHAR(MAX(end_time),'YY-MM-DD HH24:MI:SS')  times,
        LPAD(ROUND(MAX(delta_in_seconds),0),10) || ' ' ||
        TO_CHAR(MAX(sql_exec_id)) longest_sql_exec_id
   FROM ( SELECT
                                            sql_id,
                                            sql_exec_id,
              CAST(sample_time AS DATE)     end_time,
              CAST(sql_exec_start AS DATE)  start_time,
              ((CAST(sample_time    AS DATE)) -
               (CAST(sql_exec_start AS DATE))) * (3600*24) delta_in_seconds
           FROM
              dba_hist_active_sess_history
           WHERE sql_exec_id IS NOT NULL
             and dbid=&v_dbid
        )
   GROUP BY sql_id,sql_exec_id
)
)
where ct > &min_repeat_executions_filter
 and  mxdelta > &min_elapsed_time
)
SELECT * FROM pivot_data
PIVOT ( COUNT(*) FOR bucket IN (1,2,3,4,5))
ORDER BY mx DESC,av DESC
;

