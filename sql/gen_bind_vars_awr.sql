
-- gen_bind_vars_awr.sql
-- jared still 2017-08-28 - jkstill@gmail.com, still@pythian.com
-- copied from gen_bind_vars.sql and modified for AWR
-- given a SQL_ID get the SQL and bind variables
-- create a sqlplus script to run them
-- crude parsing of data types could use some refinement
-- works for what I need now

-- parameters:
-- 1: sql_id
-- 2: utl_file - write output to utl_file_dir if this is 'y'
--		any other values disables utl_file output.
--		there must be a directory DB Directory
--		which you have access.


-- directory to write to
define u_dba_dir='MYDIR'


-- use this to examine dba_directories
/*

col owner format a30
col directory_name format a30
col directory_path format a120

set linesize 200 trimspool on
set pagesize 100

select *
from dba_directories
order by owner, directory_name;

*/


@clears

col my_sql_id new_value my_sql_id noprint
col utl_file_output new_value utl_file_output noprint

prompt
prompt SQL_ID: 
set feed off term off
select '&1' my_sql_id from dual;

set feed on term on
prompt
prompt Write &u_dba_dir? Y/N: 
set feed off term off
select upper('&2') utl_file_output from dual;

@clear_for_spool

set serveroutput on size unlimited

set line 4000

declare

	BUFSIZE integer := 4000;

	b_utl_file_out boolean := false;

	v_file_prefix varchar2(30) := 'sql_bind_gen';
	v_file_suffix varchar2(4) := '.sql';
	v_filename varchar2(100);
	v_directory varchar2(30) := '&u_dba_dir';
	f_handle utl_file.file_type;

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

	v_sql varchar2(20000);

	cursor c_get_sql( v_sql_id_in varchar2 )
	is
	select sql_id, sql_text
	--from v$sql
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
		dbms_output.put_line(v_string_in);
	end;

	procedure fp (f_handle_in utl_file.file_type, v_string_in varchar2)
	is
	begin
		if b_utl_file_out then
			utl_file.put(f_handle_in,v_string_in);
		end if;
	end;

	procedure fpl (f_handle_in utl_file.file_type, v_string_in varchar2)
	is
	begin
		if b_utl_file_out then
			utl_file.put_line(f_handle_in,v_string_in);
		end if;
	end;

	function fopen ( v_directory_in varchar2, v_filename_in varchar2, v_mode_in varchar2,i_bufsize_in integer)
	return utl_file.file_type
	is
		f_handle utl_file.file_type;
	begin
		if b_utl_file_out then
			f_handle := utl_file.fopen(v_directory_in,v_filename_in,v_mode_in,i_bufsize_in);
			if utl_file.is_open(f_handle) then
				pl('Opened file: '  || v_filename_in  || ' in ' || v_directory_in);
				return f_handle;
			else
				raise_application_error(-20000,'error opening ' || v_filename_in );
			end if;
		else 
			return null;
		end if;
	end;

begin

	if '&&utl_file_output' = 'Y' then
		b_utl_file_out := true;
	end if;

	--t_sql_id(1) := '6pk8u51cuxykt';
	t_sql_id(1) := '&&my_sql_id';
	
	for i in t_sql_id.first ..t_sql_id.last
	loop
		--pl('working on ' || t_sql_id(i));
		-- get sql
		for sqlrec in c_get_sql(t_sql_id(i))
		loop
			v_sql := sqlrec.sql_text;
			--pl('working on child ' || sqlrec.child_number );
			--pl('###################################################');
			--pl('SQL:' || v_sql);

			-- get bind names into associative array
			t_bind_names := t_bin_names_empty;
			for bindnamerec in c_get_bind_names(sqlrec.sql_id)
			loop
					t_bind_names(bindnamerec.position).bind_name := bindnamerec.name;
					t_bind_names(bindnamerec.position).datatype_string := bindnamerec.datatype_string;

					pl('======= bind definitions =============================');
					pl('bind position: ' || bindnamerec.position);
					pl('bind name    : ' || bindnamerec.name);
					pl('bind datatype: ' || bindnamerec.datatype_string);

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

				pl('======= bind values =============================');
				pl('bind snapid  : ' || bindrec.snap_id);
				pl('bind position: ' || bindrec.position);
				pl('bind name	  : ' || bindrec.name);
				pl('bind datatype: ' || bindrec.datatype_string);
				pl('value        : ' || bindrec.value_string);

			end loop;

			v_filename := v_file_prefix || '_' || sqlrec.sql_id || v_file_suffix;
			pl( v_filename);

			f_handle := fopen(v_directory,v_filename,'W',BUFSIZE);

			-- create variable definitions
			for i in t_bind_names.first .. t_bind_names.last
			loop
				p('var ' || substr(t_bind_names(i).bind_name,2));
				fp(f_handle,'var ' || substr(t_bind_names(i).bind_name,2));
				if t_bind_names(i).datatype_string like 'NUMBER%' then
					pl(' number');
					fpl(f_handle,' number');
				else
					pl(' varchar2(' || 
						substr(
							t_bind_names(i).datatype_string,
							instr(t_bind_names(i).datatype_string,
							'(')+1,instr(t_bind_names(i).datatype_string,')') - instr(t_bind_names(i).datatype_string,'(')-1
						) || ')'
					);

					fpl(f_handle,' varchar2(' || 
						substr(
							t_bind_names(i).datatype_string,
							instr(t_bind_names(i).datatype_string,
							'(')+1,instr(t_bind_names(i).datatype_string,')') - instr(t_bind_names(i).datatype_string,'(')-1
						) || ')'
					);
				end if;
			end loop;

			pl('begin');
			fpl(f_handle,'begin');

			v_bind_key := t_binds.first;

			-- key is formatted as 'snap_id:position'
			-- look for changes in snap_id then output the SQL

			while v_bind_key is not null
			loop

				v_snap_id := substr(v_bind_key,1,instr(v_bind_key,':')-1);

				p(t_binds(v_bind_key).bind_name || ' := ');
				fp(f_handle,t_binds(v_bind_key).bind_name || ' := ');

				if t_binds(v_bind_key).datatype_string like 'NUMBER%' then
					pl(' to_number(''' || t_binds(v_bind_key).value_string || ''');');
					fpl(f_handle,' to_number(''' || t_binds(v_bind_key).value_string || ''');');
				elsif t_binds(v_bind_key).datatype_string = 'DATE' then
					pl('to_date(''' || t_binds(v_bind_key).value_string || ''');');
					fpl(f_handle,'to_date(''' || t_binds(v_bind_key).value_string || ''');');
				else
					pl('''' || t_binds(v_bind_key).value_string || ''';');
					fpl(f_handle,'''' || t_binds(v_bind_key).value_string || ''';');
				end if;

				v_bind_key := t_binds.next(v_bind_key);

				if v_snap_id != substr(v_bind_key,1,instr(v_bind_key,':')-1) then
					pl('bind_key: ' || v_bind_key);
					pl(v_sql);
					pl('/');
					fpl(f_handle,v_sql);
					fpl(f_handle,'/');
				end if;

			end loop;
			pl('end;');
			pl('/');

			fpl(f_handle,'end;');
			fpl(f_handle,'/');


			if b_utl_file_out then
				utl_file.fclose(f_handle);
			end if;
			
		end loop;
	end loop;

end;
/


@clears
set line 80
undef 1 2

