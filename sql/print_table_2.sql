

-- print_table_2.sql
-- based on the script by Tom Kyte @ Oracle
-- this script uses and anonymous block, not a stored procedure
-- pass the entire SQL to the script
-- @print_table 'select * from dual'
-- see http://asktom.oracle.com/pls/apex/f?p=100:11:0::::P11_QUESTION_ID:4845523000346615725
-- Jared Still - 2023 - added sorting of column names

/*

To simplify quoting, use double quotes for literals.

The PL/SQL will replace the double quotes with single quotes before parsing

SQL#  @print_table_2 'select * from v$archive_dest_status where status != "INACTIVE"'

parse next
DEST_ID                       : 1
DEST_NAME                     : LOG_ARCHIVE_DEST_1
STATUS                        : VALID
TYPE                          : LOCAL
DATABASE_MODE                 : OPEN
RECOVERY_MODE                 : IDLE
PROTECTION_MODE               : MAXIMUM PERFORMANCE
DESTINATION                   : +FRA
STANDBY_LOGFILE_COUNT         : 0
STANDBY_LOGFILE_ACTIVE        : 0
ARCHIVED_THREAD#              : 1
ARCHIVED_SEQ#                 : 6000
APPLIED_THREAD#               : 0
APPLIED_SEQ#                  : 0
ERROR                         :
SRL                           : NO
DB_UNIQUE_NAME                : NONE
SYNCHRONIZATION_STATUS        : CHECK CONFIGURATION
SYNCHRONIZED                  : NO
GAP_STATUS                    :
CON_ID                        : 0
-----------------

PL/SQL procedure successfully completed.

*/

-- a blank string selects sorted/unsorted
def sorted=''
def unsorted='--'

prompt

set feed on
SET verify OFF serveroutput on size unlimited

DECLARE
	l_theCursor   INTEGER DEFAULT dbms_sql.open_cursor;
	l_columnValue VARCHAR2 ( 4000 ) ;
	l_status		  INTEGER;
	l_descTbl dbms_sql.desc_tab;
	l_colCnt NUMBER;
	type sort_typ is table of integer index by varchar2(30);
	sort_table sort_typ;
	s_idx varchar2(50);
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
		sort_table(l_descTbl(i).col_name) := i;
	END LOOP;

	FOR i IN 1 .. l_colCnt
	LOOP
		dbms_sql.define_column ( l_theCursor, i, l_columnValue, 4000 ) ;
	END LOOP;
	l_status	:= dbms_sql.execute ( l_theCursor ) ;
	WHILE ( dbms_sql.fetch_rows ( l_theCursor ) > 0 )
	LOOP
		s_idx := sort_table.first;
		-- unsorted
		&unsorted FOR i IN 1 .. l_colCnt
		--sorted
		&sorted WHILE s_idx IS NOT NULL
		LOOP
			-- unsorted
			&unsorted dbms_sql.column_value ( l_theCursor, i, l_columnValue ) ;
			&unsorted p ( rpad ( l_descTbl ( i ).col_name, 30 )
			&unsorted || ': '
			&unsorted || l_columnValue);
			-- unsorted

			-- sorted
			&sorted dbms_sql.column_value ( l_theCursor, sort_table(s_idx), l_columnValue ) ;
			&sorted p ( rpad ( l_descTbl ( sort_table(s_idx) ) .col_name, 30 )
			&sorted || ': '
			&sorted || l_columnValue);
			-- sorted

			s_idx := sort_table.next(s_idx);		  
		END LOOP;
		dbms_output.put_line ( '-----------------' ) ;
	END LOOP;
	dbms_sql.close_cursor(l_theCursor);
END;
/

prompt


