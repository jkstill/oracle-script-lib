

-- sqlplus_return_code_2.sql

-- test if a+b = c
-- exit if test fails


create or replace function errchk ( test_number_in varchar2 ) return integer
is
	v_number integer;
begin
	v_number := to_number(test_number_in);
	return 1;
exception
when invalid_number or value_error then
	raise_application_error(-20100,'Your Error Message Here' );
end;
/


define a=1
define b=2
define c=3

-- it is important to exit to the shell with an
-- error code so that the controlling process 
-- knows an error occurred

whenever sqlerror exit 1

select decode( sign( (&a+&b) - &c) ,
	0,errchk(0),
	errchk('failed')
)
from dual
/


define c=2

select decode( sign( (&a+&b) - &c) ,
	0,errchk(0),
	errchk('failed')
)
from dual
/


