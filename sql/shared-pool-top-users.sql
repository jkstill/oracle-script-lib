var topcount number

exec :topcount:=20

col sql_fulltext format a100
set linesize 200 trimspool on
set pagesize 200

break on report
compute sum of sharable_mem on report
compute sum of persistent_mem on report
compute sum of runtime_mem on report
compute sum of version_count on report
compute sum of sql_count on report

col sharable_mem		format 999,999,999,999
col persistent_mem	format 999,999,999,999
col runtime_mem		format 999,999,999,999
col version_count		format 99,999,999
col sql_count			format 99,999,999

col parsing_schema_name format a20

with sql_size as (
	select  distinct s.parsing_schema_name
		, sum(s.sharable_mem) over (partition by s.parsing_schema_name order by s.parsing_schema_name)	sharable_mem
		, sum(s.persistent_mem) over (partition by s.parsing_schema_name order by s.parsing_schema_name) persistent_mem
		, sum(s.runtime_mem) over (partition by s.parsing_schema_name order by s.parsing_schema_name) runtime_mem
		, count(*) over (partition by s.parsing_schema_name order by s.parsing_schema_name) sql_count
		, sum(s.version_count) over (partition by s.parsing_schema_name order by s.parsing_schema_name) version_count
	from v$sqlarea s 
	order by 2 desc
),
sql_top as (
		  select * from sql_size where rownum <= :topcount
)
select  t.parsing_schema_name
		  , t.sharable_mem
		  , t.persistent_mem
		  , t.runtime_mem
		  , t.sql_count
		  , t.version_count
from sql_top t
/

