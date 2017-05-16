

-- date_math_2.sql
-- date math examples

-- how to get the minutes between to dates of the same day

drop table date_math;

create table date_math ( start_date date, end_date date );

insert into date_math values( to_date('10/05/2000', 'mm/dd/yyyy'), to_date('10/15/2000', 'mm/dd/yyyy'));
insert into date_math values( to_date('10/01/2000', 'mm/dd/yyyy'), to_date('10/21/2000', 'mm/dd/yyyy'));
insert into date_math values( to_date('10/20/2000', 'mm/dd/yyyy'), to_date('10/23/2000', 'mm/dd/yyyy'));
insert into date_math values( to_date('10/12/2000', 'mm/dd/yyyy'), to_date('12/17/2000', 'mm/dd/yyyy'));

commit;

-- calculate end_date in business days 
-- variable 'days' is input

col start_date format a30
col end_date format a30

select 
	to_char(start_date, 'mm/dd/yyyy, Day') start_date,
	to_char( start_date + 
		trunc( &&days/5)*7 +
		decode(
			mod(&&days,5),
			4, decode(to_char(start_date, 'D'),1,4,2,4,7,5,6),
			3, decode(to_char(start_date, 'D'),1,3,2,3,3,3,7,4,5),
			2, decode(to_char(start_date, 'D'),5,4,6,4,7,3,2),
			1, decode(to_char(start_date, 'D'),6,3,7,2,1),
			0, decode(to_char(start_date, 'D'),1,-2,7,-1,0)
		),
		'mm/dd/yyyy, Day'
	) end_date
from date_math
/




