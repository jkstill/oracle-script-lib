
-- date_math.sql
-- date math examples

-- how to get the minutes between to dates of the same day

drop table date_math;

create table date_math ( start_date date, end_date date );

insert into date_math values( to_date('06/15/1999 06:00:00', 'mm/dd/yyyy hh24:mi:ss'), to_date('06/15/1999 06:45:32', 'mm/dd/yyyy hh24:mi:ss'));

commit;

select 
	to_char( ( end_date - start_date )  +trunc(sysdate) , 'hh24:mi:ss')
from date_math
/

delete from date_math;

insert into date_math values( to_date('06/12/1999 06:00:00', 'mm/dd/yyyy hh24:mi:ss'), to_date('06/15/1999 09:33:16', 'mm/dd/yyyy hh24:mi:ss'));
insert into date_math values( to_date('04/01/1957 06:00:00', 'mm/dd/yyyy hh24:mi:ss'), sysdate );

-- days and minutes

select 
	--days
	floor( end_date - start_date ) || ':' || 
	-- minutes
	to_char( ( end_date - start_date )  +trunc(sysdate) , 'hh24:mi:ss')
from date_math
/

