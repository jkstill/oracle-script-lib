
-- show server event messages
-- courtesy Julian Dyke

set serveroutput on size 1000000
DECLARE
	err_msg VARCHAR2(120);
BEGIN
	dbms_output.enable (1000000);
	FOR err_num IN 10000..10999
	LOOP
		err_msg := SQLERRM (-err_num);
		IF err_msg NOT LIKE '%Message '||err_num||' not found%' THEN
			dbms_output.put_line (err_msg);
		END IF;
	END LOOP;
END;
/

