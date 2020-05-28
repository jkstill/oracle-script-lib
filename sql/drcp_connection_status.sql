
/*

'WAITING' - sessions waiting to connect
'ACTIVE' - sessions that are connected

Possible states;

NONE
CONNECTING
ACTIVE
WAITING
IDLE
CLOSING

If any are waiting for more than N seconds, issue an alert

Might there be an alternative to increase the max count?


*/


select distinct connection_status drcp_connection_status
	, count(connection_status) over (partition by connection_status) drcp_count
from GV$CPOOL_CONN_INFO
order by 1
/
