
-- timestamp-types.sql
-- Jared Still
--  jkstill@gmail.com


/*

--to see the types from a table


drop table timestamp_test purge;
create table timestamp_test( t1 timestamp);

insert into timestamp_test values(systimestamp);

commit;

set linesize 90

select  
	dump(systimestamp)
	, dump(t1)
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

set linesize 200 trimspool on

