

set linesize 200

COLUMN   sval1 ON FORMAT   999999
COLUMN   sval2 ON FORMAT   a36
COLUMN   spare1 ON FORMAT   999999999999999999
COLUMN   spare2 ON FORMAT   a6
COLUMN   spare3 ON FORMAT   a6
COLUMN   spare4 ON FORMAT   a40
COLUMN   spare5 ON FORMAT   a6
COLUMN   spare6 ON FORMAT   a6

select 
	sname
	, sval1
	, sval2
	, spare1 -- 1 if default values from oracle, null if user has set them
	, spare2
	, spare3
	, spare4
	, spare5
	, spare6
from SYS.OPTSTAT_HIST_CONTROL$
order by sname
/

