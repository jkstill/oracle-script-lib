
-- session-cursor-metrics.sql
-- Jared Still 
--  2018
--  jkstill@gmail.com

/*

Equal width bucket (10 buckets) Histograms for session cursor metrics

*/

var metric varchar2(60)

set serveroutput on size unlimited
set feedback off
begin
	:metric := 'session cursor cache count';
	dbms_output.put_line(chr(9));
	dbms_output.put_line('Metrics for ' || :metric);
	dbms_output.put_line(chr(9));
end;
/
set feedback on


with data as (
   select
		 s.inst_id
       ,width_bucket(s.value,1,50,10)  used
   from
   gv$statname n,
      gv$sesstat s
   where
      n.name = :metric
      and s.statistic# = n.statistic#
		and s.inst_id = n.inst_id
)
select distinct
	inst_id
   , used
   , count(used) over (partition by inst_id,used order by inst_id,used) used_count
from data
order by inst_id, used
/

set feedback off

exec :metric := 'opened cursors current'
exec dbms_output.put_line(chr(9))
exec dbms_output.put_line('Metrics for ' || :metric)
exec dbms_output.put_line(chr(9))

set feedback on

prompt Metrics for :metric

/



