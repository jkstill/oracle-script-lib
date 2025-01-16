
-- sql-version-counts
-- Oracle 12.1+
-- Jared Still -  jkstill@gmail.com
-- 2017-01-07

--@clears

set pagesize 60
set linesize 200 trimspool on



select 
	version_count
	, sql_id
	, substr(sql_fulltext,1,50) sqltext
from v$sqlstats
order by version_count desc
fetch first 10 rows with ties
/
