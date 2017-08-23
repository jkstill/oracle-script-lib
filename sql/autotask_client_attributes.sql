
@@autotask_sql_setup

declare
	v_service_name varchar2(100);
	v_window_group varchar2(100);
	v_pad_char char(1) := '-';
	v_pad_len number(4) := 50;
begin

	dbms_output.put_line(rpad(v_pad_char,v_pad_len,v_pad_char));

	for crec in (
		select client_name
		from DBA_AUTOTASK_CLIENT
	)
	loop
		dbms_auto_task_admin.get_client_attributes(
			crec.client_name,
			v_service_name,
			v_window_group
		);

		dbms_output.put_line('CLIENT    : ' ||crec.client_name);
		dbms_output.put_line('SERVICE   : ' ||v_service_name);
		dbms_output.put_line('WINDOW GRP: ' ||v_window_group);
		dbms_output.put_line(rpad(v_pad_char,v_pad_len,v_pad_char));

	end loop;
end;
/

