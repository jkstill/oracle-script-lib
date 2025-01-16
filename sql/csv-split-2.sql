
-- csv-split-2.sql
-- transform a string of CSV data to rows
-- much less code required than that seen in csv-split.sql
-- useful for accepting input into a procedure or function when an array is not the best solution
-- such as an API call from other apps

-- excellent explanation found here of how this regular expression works:
-- now I do not have to try and explain it :)
-- https://stackoverflow.com/questions/19195280/connect-by-clause-in-regex-substr

-- sqlplus bindvar assignments are printed automatically
set autoprint on

col schema format a10
col l_schemas format a80
set line 200 trimspool on

-- spaces and TABs embedded in the string
def schemas='O E,  HR ,  PM ,	IX'
prompt 
prompt Schemas: '&schemas'
prompt

var l_schemas varchar2(4000)

-- remove all spaces
exec :l_schemas := regexp_replace(trim('&schemas'), '(\s){1,}','')

select 
	regexp_substr(:l_schemas, '[^,]+', 1, level) schema 
from dual 
	connect by regexp_substr(:l_schemas, '[^,]+', 1, level) is not null;

set autoprint off

prompt
prompt =========================================================
prompt Now show one way to use this as an argument to PL/SQL
prompt =========================================================
prompt
prompt

set serveroutput on size unlimited

/*

  procedure scan_schemas accepts a CSV string of args
  an array is used internally

*/


declare

	type csv_t is table of varchar2(30) index by binary_integer;
	csv_validate_test_rows csv_t;

	cursor csv_convert_c(csv_data_in varchar2)  is

		select 
			regexp_substr(csv_data_in, '[^,]+', 1, level) csv_row
		from dual 
			connect by regexp_substr(csv_data_in, '[^,]+', 1, level) is not null;

	procedure process_csv_args (csv_args in varchar2, csv_array in out csv_t)
	is
		csv_data varchar2(4000);
	begin

		-- remove spaces and tabs
		csv_data := regexp_replace(trim(csv_args), '(\s){1,}','');

		if csv_convert_c%isopen then
			close csv_convert_c;
		end if;

		open csv_convert_c(csv_data);
		
		fetch csv_convert_c bulk collect into csv_array;

		/*
		dbms_output.put_line(rpad('=',40,'='));
		dbms_output.put_line('rows: ' || csv_convert_c%rowcount);
		dbms_output.put_line('first row: |' || csv_array(1) || '|' );
		dbms_output.put_line('length: ' || length(csv_array(1)) );
		dbms_output.put_line('elements: ' || csv_array.last);
		*/

		if csv_array(1) is null then
			raise_application_error(-20000,'Empty string passed');
		end if;

		close csv_convert_c;

	exception
	-- placeholder
	when no_data_found then
		null;
	when others then
		raise;
	end;

	procedure scan_schemas(csv_args varchar2)
	is
		object_owners csv_t;
		obj_count integer;
	begin
		process_csv_args(csv_args, object_owners);
		for i in object_owners.first .. object_owners.last
		loop
			select count(*) into obj_count
			from dba_objects
			where owner = object_owners(i);
			dbms_output.put_line(object_owners(i) || ' : ' || obj_count);
		end loop;
	end;

begin

	dbms_output.enable(null);

	--process_csv_args(:l_schemas, csv_validate_test_rows);
	--process_csv_args('TEST1', csv_validate_test_rows);
	--process_csv_args('TEST1,TEST2', csv_validate_test_rows);
	-- fails with ORA-20000
	--process_csv_args('',csv_validate_test_rows);

	scan_schemas(:l_schemas);
	dbms_output.put_line(rpad('=',60,'='));
	dbms_output.put_line('no data will be found for the following');
	dbms_output.put_line(rpad('=',60,'='));
	scan_schemas('CSVTEST');

	-- this one would fail
	--scan_schemas('');

end;
/


