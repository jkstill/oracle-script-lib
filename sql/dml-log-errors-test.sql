

-- dml-log-errors-test.sql
-- Jared Still jkstill@gmail.com 
-- demo of the INSERT .. LOG ERRORS for DML
--
-- Note:  if the table is in a different schema, this syntax is necessary
--   log errors into schema.err$_table_name
-- where the table name is 'ERR$_' || substr(table_name,1,25)
-- a synonym for the error table would likely work, though doing so
-- seems a bit of a had for this usage


drop table log_err_test purge;
drop table err$_log_err_test purge;

create table log_err_test (
	id integer,
	c1 varchar2(30)
)
/


exec dbms_errlog.create_error_log(dml_table_name => 'LOG_ERR_TEST')

/*
 
 when the number of errors exceeds the reject limit value,
 the INSERT fails, and the rows that failed up to that point
 will still be inserted in to the error log table

 when reject limit is >= 70, the transaction succeeds, with 
 the failed rows being in the error log table

 when reject limit is < 70, the transaction fails, with 
 the failed rows being in the error log table


*/

insert into log_err_test(id,c1) 
-- the length of the string will be 1-100 characters
select level,  rpad('X',level,'X')
from dual
connect by level <= 100
log errors ('insert value too large') reject limit 70 -- change to 69
/

--select 'log_err_test: ' || count(*) from log_err_test;

set linesize 80

describe log_err_test

select * from log_err_test;

select 'err$_log_err_test: ' || count(*) from err$_log_err_test;


