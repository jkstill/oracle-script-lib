
set line 200

col cclass_name format a50

select
	cclass_name
	, num_requests
	, num_hits
	, num_misses
	, num_waits
	--, wait_time -- reserved for future use
	--, client_req_timeouts -- reserved for future use
	, num_authentications
from V$CPOOL_CC_STATS
where num_requests > 0
order by cclass_name
/

