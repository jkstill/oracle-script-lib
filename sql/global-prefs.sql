
col spare4 format a40 head 'VALUE'

select sname,spare4 
from sys.optstat_hist_control$
order by 1
/
