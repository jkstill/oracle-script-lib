
-- show server event messages
-- courtesy Julian Dyke

set serveroutput on 

DECLARE
	err_msg VARCHAR2(1024);
BEGIN
	dbms_output.enable (null);
	FOR err_num IN 10000..10999
	LOOP
		err_msg := SQLERRM (-err_num);
		IF err_msg NOT LIKE '%Message '||err_num||' not found%' THEN
			dbms_output.put_line (err_msg);
		END IF;
	END LOOP;
END;
/

