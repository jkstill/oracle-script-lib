
-- timestamp-types.sql
-- Jared Still
-- still@pythian.com jkstill@gmail.com


/*

to see the types from a table

create table timestamp_test( t1 timestamp);

insert into timestamp_test values(systimestamp);

commit;


select  
	dump(t1)
	, dump(cast(trunc(t1) as timestamp))
	, dump(cast(t1 as timestamp with time zone))
	, dump(cast(t1 as timestamp with local time zone))
from timestamp_test
/


*/


select  
	dump(systimestamp)
	, dump(cast(trunc(systimestamp) as timestamp))
	, dump(cast(systimestamp as timestamp with time zone))
	, dump(cast(systimestamp as timestamp with local time zone))
from dual
/
