
set echo on

begin


	-- v$session.client_info
	dbms_application_info.set_client_info('Test - 64 Characters Max');

end;
/

accept x prompt "Press <ENTER>"

begin

	-- v$sqlarea.module
	-- v$sqlarea.action
	-- or dbms_application_info.read_module()
	dbms_application_info.set_module(
		module_name => 'Test Module',
		action_name => 'Action 1'
	);

	dbms_lock.sleep(10);

end;
/

accept x prompt "Press <ENTER>"

begin

	dbms_application_info.set_action(
	      action_name => null
	);

end;
/

set echo off

