
col owner format a14
col object_name format a30
col subobject_name format a30
col object_type format a12
col statistic_name format a30
col value format 999,999,999


/* -- may be interesting results
select
	statistic_name, sum(value)
from v$segment_statistics
group by statistic_name
order by 2;
*/

select 
	owner
	, object_name
	, subobject_name
	, object_type
	, statistic_name
	, value
from v$segment_statistics
where statistic_name = 'ITL waits'
	and value > 0
	-- and object_name = 'INITRANS_TEST'
order by value
/
