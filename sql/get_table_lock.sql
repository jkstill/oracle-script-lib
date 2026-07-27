
-- get_table_lock.sql
-- Jared Still
-- 


-- run a PL/SQL loop looking for a table lock
-- exit to SQLPlus command prompt when lock obtained

col table_to_lock new_value table_to_lock noprint
prompt Enter table name to lock:
set feed off termout off
select '&1' table_to_lock from dual;
set feed on termout on

var table_to_lock varchar2(128)
exec :table_to_lock := '&table_to_lock'

set linesize 200 trimspool on
set serveroutput on size 1000000

declare 
	v_sql varchar2(200) := 'lock table &table_to_lock in exclusive mode nowait';
	e_table_busy exception;
	pragma exception_init(e_table_busy,-54);
begin

	dbms_output.put_line(to_char(sysdate,'hh24:mi:ss') || ' - attempting to lock &table_to_lock');

	if (length(:table_to_lock) = 0 ) then
		raise_application_error(-20001,'Table name must be provided');
	end if;

	loop
		
		begin
			execute immediate v_sql;		
			exit;
		exception 
		when e_table_busy then
			dbms_output.put_line(to_char(sysdate,'hh24:mi:ss') || ' - waiting to lock &table_to_lock');
			dbms_lock.sleep(.5);
		when others then 
			raise;
		end;

	end loop;

	dbms_output.put_line(to_char(sysdate,'hh24:mi:ss') || ' - locked &table_to_lock');

end;
/




