col sample_time format a30
col event format a30
set linesize 200 trimspool on
set pagesize 60

col avg_wait_time format 90.09999
col wait_time format 9990.09999
col max_time_waited format 90.09999

with av as (
        select
                sample_id
                , session_id
                , sample_time
                , max(time_waited) over (partition by sample_id, session_id, sample_time) time_waited
                --,  time_waited / power(10,6) time_waited
        from v$active_session_history
        where session_state = 'WAITING'
        and event = 'log file sync'
) 
select 
        to_char(trunc(sample_time,'hh24'),'yyyy-mm-dd hh24:mi') sample_time
        , sum(time_waited / power(10,6)) time_waited 
        , max(time_waited / power(10,6)) max_time_waited
        , sum(time_waited / power(10,6)) / count(*) avg_wait_time
from av 
--where rownum <= 100
group by trunc(sample_time,'hh24')
order by sample_time
/
