
-- bulk-collect-1.sql
-- fetch ... bulk collect into demo

set serveroutput on size unlimited

alter session set plsql_optimize_level=3;
--alter session set Plsql_Warnings = 'error:all';
alter session set Plsql_Warnings = 'enable:all';


/*

maxrc can be altered at runtime

begin
  bc.maxrc := 1000;
  bc.main;
end;
/

*/


create or replace package bc authid definer
is
	maxrc integer := 100;
	procedure main;
end;
/

show errors package bc

create or replace package body bc
is

	type objrec_t is table of dba_objects%rowtype index by binary_integer;

	cursor c1 is select * from dba_objects;

	objects objrec_t;

	rowcount integer := 0;

	procedure p(v_in varchar2)
	is
	begin
		dbms_output.put(v_in);
	end;

	procedure pl(v_in varchar2)
	is
	begin
		p(v_in);
		dbms_output.new_line;
	end;

	procedure main
	is
		curr_rows integer := 0;
	begin
		open c1;
		loop

			fetch c1 bulk collect into objects limit maxrc;
			exit when c1%notfound;

			pl('rows fetched: ' || to_char(c1%rowcount - curr_rows));

			curr_rows := c1%rowcount;

		end loop;

		pl('rows fetched: ' || to_char(c1%rowcount - curr_rows));

		pl('rowcount: ' || to_char(c1%rowcount));

		close c1;
	end;

begin

	main;

end;
/

show errors package body bc

