set line 200 trimspool on
set pagesize 60
col resetlogs_change# format 99999999999999

select status
	, incarnation#
	, resetlogs_change#
	, to_char(resetlogs_time,'yyyy-mm-dd hh24:mi:ss') resetlogs_time
	, to_char(prior_resetlogs_time,'yyyy-mm-dd hh24:mi:ss') prior_resetlogs_time
from v$database_incarnation
/

