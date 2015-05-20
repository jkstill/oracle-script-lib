

-- date_math_4.sql

-- round timestamps to previous interval
-- 15 minutes in this example

def n_interval_minutes=15

drop table date_math_4 purge;

create table date_math_4 (
	d1 timestamp
)
/

insert into date_math_4 values(to_timestamp('2013-10-30 00:00:00','yyyy-mm-dd hh24:mi:ss'));
insert into date_math_4 values(to_timestamp('2013-10-30 13:12:00','yyyy-mm-dd hh24:mi:ss'));
insert into date_math_4 values(to_timestamp('2013-10-30 13:15:00','yyyy-mm-dd hh24:mi:ss'));
insert into date_math_4 values(to_timestamp('2013-10-30 13:29:00','yyyy-mm-dd hh24:mi:ss'));
insert into date_math_4 values(to_timestamp('2013-10-30 13:31:00','yyyy-mm-dd hh24:mi:ss'));
insert into date_math_4 values(to_timestamp('2013-10-30 13:49:00','yyyy-mm-dd hh24:mi:ss'));
insert into date_math_4 values(to_timestamp('2013-10-30 14:00:00','yyyy-mm-dd hh24:mi:ss'));

commit;

col d1 format a30

with r as (
	select
		d1
		, trunc(d1,'DD') tdate
   	, ( extract (hour from d1 - trunc(d1,'DD') ) * 60 * 60)
     		+ (
	  			( extract (minute from d1 - trunc(d1,'hh24') ) * 60 )
      		-  mod(extract (minute from d1 - trunc(d1,'hh24') ) * 60, (&&n_interval_minutes*60))
			) seconds
	from date_math_4
)
select
	d1
	, seconds
	, tdate + 
		-- midnight converted to 1 second after midnight
		( decode(seconds,0,1,seconds) / (24*60*60)) 
from r
/

