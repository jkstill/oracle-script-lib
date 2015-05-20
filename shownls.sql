

@clears

col parameter format a30
col value format a40

ttitle 'NLS PARAMETERS'

set pagesize 60
break on source skip 1

select 'SESSION' source, parameter, value
from nls_session_parameters
union
select 'INSTANCE' source, parameter, value
from nls_instance_parameters
union
select 'DATABASE' source, parameter, value
from nls_database_parameters
order by source desc, parameter
/

