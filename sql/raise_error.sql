
-- raise_error.sql
-- arbitrarily raise an error

col u_error new_value u_error noprint

prompt Error number to raise:  
select '-&1' u_error from dual;

declare
	some_error exception;
	pragma exception_init(some_error,&u_error);
begin
	raise some_error;
end;
/




