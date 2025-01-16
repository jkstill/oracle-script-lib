
-- utl_file-test.sql
-- Jared Still

/*

 A simple test to make sure a directory is working

 Dir       Path
 TESTDIR   /u01/home/db-directories

 # groupadd abc
 # getent group abc
 # usermod -G abc -a oracle
 # id oracle
 # mkdir /home/u01/db-directories
 # chown nobody:abc /home/u01/db-directories
 # chmod g+w /home/u01/db-directories
 # ls -ld /home/u01/db-directories

  create or replace directory TESTDIR as '/home/u01/db-directories';

  grant read,write on directory TESTDIR to SCOTT;

  If the OS filesytem needs to be read and/or write capable by Oracle
  if a group is added to Oracle at the OS level to get file permissions,
  be sure to test through a sqlnet connection as a non-DBA user.

  It may be necessary to restart the database and listener to get the group permissions applied
 

*/


var dirname varchar2(300)
var testfile varchar2(100)


-- change names as needed in this block
-- eg. change :dirname to 'CSS_WM_CODESTABLE_DATA_DUMP_DIR'
begin
	:dirname := 'TESTDIR';
	:testfile := 'dir-test.txt';
end;
/


set serveroutput on size unlimited

-- do not edit this block unless it is necessary
declare

	i integer;

	v_file_exists boolean := FALSE;
	v_file_length pls_integer := 0;
	v_block_size pls_integer := 0;
	fh utl_file.file_type;
	v_max_line_length pls_integer := 4000;
	v_test_data varchar2(4000) := 'this is a test';
	v_read_data varchar2(4000);

	procedure pl(v_msg_in clob)
	is
	begin
		dbms_output.put_line(v_msg_in);
	end;

begin

	pl('getting file attributes for ' || :dirname || ':' || :testfile);
	utl_file.fgetattr(
		location       => :dirname,
		filename       => :testfile,
		fexists        => v_file_exists,
		file_length    => v_file_length,
		block_size     => v_block_size
	);

	if v_file_exists then
		pl('removing '  || :dirname || ':' || :testfile);
		utl_file.fremove (
			location => :dirname,
			filename  => :testfile
		);
	end if;


	pl('creating file ' || :dirname || ':' || :testfile);
	fh := utl_file.fopen (
		location       => :dirname,
		filename       => :testfile,
		open_mode      => 'w',
		max_linesize   => v_max_line_length
	);

	pl('writing file ' || :dirname || ':' || :testfile);
	utl_file.put_line (
		file      => fh,
		buffer    => v_test_data,
		autoflush => true
	);

	pl('closing file ' || :dirname || ':' || :testfile);
	utl_file.fclose( file => fh);

	pl('opening file for read ' || :dirname || ':' || :testfile);
	fh := utl_file.fopen (
		location       => :dirname,
		filename       => :testfile,
		open_mode      => 'r',
		max_linesize   => v_max_line_length
	);

	pl('reading file ' || :dirname || ':' || :testfile);
	utl_file.get_line (
		file     => fh,
		buffer   => v_read_data
	);

	if v_read_data != v_test_data then
		pl('data read is not the same as data written');
		pl('data written: ' || v_test_data);
		pl('data    read: ' || v_read_data);
	end if;

	pl('closing file ' || :dirname || ':' || :testfile);
	utl_file.fclose( file => fh);

	pl('removing '  || :dirname || ':' || :testfile);
	utl_file.fremove (
		location => :dirname,
		filename  => :testfile
	);

exception

	when utl_file.invalid_path then
		pl('invalid_path');
		pl(sqlerrm);
		raise;

	when utl_file.invalid_mode then
		pl('invalid_mode');
		pl(sqlerrm);
		raise;

	when utl_file.invalid_filehandle then
		pl('invalid_filehandle');
		pl(sqlerrm);
		raise;

	when utl_file.invalid_operation then
		pl('invalid_operation');
		pl(sqlerrm);
		raise;

	when utl_file.read_error then
		pl('read_error');
		pl(sqlerrm);
		raise;

	when utl_file.write_error then
		pl('write_error');
		pl(sqlerrm);
		raise;

	when utl_file.internal_error then
		pl('internal_error');
		pl(sqlerrm);
		raise;

	when others then
		pl('other write error');
		pl(sqlerrm);
		raise;

end;
/

