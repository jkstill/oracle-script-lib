
col pdb_name format a15
col open_mode format a10

select name pdb_name, open_mode
from v$pdbs
order by 1
/
