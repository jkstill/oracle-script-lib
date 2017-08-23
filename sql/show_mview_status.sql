
select owner, mview_name, unusable,invalid, known_stale
from dba_mview_analysis
order by owner, mview_name
/


