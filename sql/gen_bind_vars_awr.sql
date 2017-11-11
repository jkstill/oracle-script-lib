
-- gen_bind_vars_awr.sql
-- jared still 2017-08-28 - jkstill@gmail.com, still@pythian.com
-- copied from gen_bind_vars.sql and modified for AWR
-- given a SQL_ID get the SQL and bind variables
-- create a sqlplus script to run them
-- crude parsing of data types could use some refinement
-- works for what I need now
--
-- jkstill 2017-11-10
-- refactored quite a bit 
-- no longer using utl_file due to SQL formatting issues
--
-- parameters:
-- 1: sql_id
/*

for this script utl_file is no longer being used.
The problem is that some SQL is over 2499 characters in length, and it may be stored as one line in the data dictionary
SQLPlus cannot execute lines that long

Formatting with PL/SQL and keeping the syntax legal was proving more difficult that necessary for this script.

So, spooled output from sqlplus is being used instead.

*/


@clears

col my_sql_id new_value my_sql_id noprint

prompt
prompt SQL_ID: 
set feed off term off
select '&1' my_sql_id from dual;

set feed on term on

@clear_for_spool

set serveroutput on size unlimited

spool 'sql-exe-&my_sql_id..sql'

prompt set timing on pause off
prompt set linesize 200 trimspool on

prompt -- alter session set events '10046 trace name context forever, level 12';
prompt -- alter session set tracefile_identifier = '&my_sql_id-TEST';


-- do not set GT 2499
-- SQL statements input on sqlplus cmdline cannot be longer than 2499
set line 500

declare

	debug boolean := false;

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
	t_bin_names_empty bindnametyp;

	v_bind_key varchar(100);
	v_snap_id number := 0;

	v_sql clob;

	cursor c_get_sql( v_sql_id_in varchar2 )
	is
	select sql_id, sql_text
	from dba_hist_sqltext
	where sql_id = v_sql_id_in;

	cursor c_get_binds( v_sql_id_in varchar2 )
	is
	select distinct snap_id, position, name, datatype_string, value_string, last_captured
	from dba_hist_sqlbind
	where sql_id = v_sql_id_in 
	order by snap_id, last_captured, position;

	cursor c_get_bind_names( v_sql_id_in varchar2 )
	is
	select distinct position, name, datatype_string
	from dba_hist_sqlbind
	where sql_id = v_sql_id_in 
		and snap_id = ( 
			select max(snap_id)
			from dba_hist_sqlbind
			where sql_id = v_sql_id_in
		)
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

	procedure dout (v_string_in varchar2)
	is
	begin
		if ( debug ) then
			pl(v_string_in);
		end if;
	end;

begin

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
			t_bind_names := t_bin_names_empty;
			for bindnamerec in c_get_bind_names(sqlrec.sql_id)
			loop
					t_bind_names(bindnamerec.position).bind_name := bindnamerec.name;
					t_bind_names(bindnamerec.position).datatype_string := bindnamerec.datatype_string;

					dout('-- ======= bind definitions =============================');
					dout('-- bind position: ' || bindnamerec.position);
					dout('-- bind name    : ' || bindnamerec.name);
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

				t_binds(v_bind_key).bind_name := bindrec.name;
				t_binds(v_bind_key).datatype_string := bindrec.datatype_string;
				t_binds(v_bind_key).value_string := bindrec.value_string;

				dout('-- ======= bind values =============================');
				dout('-- bind snapid  : ' || bindrec.snap_id);
				dout('-- bind position: ' || bindrec.position);
				dout('-- bind name	  : ' || bindrec.name);
				dout('-- bind datatype: ' || bindrec.datatype_string);
				dout('-- value        : ' || bindrec.value_string);

			end loop;

			-- create variable definitions
			for i in t_bind_names.first .. t_bind_names.last
			loop
				p('var ' || substr(t_bind_names(i).bind_name,2));
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

					pl(' varchar2(' || 
						substr(
							t_bind_names(i).datatype_string,
							instr(t_bind_names(i).datatype_string,
							'(')+1,instr(t_bind_names(i).datatype_string,')') - instr(t_bind_names(i).datatype_string,'(')-1
						) || ')'
					);
				end if;
			end loop;

			pl('	');
			pl(v_sql);  
			pl('	');

			v_bind_key := t_binds.first;

			-- key is formatted as 'snap_id:position'
			-- look for changes in snap_id then output the SQL

			while v_bind_key is not null
			loop

				v_snap_id := substr(v_bind_key,1,instr(v_bind_key,':')-1);

				p('exec ' || t_binds(v_bind_key).bind_name || ' := ');

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

spool off

prompt -- alter session set events '10046 off';
prompt -- select '-- ' || value tracefile_name from v$diag_info where name = 'Default Trace File';

prompt
prompt SQL in 'sql-exe-&my_sql_id..sql'
prompt

@clears
set line 80
undef 1 2


