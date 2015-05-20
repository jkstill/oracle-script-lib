
-- show_os_stats.sql
-- populated by the timed_os_statistics init parameter
--

col sname format a15
col pname format a15
col pval1 format 99,999,999,999.9999
col pval2 format a22

set line 80

select * 
from sys.aux_stats$
order by sname
/
