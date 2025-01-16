
-- gen_bind_vars_awr.sql
--
-- jared still 2024-01-04
-- sqlplus cannot handle bind placeholder names such as :1, :2, etc
-- now a pl/sql block is being used with 'execute immediate'
-- this is to that SQL will execute with the original SQL_ID
--
-- converted execute immediate to dbms_sql, as the results were not as expected
--
-- jared still 2023-12-15 - jkstill@gmail.com
-- changed the SQL that gets bind values - now does a much better job of it
--
-- jared still 2017-08-28 - jkstill@gmail.com,
-- copied from gen_bind_vars.sql and modified for AWR
-- given a SQL_ID get the SQL and bind variables
-- create a sqlplus script to run them
-- crude parsing of data types could use some refinement
-- works for what I need now
--
-- the generated SQL statement may need some editing
--
-- jkstill 2017-11-10
-- refactored quite a bit
-- no longer using utl_file due to SQL formatting issues
--
-- jkstill 2017-11-27
-- now uses a BETWEEN to get the historical metrics
-- dates are set to the :v_start_days_back and :v_end_days_back
-- see parameters at end of comments
--
-- also renames system generated bind variables from SYS_B_ to B_
-- generated bind variables with just a digit name are also changed. eg: :1 becomes :G1
--
-- jkstill 2017-11-27
-- use numtodsinterval() to calculate dates
-- "select systimestamp - interval '100' day from dual" will cause ORA-01873: the leading precision of the interval is too small
-- this can be corrected by:
-- "select systimestamp - interval '100' day(3) from dual"
-- use of numtodsinterval() is much cleaner


-- parameters:
-- 1: sql_id
-- 2: days back for begin snap_id
-- 3: days back for end snap_id
-- to generate a script using bind values from 30 to 60 days ago
-- @gen_bind_vars_awr 'sd3h4987dnwe8' 60 30
--

def file_prefix='sql'


@clears

col my_sql_id new_value my_sql_id noprint
col my_start_days_back new_value my_start_days_back noprint
col my_end_days_back new_value my_end_days_back noprint

prompt
prompt SQL_ID:
set feed off term off
select '&1' my_sql_id from dual;

set feed on term on

prompt
prompt Days back for Begin SNAP_ID:
prompt

set term off feed off
select '&2' my_start_days_back from dual;
set term on feed on

prompt
prompt Days back for End SNAP_ID:
prompt

set term off feed off
select '&3' my_end_days_back from dual;
set term on feed on


-- change these as needed

var v_start_days_back number
var v_end_days_back number

begin
	:v_start_days_back := &my_start_days_back;
	-- must be GE start days
	:v_end_days_back := &my_end_days_back;
end;
/


@clear_for_spool

set serveroutput on size unlimited

spool '&file_prefix-exe-&my_sql_id..sql'

prompt
prompt host mkdir -p logs
prompt spool 'logs/&file_prefix-exe-&my_sql_id..log'

prompt set echo on

prompt set timing on pause off
prompt set linesize 200 trimspool on

prompt --alter session set statistics_level = 'TYPICAL';;
prompt --alter session set tracefile_identifier = '&my_sql_id-TEST';;
prompt --alter session set optimizer_use_invisible_indexes=true;;
prompt --alter session set events '10046 trace name context forever, level 12';;
prompt


-- do not set GT 2499
-- SQL statements input on sqlplus cmdline cannot be longer than 2499
set line 500

declare

	debug boolean := false;

	t_begin_interval timestamp;
	t_end_interval timestamp;

	type bindrectyp is record (
		snap_id number,
		bind_name varchar2(30),
		datatype_string varchar2(15),
		value_string varchar2(4000)
	);

	type bindnamerectyp is record (
		bind_name varchar2(30),
		datatype_string varchar2(15)
	);

	type bindtyp is table of bindrectyp index by varchar2(100);
	type bindnametyp is table of bindnamerectyp index by pls_integer;
	type tabtyp is table of varchar2(100) index by pls_integer;

	t_sql_id tabtyp;
	t_binds bindtyp;
	t_binds_empty bindtyp;
	t_bind_names bindnametyp;
	t_bind_names_empty bindnametyp;

	v_bind_key varchar(100);
	v_snap_id number := 0;

	v_sql clob;

	-- renames system generated bind var names
	-- renaming the bind place_holders was a mistake, as then the sql_id is not matched
	-- it was done because :1 is not a legal sqlplus var name
	-- use a pl/sql block and execute immediate, and leave the names as is
	cursor c_get_sql( v_sql_id_in varchar2 )
	is
	with first_iteration as (
		select sql_id, replace(sql_text,'SYS_B_','B_') sql_text
		from dba_hist_sqltext
		where sql_id = v_sql_id_in
	),
	second_iteration as (
		--select sql_id, regexp_replace(sql_text,':([[:digit:]]+)',':G' || '\1' ) sql_text
		select sql_id, sql_text
		from first_iteration
	)
	select sql_id, sql_text
	from second_iteration;

	/* new sql */

	cursor c_get_binds( v_sql_id_in varchar2 )
	is
	with data as (
	select
		b.snap_id, b.position
		, case
			when b.name like ':SYS_B_%' then substr(b.name,6)
			when regexp_like(b.name,'^:[[:digit:]]') then 'G' || substr(b.name,2)
			else b.name
		end name
		--, b.value_string
		--, b.datatype_string
		, anydata.GETTYPENAME(b.value_anydata) datatype_string
		-- use the anydata values as they are sometimes more reliable dependent on oracle version
		, case anydata.GETTYPENAME(b.value_anydata)
			when 'SYS.VARCHAR' then	 anydata.accessvarchar(b.value_anydata)
			when 'SYS.VARCHAR2' then anydata.accessvarchar2(b.value_anydata)
			when 'SYS.CHAR' then anydata.accesschar(b.value_anydata)
			when 'SYS.DATE' then to_char(anydata.accessdate(b.value_anydata),'yyyy-mm-dd hh24:mi:ss')
			when 'SYS.TIMESTAMP' then to_char(anydata.accesstimestamp(b.value_anydata),'yyyy-mm-dd hh24:mi:ss')
			when 'SYS.NUMBER' then to_char(anydata.accessnumber(b.value_anydata))
		end value_string
		,	b.last_captured
	from dba_hist_sqlbind  b
	join dba_hist_snapshot s on s.instance_number = b.instance_number
		and s.dbid = b.dbid
		and b.snap_id = s.snap_id
	where b.sql_id = v_sql_id_in
		and begin_interval_time between t_begin_interval and t_end_interval
		and b.instance_number =	 sys_context('userenv','instance')
	order by s.begin_interval_time, b.position, b.instance_number
	)
	select distinct
		snap_id
		, position
		, name
		, datatype_string
		, value_string
		, last_captured
	from data;

	/* ^^^ new sql ^^^ */

	cursor c_get_bind_names( v_sql_id_in varchar2 )
	is
	select distinct
		b.position
		-- convert the names of system generated bind variables
		-- these will ber SYS_B_ and just digits such as '1'
		, case
			when b.name like ':SYS_B_%' then substr(b.name,6)
			when regexp_like(b.name,'^:[[:digit:]]') then 'G'	|| substr(b.name,2)
			else b.name
		end name
		, datatype_string
	from dba_hist_sql_bind_metadata b
	where b.sql_id = v_sql_id_in
	order by position;

	procedure p (v_string_in varchar2)
	is
	begin
		dbms_output.put(v_string_in);
	end;

	procedure pl (v_string_in varchar2)
	is
	begin
		p(v_string_in);
		dbms_output.put_line('');
	end;

	procedure nl
	is
	begin
		dbms_output.new_line;
	end;

	procedure dout (v_string_in varchar2)
	is
	begin
		if ( debug ) then
			pl(v_string_in);
		end if;
	end;

begin

	t_begin_interval := systimestamp - numtodsinterval(:v_start_days_back,'day');
	t_end_interval := systimestamp - numtodsinterval(:v_end_days_back,'day');

	pl('-- Begin Interval Time: ' || t_begin_interval);
	pl('--	End Interval Time: ' || t_end_interval);
	pl('--');

	--t_sql_id(1) := '6pk8u51cuxykt';
	t_sql_id(1) := '&&my_sql_id';

	for i in t_sql_id.first ..t_sql_id.last
	loop
		--dout('working on ' || t_sql_id(i));
		-- get sql
		for sqlrec in c_get_sql(t_sql_id(i))
		loop
			v_sql := sqlrec.sql_text;

			--dout('-- V_SQL: ' || v_sql);
			--dout('working on child ' || sqlrec.child_number );
			--dout('###################################################');
			--dout('SQL:' || v_sql);

			-- get bind names into associative array
			t_bind_names := t_bind_names_empty;
			for bindnamerec in c_get_bind_names(sqlrec.sql_id)
			loop
				if substr(bindnamerec.name,1,1) = ':' then
					t_bind_names(bindnamerec.position).bind_name := substr(bindnamerec.name,2);
				else
					t_bind_names(bindnamerec.position).bind_name := bindnamerec.name;
				end if;
				t_bind_names(bindnamerec.position).datatype_string := bindnamerec.datatype_string;

				dout('-- ======= bind definitions =============================');
				dout('-- bind position: ' || bindnamerec.position);
				dout('-- bind name	 : ' || bindnamerec.name);
				dout('-- bind datatype: ' || bindnamerec.datatype_string);

			end loop;

			-- get binds into associative array
			t_binds := t_binds_empty; -- set binds table to null
			for bindrec in c_get_binds(sqlrec.sql_id)
			loop
				--t_binds(bindrec.position).bind_name := bindrec.name;
				--t_binds(bindrec.position).datatype_string := bindrec.datatype_string;
				--t_binds(bindrec.position).value_string := bindrec.value_string;

				v_bind_key := to_char(bindrec.snap_id) || ':' || to_char(bindrec.position);

				dout('-- ======= bind values =============================');

				-- at some point oracle started adding a ':' to the bind name
				-- we do not want a ': in the bind name
				if substr(bindrec.name,1,1) = ':' then
					--dout('	  setting bind name to substr');
					t_binds(v_bind_key).bind_name := substr(bindrec.name,2);
				else
					--dout('	  setting bind name to full name');
					t_binds(v_bind_key).bind_name := bindrec.name;
				end if;

				t_binds(v_bind_key).datatype_string := bindrec.datatype_string;
				t_binds(v_bind_key).value_string := bindrec.value_string;

				dout('-- bind snapid	 : ' || bindrec.snap_id);
				dout('-- bind position: ' || bindrec.position);
				--dout('-- bind name	  : ' || bindrec.name);
				--dout('-- bind datatype: ' || bindrec.datatype_string);
				--dout('-- value			 : ' || bindrec.value_string);
				dout('-- bind name	  % ' ||	 t_binds(v_bind_key).bind_name);
				dout('-- bind datatype: ' || t_binds(v_bind_key).datatype_string);
				dout('-- value			 : ' || t_binds(v_bind_key).value_string);

			end loop;


			-- create variable definitions
			for i in t_bind_names.first .. t_bind_names.last
			loop
				--p('var ' || substr(t_bind_names(i).bind_name,2));
				dout('-- set bind name	  % ' ||	 t_bind_names(i).bind_name);
				p('var ' || t_bind_names(i).bind_name);
				if t_bind_names(i).datatype_string like 'NUMBER%' then
					pl(' number');
				else
					pl(' varchar2(' ||
						substr(
							t_bind_names(i).datatype_string,
							instr(t_bind_names(i).datatype_string,
							'(')+1,instr(t_bind_names(i).datatype_string,')') - instr(t_bind_names(i).datatype_string,'(')-1
						) || ')'
					);
				end if;
			end loop;

/*

-- example PL/SQL block with dbms_sql

declare
	cursor_name integer;
	execReturnStatus integer; -- as per docs, the return value can be ignored for SELECT
	rc number := 0; -- row count
	v_sql clob;
begin
	cursor_name := dbms_sql.open_cursor;
	v_sql :=	 q'[SELECT CITY, STATE, NAME, ADDRESS FROM CUSTOMERS WHERE CUST_ID = :B1 AND STATUS = 'A']';
	dbms_sql.parse(cursor_name, v_sql,	dbms_sql.native);
	dbms_sql.bind_variable(cursor_name, ':B1', :G1);
	execReturnStatus := DBMS_SQL.EXECUTE(cursor_name);
	rc := dbms_sql.fetch_rows(cursor_name);
	dbms_sql.close_cursor(cursor_name);
	dbms_output.put_line('rows found: ' || rc);
exception
when no_data_found then
	dbms_output.put_line('no data found: ' ||	 rc);
end;

*/

			-- output pl/sql block
			-- the output may require editing after generation

			pl(chr(9));
			pl('declare');
			pl(q'[	cursor_name integer;]');
			pl(q'[	execReturnStatus integer; -- as per docs, the return value can be ignored for SELECT]');
			pl(q'[	rc number := 0; -- row count]');
			pl(q'[	v_sql clob;]');
			pl('begin');
			pl(q'[	cursor_name := dbms_sql.open_cursor;]');
			pl(q'[	v_sql :=	 q'[]' || v_sql || ']'';' );
			pl(q'[	dbms_sql.parse(cursor_name, v_sql,	dbms_sql.native);]');

			--pl(q'[	  -- modify generator code to catch all of the bind value]');
			--pl(q'[ dbms_sql.bind_variable(cursor_name, ':B1', :B1);]');


			-- bind the sql placeholders, if any
			for i in t_bind_names.first .. t_bind_names.last
			loop

				dout('-- set bind name	  % ' ||	 t_bind_names(i).bind_name);

				p(
					q'[	dbms_sql.bind_variable(cursor_name, ]'	 ||
					''':' || t_bind_names(i).bind_name || ''',' ||
					':' || t_bind_names(i).bind_name	 || ');'
				);

			end loop;

			pl(q'[	execReturnStatus := DBMS_SQL.EXECUTE(cursor_name);]');
			pl(q'[	rc := dbms_sql.fetch_rows(cursor_name);]');
			pl(q'[	dbms_sql.close_cursor(cursor_name);]');
			pl(q'[	dbms_output.put_line('rows: ' || rc);]');
			pl('exception');
			pl('when no_data_found then');
			pl(q'[	dbms_output.put_line('no data found: ' || rc);]');
			pl('end;');
			pl('/');
			pl(chr(9));


			v_bind_key := t_binds.first;

			-- key is formatted as 'snap_id:position'
			-- look for changes in snap_id then output the SQL

			while v_bind_key is not null
			loop

				v_snap_id := substr(v_bind_key,1,instr(v_bind_key,':')-1);

				dout('-- v_bind_key: ' || v_bind_key);

				p('exec :' || t_binds(v_bind_key).bind_name || ' := ');

				if t_binds(v_bind_key).datatype_string like 'NUMBER%' then
					pl(' to_number(''' || t_binds(v_bind_key).value_string || ''');');
				elsif t_binds(v_bind_key).datatype_string = 'DATE' then
					pl('to_date(''' || t_binds(v_bind_key).value_string || ''');');
				else
					pl('''' || t_binds(v_bind_key).value_string || ''';');
				end if;

				v_bind_key := t_binds.next(v_bind_key);

				if v_snap_id != substr(v_bind_key,1,instr(v_bind_key,':')-1) then
					pl('-- bind_key: ' || v_bind_key);
					--pl(v_sql || ';');
					pl('/');
				end if;

			end loop;

			-- get the last SQL exe in
			pl('/');

		end loop;
	end loop;

end;
/


prompt
prompt --alter session set events '10046 off';;
prompt --alter session set optimizer_use_invisible_indexes=false;;
prompt
prompt col tracefile_name new_value tracefile_name
prompt
prompt --select value tracefile_name from v$diag_info where name = 'Default Trace File';;
prompt
prompt --host mkdir -p trace
set scan off
prompt --host cp -p &tracefile_name trace
prompt

prompt spool off

spool off

prompt
prompt --prompt SQL in '&file_prefix-exe-&my_sql_id..sql'
prompt
set scan on

@clears
set line 80
undef 1 2

