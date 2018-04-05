
-- ashmasters - https://github.com/khailey/ashmasters
-- Kyle Hailey

set linesize 150
set pagesize 100
set verify off echo off term on head on feed on


/*
   ASH graph from v$active_session_history and dba_hist_active_sess_history 
   no filter no DBID
   time filter by # of days, input variable &v_days


   Output looks like

   TO_CHAR( AAS PCT1 FIRST           PCT2 SECOND          GRAPH
   -------- --- ---- --------------- ---- --------------- -------------------------------------------
   15 15:00   7   46 db file sequent   19 CPU             +++++++ooooooooooooo4ooooooooooo------
   15 16:00   6   53 db file sequent   31 CPU             +++++++++ooooooooooo4oooooooo---
   15 17:00   7   48 db file sequent   41 CPU             +++++++++++++++ooooo4oooooooooooooooo-
   15 18:00   5   55 CPU               37 db file sequent ++++++++++++++oooooo4oooooo-
   15 19:00   1   64 CPU               21 db file sequent ++o                 4
   15 20:00   1   63 CPU               19 read by other s ++++o-              4
   15 21:00   2   31 db file sequent   24 CPU             ++ooo----           4
   15 22:00   3   35 CPU               24 db file scatter +++++ooooooo---     4
   15 23:00   6   29 log file sync     25 db file sequent ++++ooooooooo-------4-------------
   16 00:00   7   52 db file sequent   27 CPU             ++++++++++oooooooooo4ooooooooooooooo--
   16 01:00   4   57 CPU               36 db file sequent +++++++++++oooooooo 4
   16 02:00   6   38 db file sequent   21 CPU             ++++++oooooooooooo--4---------
   16 03:00   3   69 db file sequent   20 CPU             +++ooooooooooo      4
   16 04:00   0   45 db file sequent   28 CPU             o                   4
   16 05:00   1   58 db file sequent   24 CPU             +ooo                4
   16 06:00   1   41 db file sequent   39 CPU             +oo                 4


    The "graph" on the right shows the load over time each line is an hour by default. 
    The "+" represent CPU, "o" represent I/O and "-" represent a wait.
    The columns "FIRST" and "SECOND" represent the top two things happening on the database. 

*/

Def v_secs=60 --  bucket size
Def v_days=1 --  total time analyze
Def v_bars=5 -- size of one AAS in characters
Def v_graph=80

col aveact format 999.99
col graph format a30
col fpct format 9.99
col spct format 9.99
col tpct format 9.99
col aas1 format 99.99
col aas2 format 99.99
col first format A15
col second format A15


select to_char(start_time,'DD HH24:MI:SS'),
       samples,
       --total,
       --waits,
       --cpu,
       round(fpct * (total/&v_secs),2) aas1,
       decode(fpct,null,null,first) first,
       round(spct * (total/&v_secs),2) aas2,
       decode(spct,null,null,second) second,
        substr(substr(rpad('+',round((cpu*&v_bars)/&v_secs),'+') ||
        rpad('-',round((waits*&v_bars)/&v_secs),'-')  ||
        rpad(' ',p.value * &v_bars,' '),0,(p.value * &v_bars)) ||
        p.value  ||
        substr(rpad('+',round((cpu*&v_bars)/&v_secs),'+') ||
        rpad('-',round((waits*&v_bars)/&v_secs),'-')  ||
        rpad(' ',p.value * &v_bars,' '),(p.value * &v_bars),10) ,0,30)
        graph
     --  spct,
     --  decode(spct,null,null,second) second,
     --  tpct,
     --  decode(tpct,null,null,third) third
from (
select start_time
     , max(samples) samples
     , sum(top.total) total
     , round(max(decode(top.seq,1,pct,null)),2) fpct
     , substr(max(decode(top.seq,1,decode(top.event,'ON CPU','CPU',event),null)),0,15) first
     , round(max(decode(top.seq,2,pct,null)),2) spct
     , substr(max(decode(top.seq,2,decode(top.event,'ON CPU','CPU',event),null)),0,15) second
     , round(max(decode(top.seq,3,pct,null)),2) tpct
     , substr(max(decode(top.seq,3,decode(top.event,'ON CPU','CPU',event),null)),0,10) third
     , sum(waits) waits
     , sum(cpu) cpu
from (
  select
       to_date(tday||' '||tmod*&v_secs,'YYMMDD SSSSS') start_time
     , event
     , total
     , row_number() over ( partition by id order by total desc ) seq
     , ratio_to_report( sum(total)) over ( partition by id ) pct
     , max(samples) samples
     , sum(decode(event,'ON CPU',total,0))    cpu
     , sum(decode(event,'ON CPU',0,total))    waits
  from (
    select
         to_char(sample_time,'YYMMDD')                      tday
       , trunc(to_char(sample_time,'SSSSS')/&v_secs)          tmod
       , to_char(sample_time,'YYMMDD')||trunc(to_char(sample_time,'SSSSS')/&v_secs) id
       , decode(ash.session_state,'ON CPU','ON CPU',ash.event)     event
       , sum(decode(session_state,'ON CPU',1,decode(session_type,'BACKGROUND',0,1))) total
       , (max(sample_id)-min(sample_id)+1)                    samples
     from
        v$active_session_history ash
     where
               sample_time > sysdate - &v_days
     group by  trunc(to_char(sample_time,'SSSSS')/&v_secs)
            ,  to_char(sample_time,'YYMMDD')
            ,  decode(ash.session_state,'ON CPU','ON CPU',ash.event)
union all
    select
         to_char(sample_time,'YYMMDD')                      tday
       , trunc(to_char(sample_time,'SSSSS')/&v_secs)          tmod
       , to_char(sample_time,'YYMMDD')||trunc(to_char(sample_time,'SSSSS')/&v_secs) id
       , decode(ash.session_state,'ON CPU','ON CPU',ash.event)     event
       , sum(decode(session_state,'ON CPU',10,decode(session_type,'BACKGROUND',0,10))) total
       , (max(sample_id)-min(sample_id)+1)                    samples
     from
        dba_hist_active_sess_history ash
     where
               sample_time > sysdate - &v_days
         and sample_time < ( select min(sample_time) from v$active_session_history)
     group by  trunc(to_char(sample_time,'SSSSS')/&v_secs)
            ,  to_char(sample_time,'YYMMDD')
            ,  decode(ash.session_state,'ON CPU','ON CPU',ash.event)
  )  chunks
  group by id, tday, tmod, event, total
) top
group by start_time
) aveact,
  v$parameter p
where p.name='cpu_count'
order by start_time
/

