
-- ashdump.sql
-- Jared Still -  
--  jkstill@gmail.com
--
-- see the example 'ashdump-summary.sql' for viewing the data

/*

Dump the contents of ASH for the past N minutes

Oracle Support Note 243132.1 desribes how to get an ASH dump.

This note is still mostly useful. 

The 4 scripts mentioned in for loading and processing ASH are no longer useful.
ie. they do not work.

Oracle Support Note 555303.1 contains those scripts.

As of at least Oracle 11.2 those scripts are completely unnecessary

When ASH Dump trace file is created, it will include the following commands:

- DDL to build the ASHDUMP table
- The contents of the sqlldr script ashldr.ctl
- The sqlldr command to load the ASHDUMP table.

=== Container Databases ====

When taking an ASH Dump, you need to do it from the CDB, not the PDB.

This is true as of Oracle 19.3

For RAC systems, a separate ASH dump needs to be made per node, as required.


Finally, there is a script 'ashdump-summary.sql' that is an example of viewing the ASHDUMP table.

Actually, any script that works with ASH should work with ASHDUMP just by changing references
to 'v$active_session_history' to 'ashdump'

*/

col filename format a100

set echo off pause off tab off verify off

prompt ASH Dump of how many minutes?: 

set term off feed off echo off pause off tab off

col v_ash_minutes new_value v_ash_minutes noprint

select &1 v_ash_minutes from dual;

set term on feed on echo on

oradebug setmypid
oradebug dump ashdump &v_ash_minutes

set echo off

select value filename from v$diag_info where name = 'Default Trace File';



