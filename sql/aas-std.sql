
-- aas-std.sql
-- gather AAS metrics from AWR

@clear_for_spool

set term off

spool aas-std-lks.csv

prompt begin_time,end_time,instance_number,elapsed_seconds,AAS


with data as (
	select 
		to_char(h.begin_time,'yyyy-mm-dd hh24:mi:ss') begin_time
		, to_char(h.end_time,'yyyy-mm-dd hh24:mi:ss') end_time
		, (h.end_time - h.begin_time) * 86400  elapsed_seconds
		, h.instance_number
		, round(h.value,2) aas
	from dba_hist_sysmetric_history h
	where h.metric_name = 'Average Active Sessions'
	order by h.snap_id
)
select 
	begin_time
	|| ',' || end_time
	|| ',' || instance_number
	|| ',' || elapsed_seconds
	|| ',' || aas
from data
/

spool off
set term on
@clears


