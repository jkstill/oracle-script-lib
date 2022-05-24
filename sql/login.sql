
-- setting server output on breaks dbms_plan.display_plan
-- just turn it on if needed
set serveroutput off format wrapped size unlimited

set sqlprompt "_USER'@'_CONNECT_IDENTIFIER _PRIVILEGE> "

define _editor=vi

set tab off

set pagesize 100
set linesize 200 trimspool off
set verify off
set pause off
set feed off

alter  session set statistics_level=all;
clear buffer
set feed on



