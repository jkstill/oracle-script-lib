
-- runs until told to die

set serveroutput on size unlimited
col idle_time_target new_value idle_time_target

select '&1' idle_time_target from dual;

declare
	v_control_command idle_user.idle_session_control.control_command%type;
begin

		while true
		loop
			select control_command into v_control_command from idle_user.idle_session_control;

			if v_control_command = 'DIE' then
				exit;
			elsif v_control_command = 'LIVE' then
				sys.dbms_lock.sleep(&idle_time_target);
			else
				dbms_output.put_line('something went wrong');
				exit;
			end if;
			
		end loop;

end;
/
