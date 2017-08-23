

-- print_table_2.sql
-- based on the script by Tom Kyte @ Oracle
-- this script uses and anonymous block, not a stored procedure
-- pass the entire SQL to the script
-- @print_table 'select * from dual'
-- see http://asktom.oracle.com/pls/apex/f?p=100:11:0::::P11_QUESTION_ID:4845523000346615725

prompt

set feed on
SET verify OFF serveroutput on size unlimited

DECLARE
	l_theCursor   INTEGER DEFAULT dbms_sql.open_cursor;
	l_columnValue VARCHAR2 ( 4000 ) ;
	l_status		  INTEGER;
	l_descTbl dbms_sql.desc_tab;
	l_colCnt NUMBER;
PROCEDURE execute_immediate ( p_sql IN VARCHAR2)
IS
BEGIN
	dbms_sql.parse ( l_theCursor, p_sql, dbms_sql.native ) ;
	l_status := dbms_sql.execute ( l_theCursor ) ;
END;
PROCEDURE p ( p_str IN VARCHAR2)
IS
	l_str LONG := p_str;
BEGIN
	LOOP
		EXIT
	WHEN l_str IS NULL;
		dbms_output.put_line ( SUBSTR ( l_str, 1, 250 ) ) ;
		l_str := SUBSTR ( l_str, 251 ) ;
	END LOOP;
END;
BEGIN
	execute_immediate ( 'alter session set nls_date_format=''dd-mon-yyyy hh24:mi:ss'' ' ) ;
	dbms_sql.parse ( l_theCursor, REPLACE ( '&1', '"', '''' ), dbms_sql.native ) ;
	dbms_sql.describe_columns ( l_theCursor, l_colCnt, l_descTbl ) ;
	FOR i IN 1 .. l_colCnt
	LOOP
		dbms_sql.define_column ( l_theCursor, i, l_columnValue, 4000 ) ;
	END LOOP;
	l_status	:= dbms_sql.execute ( l_theCursor ) ;
	WHILE ( dbms_sql.fetch_rows ( l_theCursor ) > 0 )
	LOOP
		FOR i IN 1 .. l_colCnt
		LOOP
			dbms_sql.column_value ( l_theCursor, i, l_columnValue ) ;
			p ( rpad ( l_descTbl ( i ) .col_name, 30 )
			|| ': '
			|| l_columnValue);
		END LOOP;
		dbms_output.put_line ( '-----------------' ) ;
	END LOOP;
	dbms_sql.close_cursor(l_theCursor);
END;
/

prompt


