
-- sqlid-elapsed.sql
--
-- use sql-exe-times-awr-rpt.sql instead of this

:

with
function timediff ( time_1_in timestamp, time_2_in timestamp ) return number
as
begin
   return (extract( day from (time_2_in - time_1_in) )*24*60*60)+
      (extract( hour from (time_2_in - time_1_in) )*60*60)+
      (extract( minute from (time_2_in - time_1_in) )*60)+
      (extract( second from (time_2_in - time_1_in)));
end;
select sql_id, sql_exec_id, sql_exec_start, max(sample_time) end_time, count(*), timediff(cast(sql_exec_start as timestamp), max(sample_time)) seconds
from dba_hist_active_sess_history 
where sql_id = 'fuyz8hr1trvxy'
group by sql_id, sql_exec_start, sql_exec_id
order by 1,2
/

