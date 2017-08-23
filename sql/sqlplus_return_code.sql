

-- run some PL/SQL
--
-- if you don't like the results, exit with a 1
-- otherwise exit with a 0
--
-- if exactly 1 row is found in test_dual, then all
-- is ok, exit with 0
-- else exit with 1


-- setup the test
drop table test_dual;

create table test_dual 
as select * from dual;

-- uncomment this line and this script
-- will exit with a 1
insert into test_dual(dummy) values('X');

commit;

-- this is a bind variable
var return_code varchar2(1);

-- this column command creates the substitution 
-- variable 'sqlplus_return_code' when used with
-- a select statement below
col rowcount noprint new_value sqlplus_return_code

declare
	rowcount integer := 0;
begin

	select count(*) into rowcount
	from test_dual;

	if rowcount = 1 then
		select 0 into :return_code
		from dual;
	else
		select 1 into :return_code
		from dual;
	end if;
	
end;
/


set echo off feed off term off
select :return_code rowcount 
from dual;

whenever sqlerror exit &sqlplus_return_code

-- create an intentional error
-- to cause the script to exit
select * from -sdfsdf;

