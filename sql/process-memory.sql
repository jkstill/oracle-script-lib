
-- process-memory.sql
-- Jared Still - jkstill@gmail.com
-- combination of scripts from Charles Hooper and Tom Kyte
-- slightly modified for CDB/PDB/RAC


prompt

var v_sql clob

begin

-- this v$process SQL from Charles Hoooper
-- https://hoopercharles.wordpress.com/2010/02/03/open-cursor-leaks-identifying-the-problem/

:v_sql := q'[SELECT
  S.CON_ID,
  S.INST_ID,
  S.SID,
  P.PID,
  P.SPID,
  P.PROGRAM,
  S.PROGRAM,
  S.USERNAME,
  P.PGA_USED_MEM,
  P.PGA_ALLOC_MEM,
  P.PGA_FREEABLE_MEM,
  P.PGA_MAX_MEM,
  PM.SQL_ALLOCATED,
  PM.SQL_USED,
  PM.SQL_MAX_ALLOCATED,
  PM.PLSQL_ALLOCATED,
  PM.PLSQL_USED,
  PM.PLSQL_MAX_ALLOCATED,
  PM.OLAP_ALLOCATED,
  PM.OLAP_USED,
  PM.OLAP_MAX_ALLOCATED,
  PM.JAVA_ALLOCATED,
  PM.JAVA_USED,
  PM.JAVA_MAX_ALLOCATED,
  PM.OTHER_ALLOCATED,
  PM.OTHER_USED,
  PM.OTHER_MAX_ALLOCATED,
  PM.FREEABLE_ALLOCATED
FROM
  GV$PROCESS P,
  GV$SESSION S,
  (SELECT
	 CON_ID,
	 INST_ID,
	 PID,
	 SERIAL#,
	 MAX(DECODE(CATEGORY,'SQL',ALLOCATED,0)) SQL_ALLOCATED,
	 MAX(DECODE(CATEGORY,'SQL',USED,0)) SQL_USED,
	 MAX(DECODE(CATEGORY,'SQL',MAX_ALLOCATED,0)) SQL_MAX_ALLOCATED,
	 MAX(DECODE(CATEGORY,'PL/SQL',ALLOCATED,0)) PLSQL_ALLOCATED,
	 MAX(DECODE(CATEGORY,'PL/SQL',USED,0)) PLSQL_USED,
	 MAX(DECODE(CATEGORY,'PL/SQL',MAX_ALLOCATED,0)) PLSQL_MAX_ALLOCATED,
	 MAX(DECODE(CATEGORY,'OLAP',ALLOCATED,0)) OLAP_ALLOCATED,
	 MAX(DECODE(CATEGORY,'OLAP',USED,0)) OLAP_USED,
	 MAX(DECODE(CATEGORY,'OLAP',MAX_ALLOCATED,0)) OLAP_MAX_ALLOCATED,
	 MAX(DECODE(CATEGORY,'JAVA',ALLOCATED,0)) JAVA_ALLOCATED,
	 MAX(DECODE(CATEGORY,'JAVA',USED,0)) JAVA_USED,
	 MAX(DECODE(CATEGORY,'JAVA',MAX_ALLOCATED,0)) JAVA_MAX_ALLOCATED,
	 MAX(DECODE(CATEGORY,'Other',ALLOCATED,0)) OTHER_ALLOCATED,
	 MAX(DECODE(CATEGORY,'Other',USED,0)) OTHER_USED,
	 MAX(DECODE(CATEGORY,'Other',MAX_ALLOCATED,0)) OTHER_MAX_ALLOCATED,
	 MAX(DECODE(CATEGORY,'Freeable',ALLOCATED,0)) FREEABLE_ALLOCATED
  FROM
	 GV$PROCESS_MEMORY
  GROUP BY
	 CON_ID,INST_ID,PID,
	 SERIAL#) PM
WHERE
  P.ADDR=S.PADDR(+)
  AND P.CON_ID = S.CON_Id
  and P.INST_ID = S.INST_ID
  AND P.PID=PM.PID
  AND P.SERIAL#=PM.SERIAL#
  AND P.CON_ID = PM.CON_ID
  AND P.INST_ID = PM.INST_ID
  and	 s.username is not null
ORDER BY
PGA_ALLOC_MEM ]';
end;
/


set feed on
SET verify OFF serveroutput on size unlimited


-- print_table_2.sql
-- based on the script by Tom Kyte @ Oracle
-- this script uses and anonymous block, not a stored procedure
-- pass the entire SQL to the script
-- @print_table 'select * from dual'
-- see http://asktom.oracle.com/pls/apex/f?p=100:11:0::::P11_QUESTION_ID:4845523000346615725


DECLARE
	l_theCursor	  INTEGER DEFAULT dbms_sql.open_cursor;
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
	dbms_sql.parse ( l_theCursor, REPLACE ( :v_sql, '"', '''' ), dbms_sql.native ) ;
	dbms_sql.describe_columns ( l_theCursor, l_colCnt, l_descTbl ) ;
	FOR i IN 1 .. l_colCnt
	LOOP
		dbms_sql.define_column ( l_theCursor, i, l_columnValue, 4000 ) ;
	END LOOP;
	l_status := dbms_sql.execute ( l_theCursor ) ;
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

