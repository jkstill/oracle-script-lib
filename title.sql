
-- title.sql - copied from title80.sql
-- specify line width when calling
-- eg @title 'report heading' 90

rem TITLE.SQL   -     This SQL*Plus script builds a standard report 
rem                   heading for database reports that are XX columns
rem
column  TODAY		NEW_VALUE 	CURRENT_DATE		NOPRINT
column  TIME            NEW_VALUE	CURRENT_TIME		NOPRINT
column  DATABASE        NEW_VALUE       DATA_BASE               NOPRINT
set term off feed off
rem
define COMPANY = "Jared Still"
define HEADING = "&1"
col cPageNumLoc new_value PageNumLoc noprint
select ('&&2' - 10 ) cPageNumLoc from dual;
rem
TTITLE LEFT "Date: " current_date CENTER company col &&PageNumLoc "Page:" format 999 -
       SQL.PNO SKIP 1 LEFT "Time: " current_time CENTER heading RIGHT -
       format a15 SQL.USER SKIP 1 CENTER format a20 data_base SKIP 2
rem
rem
set heading off
set pagesize 0
rem
column passout new_value dbname noprint
SELECT TO_CHAR(SYSDATE,'MM/DD/YY') TODAY,
       TO_CHAR(SYSDATE,'HH:MI AM') TIME,
       --DATABASE||' Database' DATABASE,
       --rtrim(database) passout
       name||' Database' DATABASE,
       lower(rtrim(name)) passout
FROM   v$database;
set term on feed on
rem
set heading on
set pagesize 58
set line &&2
set newpage 1
define db = '_&dbname'
undef 1 2
