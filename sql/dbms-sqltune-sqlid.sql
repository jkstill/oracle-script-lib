
-- dbms-sqltune-sqlid.sql
-- Jared Still jkstill@gmail.com 
--
-- create a SQL tuning job, execute it, and run the report
-- rather straightforward.
-- this script is just a convenience to save some time
-- 
-- exits with error if an invalid sql_id is sent

@clears

col v_sqlid new_value v_sqlid noprint

-- max length of task_name is 30 
-- found through experimentation as it does not seem to be documented
var b_sql_tune_task_name varchar2(30)
var b_test_sqlid varchar2(13)

prompt SQL_ID:
set feed off term off head off
select '&1' v_sqlid from dual;
set feed on term on head on

exec :b_test_sqlid := '&v_sqlid'

-- sqlplus will exit if invalid sql_id
whenever sqlerror exit 127

declare

	v_sql_tune_task_id varchar2(100);
	v_sql_tune_task_name varchar2(100);
	v_sqlid varchar2(13);
	v_timestamp varchar2(30);

	function sql_id_is_valid ( sql_id_in varchar2) return boolean
	is
		-- the set of valid characters for SQL_ID
		v_alphabet varchar2(32) := '0123456789abcdfghjkmnpqrstuvwxyz';
		i_sql_valid pls_integer := 0;
	begin
		select 1 into i_sql_valid
		from dual
		where regexp_like( sql_id_in , q'[[]' || v_alphabet || q'[]{13}]' , 'i');
		return(i_sql_valid != 0);
	end;

begin

	begin
		if sql_id_is_valid ( :b_test_sqlid ) then
			v_sqlid := :b_test_sqlid;
		end if;
	exception
	when no_data_found then
		raise_application_error(-20000,'Invalid SQL ID');
	end;

	-- epoch
	/*
	v_timestamp := to_char (
		extract(day from(systimestamp - to_timestamp('1970-01-01', 'YYYY-MM-DD'))) * 86400000
		+ to_number(to_char(sys_extract_utc(systimestamp), 'SSSSSFF3'))
	);
	*/

	-- or just use a timestamp - this is 15 characters
	v_timestamp := to_char(systimestamp,'yyyymmdd_hh24miss');

	-- sqlid is 13 + '_' is 14
	-- leaves 16 characters available for timestamp
	:b_sql_tune_task_name := v_sqlid || '_' || v_timestamp;

	dbms_output.put_line('task_name: ' || :b_sql_tune_task_name);

	v_sql_tune_task_id := dbms_sqltune.create_tuning_task (
		sql_id => v_sqlid,
		scope => dbms_sqltune.scope_comprehensive,
		time_limit => 500,
		task_name => :b_sql_tune_task_name,
		description => 'SQL_ID: ' || v_sqlid || ' Time: ' || v_timestamp
	);

	dbms_output.put_line('v_sql_tune_task_id: ' || v_sql_tune_task_id);
end;
/

whenever sqlerror continue

--/*


exec dbms_sqltune.execute_tuning_task(task_name => :b_sql_tune_task_name)

set long 2000000
set longchunksize 65536
set linesize 200 trimspool on
set pagesize 500
set tab off

select dbms_sqltune.report_tuning_task(:b_sql_tune_task_name) from dual;

--*/

/*
-- drop a tuning task

exec dbms_sqltune.drop_tuning_task(:b_sql_tune_task_name)

*/


