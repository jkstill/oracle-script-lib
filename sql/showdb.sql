set feed off echo off pause off

col product format a30 
col version format a20
col status  format a20

select * from product_component_version
/


--select * from v$database;

col sdate head 'STARTUP' format a20
col stime head 'STARTUP' format a20

col global_name format a30 head "Data Base"
ttitle off

select global_name from global_name;

set linesize 150 trimspool on
col instance_name format a20
col host_name format a30
col currdate format a22

select 
	instance_name
	, host_name
	, to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') currdate 
from v$instance
/


col startup format a30 head "Startup Time"

var start_date char(20)

declare

	version integer;
	sqlcmd varchar2(500);

	h_sql_cursor integer;
	
	dummy integer;
	

begin

	select to_number(substr(version,1,2))  into  version
	from product_component_version
	where product like 'Oracle%';

	if version = 7 then -- this likely will no longer work due to changing substr from 1 to 2 characters
		sqlcmd := 'select to_char(to_date(d.value,' || '''' || 'j' || '''' || ')+(s.value/86400),' || '''' || 
			'mm/dd/yyyy hh24:mi:ss' || '''' || ')' || ' into :start_date' || chr(10) || 
			' from v$instance d, v$instance s  ' || chr(10) || 
			' where d.key = ' || '''' || 'STARTUP TIME - JULIAN' || '''' ||  chr(10) || 
			' and s.key = ' || '''' || 'STARTUP TIME - SECONDS' || ''''
			;
	elsif version = 8 then -- this likely will no longer work due to changing substr from 1 to 2 characters
		sqlcmd := 'select to_char(startup_time,' || '''' || 'mm/dd/yyyy hh24:mi:ss' || '''' || ') into :start_date from v$instance';
		null; -- I do not recall why there is a NULL here
	elsif version = 9 or version = 1 then -- this likely will no longer work due to changing substr from 1 to 2 characters
		sqlcmd := 'select to_char(startup_time,' || '''' || 'mm/dd/yyyy hh24:mi:ss' || '''' || ') into :start_date from v$instance';
		null;
	elsif version between 10 and 21  then -- this likely will no longer work due to changing substr from 1 to 2 characters
		sqlcmd := 'select to_char(startup_time,' || '''' || 'mm/dd/yyyy hh24:mi:ss' || '''' || ') into :start_date from v$instance';
		null;
	end if;

	--dbms_output.put_line('SQL: ' || sqlcmd);

	h_sql_cursor := dbms_sql.open_cursor;
	dbms_sql.parse(h_sql_cursor, sqlcmd, dbms_sql.native);
	dbms_sql.define_column(h_sql_cursor,1,:start_date,20);
	dummy := dbms_sql.execute_and_fetch(h_sql_cursor);

	dbms_sql.column_value(h_sql_cursor, 1, :start_date);
	dbms_sql.close_cursor(h_sql_cursor);

end;
/

select :start_date sdate from dual;

set feed on

prompt
