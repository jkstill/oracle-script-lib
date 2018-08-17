

-- ashmasters - https://github.com/khailey/ashmasters
-- Kyle Hailey

/*
   ASH graph from v$active_session_history no filter by DBID nor time 
   don't use dba_hist_active_sess_history ,


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

hello from RMOUG

*/
ef v_secs=3600 --  bucket size
Def v_secs=60 --  bucket size
Def v_bars=5 -- size of one AAS in characters
Def v_graph=80

col aveact format 999.99
col graph format a30
col fpct format 9.99
col spct format 9.99
col tpct format 9.99
col aas1 format 9.99
col aas2 format 9.99
col first format a15
col second format a15

select
        to_char(to_date(
                         trunc((id*&v_secs)/ (24*60*60)) || ' ' ||  -- Julian days
                           mod((id*&v_secs),  24*60*60)             -- seconds in the day
                , 'J SSSSS' ), 'MON DD YYYY HH24:MI:SS')     start_time,
        round(fpct * ((cpu+waits)/&v_secs),2)                aas1,
        decode(fpct,null,null,first)                         first,
        round(spct * ((cpu+waits)/&v_secs),2)                aas2,
        decode(spct,null,null,second)                        second,
        substr(
             substr(
                  rpad('+',round((  cpu/&v_secs)*&v_bars),'+’) ||
                  rpad('-',round((waits/&v_secs)*&v_bars),'-') ||
                  rpad(' ',p.value * &v_bars,' ')
               ,0,(p.value * &v_bars)) ||
             p.value  ||
             substr(
                  rpad('+',round((  cpu/&v_secs)*&v_bars),'+’) ||
                  rpad('-',round((waits/&v_secs)*&v_bars),'-') ||
                  rpad(' ',p.value * &v_bars,' '),
               (p.value * &v_bars))
           ,0,&v_graph)
        graph
from (
select id
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
       id
     , event
     , row_number() over ( partition by id order by event_count desc ) seq  -- 1 for top wait, 2 for 2nd, etc
     , ratio_to_report( event_count ) over ( partition by id )         pct  -- % of event_count to total for id
     , sum(decode(event,'ON CPU',event_count,0))                       cpu
     , sum(decode(event,'ON CPU',0,event_count))                       waits
  from (
   select
         trunc((to_char(sample_time,'J')*(24*60*60)+to_char(sample_time,'SSSSS'))/&v_secs) id
      , decode(session_state,'ON CPU','ON CPU',ash.event)     event
       , count(*) event_count
     from
        v$active_session_history ash
     group by
         trunc((to_char(sample_time,'J')*(24*60*60)+to_char(sample_time,'SSSSS'))/&v_secs)
       , decode(session_state,'ON CPU','ON CPU',ash.event)
  )  chunks
  group by id,  event, event_count
) top
group by id
) aveact,
  v$parameter p
where p.name='cpu_count'
order by id
/

