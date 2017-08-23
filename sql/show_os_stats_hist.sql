
col savtime format a40
col pname format a20
col pval1 format 99,999,990.0999

select savtime, pname, pval1
from wri$_optstat_aux_history
order by savtime 
/

