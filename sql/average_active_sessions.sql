
-- average_active_sessions_2.sql
-- current AAS - no ASH required
-- Jared Still
-- 
-- jkstill@gmail.com

/*

	convert sysdate to seconds, but difficult to convert 
	systimestamp to seconds

	run the script, and then just  rerun the current SQL
	rerunning the script will reset the time

*/


var var_init varchar2(10);
var v_start_db_time number
var v_start_time varchar2(30)


set term on feed off
set serveroutput on size unlimited

exec :var_init := 'TRUE'

begin
	if :var_init = 'TRUE' then
		dbms_output.put_line('Waiting 5 seconds for initial check');
	end if;
end;
/

begin

	if :var_init = 'TRUE' then
		:var_init := 'FALSE';

		:v_start_time := to_number(
			extract(day from(systimestamp - to_timestamp('1970-01-01', 'YYYY-MM-DD'))) * 86400000
			+ to_number(to_char(sys_extract_utc(systimestamp), 'SSSSSFF3'))
		);

		select value into :v_start_db_time from v$sys_time_model where stat_name = 'DB time';
		dbms_lock.sleep(5);
	end if;

end;
/


set term on feed on

col aas format 999.99

with dbtime as (
	select stm.value - :v_start_db_time msec
	from v$sys_time_model stm
	where stm.stat_name = 'DB time'
),
elapsed_time as (
	select 
		(
			to_number(
				extract(day from(systimestamp - to_timestamp('1970-01-01', 'YYYY-MM-DD'))) * 86400000
				+ to_number(to_char(sys_extract_utc(systimestamp), 'SSSSSFF3'))
			) 
			- :v_start_time 
		)
		* 1000 msec
	from dual aa
)
select 
	--d.msec, e.msec,
	d.msec / e.msec aas
from dbtime d, elapsed_time e
/

