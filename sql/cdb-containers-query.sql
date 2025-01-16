
-- cdb-containers-query.sql
-- an example of using the containers(object) clause
-- to query an object in multiple containers
-- run this from the CDB$ROOT
--
-- this is just an example to show how containers() may be used
--
-- Jared Still
-- jkstill@gmail.com
--
-- https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/SELECT.html#GUID-CFA006CA-6FF1-4972-821E-6996142A51C6
-- 

/*

SYS AS SYSDBA> @cdb-containers-query.sql

PDB_NAME     GRANTEE              PRIVILEGE            GRANTOR
------------ -------------------- -------------------- --------------------
PDB1         AUDIT_ADMIN          READ                 SYS
PDB1         CTXSYS               SELECT               SYS
PDB1         DVSYS                READ                 SYS
...
PDB4         MDSYS                SELECT               SYS
PDB4         ORACLE_OCM           SELECT               SYS
PDB4         SELECT_CATALOG_ROLE  SELECT               SYS

*/

col con_id format 9999
col grantor format a20
col grantee format a20
col privilege format a20
col pdb_name format a12

set linesize 200 trimspool on
set pagesize 100

select pdbs.name pdb_name, privs.grantee, privs.privilege, privs.grantor
from containers(dba_tab_privs) privs
join v$pdbs pdbs on pdbs.con_id = privs.con_id
	-- containers clause does this automatically
	--and pdbs.open_mode='READ WRITE'
where table_name='DBA_USERS'
order by pdbs.name, privs.grantee
/

