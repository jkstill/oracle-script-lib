
-- defaults.sql:
-- jared still
-- 2024-10-25
--------------
/*

-- technique to use defaults for susbstitution variables found at: https://vbegun.blogspot.com/2008/04/on-sqlplus-defines.html

This script is used to set default values for substitution variables.

Then nvl() can be used in scripts to assign default values to undefined parameters.

See defaults-demo.sql for an example of how to use this script.

*/

set echo off
set verify off
set feedback off

-- Assign null to undefined parameters
column a new_value 1
column b new_value 2
column c new_value 3
column d new_value 4
column e new_value 5
column f new_value 6
column g new_value 7
column h new_value 8
column i new_value 9

select '' a,'' b, '' c, '' d, '' e, '' f, '' g, '' h, '' i from dual where rownum=0;

