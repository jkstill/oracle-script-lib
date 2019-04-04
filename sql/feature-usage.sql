select name, detected_usages , description
from DBA_FEATURE_USAGE_STATISTICS
--where detected_usages != 0
where name in ('Extensibility','Object', 'Services')
order by name
/
