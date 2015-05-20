rem TITLE132.SQL -     This SQL*Plus script builds a standard report 
rem                             heading for database reports that are 132 columns 
rem
column  TODAY        NEW_VALUE      CURRENT_DATE   NOPRINT
column  TIME           NEW_VALUE       CURRENT_TIME   NOPRINT
column  DATABASE NEW_VALUE       DATA_BASE         NOPRINT
column  PASSOUT   NEW_VALUE       DBNAME              NOPRINT
rem
define COMPANY = "Jared Still"
define HEADING = "&1"
rem
TTITLE LEFT "Date: " current_date CENTER company col 118 "Page:" format 999 -
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
rem
set heading on
set pagesize 58
set line 132
set newpage 0
DEFINE DB = '_&DBNAME'

