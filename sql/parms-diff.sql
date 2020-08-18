
col name format a40
col parameter_values format a80

select distinct
	name
	, count(*) parameter_count
	, listagg(value,',') within group (order by sid) parameter_values
from v$spparameter
group by name
having count(*) > 1
/
