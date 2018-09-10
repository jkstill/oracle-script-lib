
-- rman-recovery-scn.sql
-- determine the SCN from which the database must be recovered
--
-- this is based on the lowest checkpoint_change# (SCN) found in a datafile
-- for 12c+ databases this will exclude the SEED database
-- 

set term off feed off
@@oversion_major

set pagesize 100
set linesize 200 trimspool on
col name format a100
col db_name format a20


col u_pdb_exclude noprint new_value PDB_EXCLUDE

select 
	case when to_number('&v_oversion_major') >= 12
		then ''
		else '--'
	end u_pdb_exclude
from dual;

set head on term on feed on verify off echo off

-- Not using a simple group by with max
-- using subquery factoring (Common Table Expression or CTE if you prefer ANSI) 
-- allows running the script and then easily editing the code if you like

with data as (
    select
        --f.con_id
        &PDB_EXCLUDE nvl(p.name,'CDB') db_name
        &PDB_EXCLUDE , 
        f.file#
        , f.checkpoint_change# SCN
        , f.name
    from v$datafile f
    &PDB_EXCLUDE left outer join v$pdbs p on p.con_id = f.con_id
    &PDB_EXCLUDE where nvl(p.name,'CDB') != 'PDB$SEED' -- exclude default SEED
)
select min(SCN) SCN
from data
order by 1
/

