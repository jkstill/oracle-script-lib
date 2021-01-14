
-- plsql-return-bool-from-sql.sql
-- Jared Still 2021 jkstill@gmai.com

/*

 return a boolean directly from the results of a SQL statement
 no if/then/else needed

 discovered while trolling oracle scripts

*/

declare

function does_exist return boolean
is
	i_exists pls_integer;
begin
	select mod(trunc(dbms_random.value(1,10)),2) into i_exists from dual;
	return(i_exists != 0);
end;

begin
	for i in 1..10
	loop
		if does_exist then
			dbms_output.put_line('found');
		else
			dbms_output.put_line('not found');
		end if;
	end loop;
end;
/

