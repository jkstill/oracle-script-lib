
-- ash-snapshot-define-begin-end.sql
-- Jared Still jkstill@gmail.com
-- 2017-05-09
-- A method to define snapshot bracketing by specific time or BEGIN or END of snapshots
--

define snap_begin_time='2016-03-16 13:00'
define snap_end_time='2016-03-16 14:15'

define snap_begin_time='BEGIN'
define snap_end_time='END'


select 
	max(sample_time) - min(sample_time)
	, min(sample_time)
	, max(sample_time)
from v$active_session_history
where sample_time between
	decode('&&snap_begin_time',
		'BEGIN',
		to_timestamp('1900-01-01 00:01','yyyy-mm-dd hh24:mi'),
		to_timestamp('&&snap_begin_time','yyyy-mm-dd hh24:mi')
	)
	AND
	decode('&&snap_end_time',
		'END',
		to_timestamp('4000-12-31 23:59','yyyy-mm-dd hh24:mi'),
		to_timestamp('&&snap_end_time','yyyy-mm-dd hh24:mi')
	)
/

