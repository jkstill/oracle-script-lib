
-- pdb-modifiable-params-dump.sql
-- Jared Still - 

set pause off
set echo off
set timing off
set trimspool on
set feed on echo off verify off
set heading off

clear col
clear break
clear computes

btitle ''
ttitle ''

btitle off
ttitle off

set newpage 1

set pagesize 0
set linesize 400 trimspool on

clear break

column sp_name format a40
column db format a25
column value format a35
column pdb_modifiable
 
define FS='|'
define dumpfile=pdb-modifiable-params-dump.csv
spool &dumpfile

prompt parameter_name,database,value,pdb_modifiable,con_id

with dbs as (
	select 0 con_id, 'CDB' db from dual
	union all
	select con_id, name db from v$pdbs
),
params as (
	select 
		name sp_name
		, sp.value
		, decode(sp.ispdb_modifiable,'TRUE','Y','N') pdb_modifiable
		, sp.con_id
	from  v$system_parameter sp
)
select 
	sp.sp_name
	|| '&FS' || dbs.db
	|| '&FS' || sp.value
	|| '&FS' || sp.pdb_modifiable
	|| '&FS' || dbs.con_id
from   params sp
join dbs on dbs.con_id = sp.con_id 
where sp.sp_name like '%%'
order by sp_name, dbs.con_id
/

spool off

set heading on
set pagesize 100

prompt
prompt output in &dumpfile
prompt


