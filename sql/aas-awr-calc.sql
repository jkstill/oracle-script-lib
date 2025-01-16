
-- aas-calc.sql
-- calculate AAS from AWR

@clear_for_spool

set term off

spool aas-calc.csv

prompt begin_time,end_time,instance_number,elapsed_seconds,AAS

with data as (
-- the values seen in dba_hist_sysmetric_history for AAS are at times suspiciously very high
-- now calculating them from dba_hist_sysmetric_history
-- doing so may take a few minutes - 5 minutes observed on a db with AWR retentionn of 30 days
-- this was a server with 4T RAM and 80 cores.
	select begin_time,end_time,instance_number,elapsed_seconds,AAS
	from (
		select 
			to_char(begin_interval_time,'yyyy-mm-dd hh24:mi:ss') begin_time
			, to_char(end_interval_time,'yyyy-mm-dd hh24:mi:ss') end_time
			, instance_number
			, elapsed_seconds
			, round(db_time / elapsed_seconds,1)  aas
		from (
			select distinct h.snap_id
				, h.instance_number
				, h.dbid
				, s.begin_interval_time
				, s.end_interval_time
				, count(*) over (partition by h.snap_id, h.instance_number) * 10 db_time
				, (extract( day from (s.end_interval_time - s.begin_interval_time) )*24*60*60)+
					(extract( hour from (s.end_interval_time - s.begin_interval_time) )*60*60)+
					(extract( minute from (s.end_interval_time - s.begin_interval_time) )*60)+
					(extract( second from (s.end_interval_time - s.begin_interval_time)))
					elapsed_seconds
			from dba_hist_active_sess_history h
			join dba_hist_snapshot s on s.snap_id = h.snap_id
			and s.instance_number = h.instance_number
			where (
				( h.session_state = 'WAITING' and h.wait_class not in ('Idle') )
				or
				h.session_state = 'ON CPU'
			)
			--and rownum <= 200
		)
		order by 2 desc
	)
)
select 
	begin_time
	|| ',' || end_time
	|| ',' || instance_number
	|| ',' || elapsed_seconds
	|| ',' || aas
from data
order by begin_time, instance_number
--where rownum <= 20
/

spool off
set term on
@clears

prompt
prompt results are in aas-calc.csv
prompt 

