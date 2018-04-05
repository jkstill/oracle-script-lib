

-- ashmasters - https://github.com/khailey/ashmasters
-- Kyle Hailey

Def v_secs=3600 --  bucket size
Def v_bars=5 -- size of one AAS in characters
Def v_graph=80

col graph format a80


select
        to_char(to_date(
                         trunc((id*&v_secs)/ (24*60*60)) || ' ' ||  -- Julian days
                           mod((id*&v_secs),  24*60*60)             -- seconds in the day
                , 'J SSSSS' ), 'MON DD YYYY HH24:MI:SS') start_time,
        substr(
             substr(
                  rpad('+',round((cpu*&v_bars)/&v_secs),'+')             ||
                  rpad('-',round((waits*&v_bars)/&v_secs),'-')           ||
                  rpad(' ',p.value * &v_bars,' ')
               ,0,(p.value * &v_bars)) ||
             p.value  ||
             substr(
                  rpad('+',round((cpu*&v_bars)/&v_secs),'+')             ||
                  rpad('-',round((waits*&v_bars)/&v_secs),'-')           ||
                  rpad(' ',p.value * &v_bars,' '),
               (p.value * &v_bars))
           ,0,&v_graph)
        graph
from (
   select
         trunc((to_char(sample_time,'J')*(24*60*60)+to_char(sample_time,'SSSSS'))/&v_secs) id
       , sum(decode(session_state,'ON CPU',1,0))    cpu
       , sum(decode(session_state,'WAITING',1,0))   waits
     from
        -- v$active_session_history ash
        dba_hist_active_sess_history
     group by
        trunc((to_char(sample_time,'J')*(24*60*60)+to_char(sample_time,'SSSSS'))/&v_secs)
) aveact,
  v$parameter p
where p.name='cpu_count'
order by id
/

