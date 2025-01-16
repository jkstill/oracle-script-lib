
col pdb_name format a15
col open_mode format a10
col con_id format 99999

select con_id, name pdb_name, open_mode
from v$pdbs
order by 1
/
