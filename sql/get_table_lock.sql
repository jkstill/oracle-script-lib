
-- get_table_lock.sql
-- Jared Still
-- 


-- run a PL/SQL loop looking for a table lock
-- exit to SQLPlus command prompt when lock obtained

define table_to_lock=locktest

declare 
	v_sql varchar2(200) := 'lock table &table_to_lock in exclusive mode nowait';
	e_table_busy exception;
	pragma exception_init(e_table_busy,-54);
begin


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
	

end;
/




