var topcount number

exec :topcount:=50

col sql_fulltext format a100
set linesize 200 trimspool on
set pagesize 200

break on report
compute sum of sharable_mem on report
compute sum of persistent_mem on report
compute sum of runtime_mem on report

col sharable_mem		format 999,999,999,999
col persistent_mem	format 999,999,999,999
col runtime_mem		format 999,999,999,999
col parsing_schema_name format a20


with sql_size as (
		  select s.sql_id
					 , s.sharable_mem	  -- SGA
					 , s.persistent_mem -- PGA: bind values, other cursor specific
					 , s.runtime_mem	  -- PGA: session related
					 --, s.sql_fulltext
		  from v$sqlarea s
		  order by s.sharable_mem desc
),
sql_top as (
		  select * from sql_size where rownum <= :topcount
)
select  t.sql_id
		  , s.parsing_schema_name
		  , s.version_count
		  , t.sharable_mem
		  , t.persistent_mem
		  , t.runtime_mem
from sql_top t
join v$sqlarea s on s.sql_id = t.sql_id
/
