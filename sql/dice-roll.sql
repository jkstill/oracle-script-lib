
col pct format 999.09

compute sum of die_count on report
break on report


with
function get_rand return integer
as
begin
	dbms_random.seed((extract(day from(systimestamp - to_timestamp('1970-01-01', 'YYYY-MM-DD'))) * 86400) + to_number(to_char(sys_extract_utc(systimestamp), 'SSSSS'))) ;
	return dbms_random.random;
end;
dice_rolls as (
	select  mod(case when r.r <0 then r.r * -1 else r.r end, 6) +1 die
	from
	(
		select get_rand, dbms_random.random r
		from dual
		connect by level <= 3000000
	) r
)
select die, count(*) die_count , round( count(*) / 3000000 * 100,2) pct
from dice_rolls
group by die
order by die
/

