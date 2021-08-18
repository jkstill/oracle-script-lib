
-- pdb-violations.sql
-- Jared Still - jkstill@gmail.com - 2021

col time format a30
col name format a30
col cause format a30
col message format a50

set linesize 200 trimspool on
set pagesize 100

select name,time,cause,status,message
from PDB_PLUG_IN_VIOLATIONS
where STATUS='PENDING'
order by name,time
/

