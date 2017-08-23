

-- date_math_3.sql
-- cause a job to run at exactly 00:30 or 12:30, regardless
-- of the last time it started
-- algorithm courtesy of Tim Hall - timhall1@gmail.com



alter session set nls_date_format = 'mm/dd/yyyy hh24:mi';

declare 
	v_date date;
	v_test_date date;

	type date_t is table of date index by binary_integer;
	v_date_table date_t;
begin


	v_date_table(1) := to_date('03/02/2005 00:29');
	v_date_table(2) := to_date('03/02/2005 00:30');
	v_date_table(3) := to_date('03/02/2005 00:31');
	v_date_table(4) := to_date('03/02/2005 12:29');
	v_date_table(5) := to_date('03/02/2005 12:30');
	v_date_table(6) := to_date('03/02/2005 12:31');

	for i in v_date_table.first .. v_date_table.last
	loop

		dbms_output.put('Test Date: ' || v_date_table(i));

		SELECT
			CASE WHEN TO_CHAR(v_date_table(i)+(1/48),'HH24') BETWEEN '01' AND '12' 
			THEN (TRUNC(v_date_table(i))+(25/48))
			ELSE (TRUNC(v_date_table(i) -(1/24))+(49/48)) 
			END
		into v_test_date
		from dual;
	
		dbms_output.put_line('    Next Date: ' || v_test_date);

	end loop;

end;
/
