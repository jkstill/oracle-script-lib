

set serveroutput on size unlimited

create or replace procedure list_bdump_2
is
	ns          VARCHAR2(1024);
	v_directory VARCHAR2(1024);
	fcount integer;
BEGIN
	v_directory := 'BDUMP_2';
	SYS.DBMS_BACKUP_RESTORE.SEARCHFILES(v_directory, ns);
	select count(*) into fcount from x$krbmsft;
	DBMS_OUTPUT.PUT_LINE('fcount: ' || fcount);
	FOR each_file IN (SELECT fname_krbmsft AS name FROM x$krbmsft) LOOP
		DBMS_OUTPUT.PUT_LINE(each_file.name);
	END LOOP;
END;
/


show errors procedure list_bdump_2
