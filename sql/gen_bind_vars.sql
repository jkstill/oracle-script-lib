
-- gen_bind_vars.sql
-- jared still 3/16/2010 - jkstill@gmail.com
-- given a SQL_ID get the SQL and bind variables
-- create a sqlplus script to run them
-- crude parsing of data types could use some refinement
-- works for what I need now

-- parameters:
-- 1: sql_id
-- 2: utl_file - write output to utl_file_dir if this is 'yes'
--    any other values disables utl_file output.
--    there must be a directory UTL_FILE_DIR to 
--    which you have access.


@clears

col my_sql_id new_value my_sql_id noprint
col utl_file_output new_value utl_file_output noprint

prompt
prompt SQL_ID: 
set feed off term off
select '&1' my_sql_id from dual;

set feed on term on
prompt
prompt Write UTL_FILE_DIR? Y/N: 
set feed off term off
select upper('&2') utl_file_output from dual;

@clear_for_spool

set line 4000

declare

	BUFSIZE integer := 4000;

	b_utl_file_out boolean := false;

	v_file_prefix varchar2(30) := 'sql_bind_gen';
	v_file_suffix varchar2(4) := '.sql';
	v_filename varchar2(100);
	v_directory varchar2(30) := 'UTL_FILE_DIR';
	f_handle utl_file.file_type;

	type bindrectyp is record (
		bind_name varchar2(30),
		datatype_string varchar2(15),
		value_string varchar2(4000)
	);

	type bindtyp is table of bindrectyp index by pls_integer;
	type tabtyp is table of varchar2(100) index by pls_integer;

	t_sql_id tabtyp;
	t_binds bindtyp;
	t_binds_empty bindtyp;

	v_sql varchar2(20000);

	cursor c_get_sql( v_sql_id_in varchar2 )
	is
	select sql_id, child_number,child_address, sql_text
	from v$sql
	where sql_id = v_sql_id_in
	order by child_number;

	cursor c_get_binds( v_sql_id_in varchar2, v_child_number_in number )
	is
	select position, name, datatype_string, value_string 
	from v$sql_bind_capture
	where sql_id = v_sql_id_in and child_number = v_child_number_in
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
			return f_handle;
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
			t_binds := t_binds_empty; -- set binds table to null
			-- get binds into associative array
			for bindrec in c_get_binds(sqlrec.sql_id, sqlrec.child_number)
			loop
				t_binds(bindrec.position).bind_name := bindrec.name;
				t_binds(bindrec.position).datatype_string := bindrec.datatype_string;
				t_binds(bindrec.position).value_string := bindrec.value_string;

				--pl('=================================================');
				--pl('bind position: ' || bindrec.position);
				--pl('bind name    : ' || bindrec.name);
				--pl('bind datatype: ' || bindrec.datatype_string);
				--pl('value        : ' || bindrec.value_string);

			end loop;

			v_filename := v_file_prefix || '_' || ltrim(to_char(sqlrec.child_number,'099')) || v_file_suffix;
			pl( v_filename);

			f_handle := fopen(v_directory,v_filename,'W',BUFSIZE);
			pl('--#### child ' || sqlrec.child_number);
			for i in t_binds.first .. t_binds.last
			loop
				p('var ' || substr(t_binds(i).bind_name,2));
				fp(f_handle,'var ' || substr(t_binds(i).bind_name,2));
				if t_binds(i).datatype_string like 'NUMBER%' then
					pl(' number');
					fpl(f_handle,' number');
				else
					pl(' varchar2(' || 
						substr(
							t_binds(i).datatype_string,
							instr(t_binds(i).datatype_string,
							'(')+1,instr(t_binds(i).datatype_string,')') - instr(t_binds(i).datatype_string,'(')-1
						) || ')'
					);

					fpl(f_handle,' varchar2(' || 
						substr(
							t_binds(i).datatype_string,
							instr(t_binds(i).datatype_string,
							'(')+1,instr(t_binds(i).datatype_string,')') - instr(t_binds(i).datatype_string,'(')-1
						) || ')'
					);
				end if;
			end loop;

			pl('begin');
			fpl(f_handle,'begin');
			for i in t_binds.first .. t_binds.last
			loop
				p(t_binds(i).bind_name || ' := ');
				fp(f_handle,t_binds(i).bind_name || ' := ');
				if t_binds(i).datatype_string like 'NUMBER%' then
					pl(' to_number(''' || t_binds(i).value_string || ''');');
					fpl(f_handle,' to_number(''' || t_binds(i).value_string || ''');');
				elsif t_binds(i).datatype_string = 'DATE' then
					pl('to_date(''' || t_binds(i).value_string || ''');');
					fpl(f_handle,'to_date(''' || t_binds(i).value_string || ''');');
				else
					pl('''' || t_binds(i).value_string || ''';');
					fpl(f_handle,'''' || t_binds(i).value_string || ''';');
				end if;
			end loop;
			pl('end;');
			pl('/');

			fpl(f_handle,'end;');
			fpl(f_handle,'/');

			pl(v_sql);
			pl('/');

			fpl(f_handle,v_sql);
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

