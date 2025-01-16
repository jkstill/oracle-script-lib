
-- setc.sql
-- set container
-- 2020   jkstill@gmail.com
--
-- see comments for restrictions on use

/*

 usage: @setc [-|con_name|con_id]

 -: this will display a list of PDBs
    type a con_name or con_id

 con_id:  switch to this con_id

 con_name: switch to this con_name


  SQL# @setc 3

  V_PDB_MSG
  ----------------------------------------
  Results: Switched Containers


  CON_ID CON_NAME
  ------ ---------------
       3 PDB1

 ===========================================================

  SQL# @setc pdb4

  V_PDB_MSG
  ----------------------------------------
  Results: Switched Containers


  CON_ID CON_NAME
  ------ ---------------
       6 PDB4


 ===========================================================

  SQL# @setc -

  CON_ID PDB_NAME
  ------ --------------------
       2 PDB$SEED
       3 PDB1
       4 PDB2
       5 PDB3
       6 PDB4
  Which PDB?:
  1

  V_PDB_MSG
  ----------------------------------------
  Results: Switched Containers


  CON_ID CON_NAME
  ------ ---------------
       1 CDB$ROOT

 ===========================================================

  SQL# @setc 12

  A non-existent PDB was requested

  V_PDB_MSG
  ----------------------------------------
  Results: Did NOT Switch Containers


  CON_ID CON_NAME
  ------ ---------------
       1 CDB$ROOT

*/

/*

as per 'Security Concepts in Oracle Multitenant'
https://www.oracle.com/technetwork/database/multitenant/learn-more/multitenant-security-concepts-12c-2402462.pdf

  "Although developers may think that they can use “execute immediatealter session set container”
  to switch between two containers inside a pl/sql procedure, function or package it is blocked 
  from execution from within a PDB."


 this only works when current container is cdb$root
 otherwise, 'ORA-01031: insufficient privileges' is raised, even as SYS

 SQL# 
 select
    sys_context('userenv','con_id') con_id
    , sys_context('userenv','con_name') con_name
	   4  from dual;
 
	 CON_ID CON_NAME
	 ------ ---------------
         4      PDB2

 1 row selected.

  SQL# begin
   2  execute immediate 'alter session set container=pdb3';
   3  end;
   4  /
 begin
	 *
	 ERROR at line 1:
	 ORA-01031: insufficient privileges
	 ORA-06512: at line 2

 Due to these restrictions, this script only works with SYS privileges

*/

set feedback off term off pause off echo off
@save-sqlplus-settings

--set serveroutput on size unlimited  format word_wrapped
set serveroutput on size unlimited
set feedback off term off verify off echo off pause off

var v_pdb_msg varchar2(60)
exec :v_pdb_msg := 'Results: Switched Containers '

col u_session_container new_value s_session_container noprint format a20

col pdb_name format a20
col con_id format 9999
var v_session_container varchar2(30)
exec :v_session_container:='&1'

-- if the input is '-' display all pdb and prompt for input

--set feed on term on echo on

col u_display_pdbs new_value u_display_pdbs noprint
col u_do_not_display_pdbs new_value u_do_not_display_pdbs noprint

col db_name format a15
col open_mode format a10
col con_name format a15

select 
	decode(:v_session_container,'-','','--') u_display_pdbs 
	, decode(:v_session_container,'-','--','') u_do_not_display_pdbs
from dual;

-- reset the value for v_session_container

alter session set container=cdb$root;

set term on

-- specified '-' on the CLI
/*
select 
	&u_display_pdbs con_id, name pdb_name
	&u_do_not_display_pdbs dummy
&u_display_pdbs from v$pdbs order by con_id
&u_do_not_display_pdbs from dual where 0=1
union 
select
&u_display_pdbs 1 con_id, 'CDB$ROOT' pdb_name
& u_do_not_display_pdbs 'noop' from dual where 1=0
/
*/

--/*

select
	&u_display_pdbs con_id, name pdb_name
	&u_do_not_display_pdbs dummy
&u_display_pdbs from v$pdbs
&u_do_not_display_pdbs from dual where 0=1
union
select
&u_display_pdbs 1 con_id, 'CDB$ROOT' pdb_name from dual
& u_do_not_display_pdbs 'noop' from dual where 1=0
order by 1
/
--*/


begin
	&u_display_pdbs dbms_output.put_line('Which PDB?: ');
	null;
end;
/
set term off


-- specified PDB on CLI
select
	&u_do_not_display_pdbs :v_session_container u_session_container
	&u_display_pdbs dummy
&u_do_not_display_pdbs from dual
&u_display_pdbs from dual where 0=1
/


-- now set v_session_container to the value from the select
exec :v_session_container:='&s_session_container'

--pause

set term on

declare
	not_allowed exception;
	pdb_does_not_exist exception;
	pragma exception_init(not_allowed,-1031);
	pragma exception_init(pdb_does_not_exist,-65011);
	-- may be a container number or name
	v_container varchar2(30);  
	v_sql varchar2(200);
begin
	if regexp_like(:v_session_container,'^[[:digit:]]+') then
		if :v_session_container = '1' then
			v_container := 'cdb$root';
		else
			select name into v_container
			from v$pdbs
			where con_id = to_number(:v_session_container);
		end if;
	else
		v_container := :v_session_container;
	end if;

	--dbms_output.put_line('v_container: ' || v_container);
	execute immediate 'alter session set container = ' || v_container;

exception
	when not_allowed then 
		dbms_output.put_line('');
		dbms_output.put_line('Must be SYS and in CDB$ROOT to change containers in PL/SQL');
		dbms_output.put_line('');
		:v_pdb_msg := 'Results: Did NOT Switch Containers';
		--raise;
	when no_data_found or pdb_does_not_exist then
		dbms_output.put_line('');
		dbms_output.put_line('A non-existent PDB was requested');
		dbms_output.put_line('');
		:v_pdb_msg := 'Results: Did NOT Switch Containers';
		dbms_output.put_line('');
		--raise;
	when others then
		raise;
end;
/

--pause

--select name db_name, open_mode from v$pdbs order by 1;
col v_pdb_msg format a40

print :v_pdb_msg


select 
	to_number(sys_context('userenv','con_id')) con_id
	, sys_context('userenv','con_name') con_name
from dual;

undef 1 
undef s_session_container

@restore-sqlplus-settings
set feedback on term on
@remove-sqlplus-settings


