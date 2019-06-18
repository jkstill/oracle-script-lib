
-- disable automatics tasks
-- useful for test systems with limited resources

declare

	type window_array_typ is table of varchar2(30);
	window_array window_array_typ := window_array_typ('SUNDAY_WINDOW','MONDAY_WINDOW','TUESDAY_WINDOW','WEDNESDAY_WINDOW','THURSDAY_WINDOW','FRIDAY_WINDOW','SATURDAY_WINDOW');
	
begin


	for window in window_array.first .. window_array.last
	loop

		dbms_output.put_line('Disabling stats job for: ' || window_array(window));
	
		DBMS_AUTO_TASK_ADMIN.DISABLE(
			client_name		=> 'auto optimizer stats collection',
			operation		=> 'auto optimizer stats job',
			window_name 	=>  window_array(window)
		);

	end loop;

end;
/


