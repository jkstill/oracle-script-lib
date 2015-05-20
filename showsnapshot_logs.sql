

@clears

col log_owner format a15 head 'LOG OWNER'
col master format a30 head 'MASTER TABLE'
col log_table format a30 head 'LOG TABLE'
col log_trigger format a30 head 'LOG TRIGGER'
col current_snapshots format a20 head 'CURR SNAPSHOTS'


break on log_owner
set line 130

select
	log_owner
	,master
	,log_table
	--,log_trigger
	,to_char(current_snapshots,'mm/dd/yyyy hh24:mi:ss') current_snapshots
from all_snapshot_logs
order by 1
/

