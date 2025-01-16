
-- bootstrap_objects.sql
-- Jared Still
-- 

-- These are objects required for a warm start, and cannot be modified in any way

col object format a30

with data as (
	select 
		case rtrim(substr(bs.sql_text,1,instr(bs.sql_text,' ',8)))
			when 'CREATE CLUSTER' then 'CLUSTER'
			when 'CREATE INDEX' then  'INDEX'
			when 'CREATE ROLLBACK' then 'ROLLBACK'
			when 'CREATE TABLE' then 'TABLE'
			when 'CREATE UNIQUE' then 'INDEX'
		end type,
		case rtrim(substr(bs.sql_text,1,instr(bs.sql_text,' ',8)))
			when 'CREATE CLUSTER' then ltrim(substr(bs.sql_text,instr(bs.sql_text,' ',15)))
			when 'CREATE INDEX' then ltrim(substr(bs.sql_text,instr(bs.sql_text,' ',13)))
			when 'CREATE ROLLBACK' then ltrim(substr(bs.sql_text,instr(bs.sql_text,' ',23)))
			when 'CREATE TABLE' then ltrim(substr(bs.sql_text,instr(bs.sql_text,' ',13)))
			when 'CREATE UNIQUE' then ltrim(substr(bs.sql_text,instr(bs.sql_text,' ',20)))
		end sql_text
	from sys.bootstrap$ bs
	where bs.sql_text like 'CREATE%'
	order by 1
)
select 
	d.type,
	case type
		when 'TABLE' then substr(d.sql_text,1,instr(d.sql_text,'(')-1)
		when 'INDEX' then substr(d.sql_text,1,instr(d.sql_text,' ')-1)
		when 'ROLLBACK' then substr(d.sql_text,1,instr(d.sql_text,' ')-1)
		when 'CLUSTER' then substr(d.sql_text,1,instr(d.sql_text,'(')-1)
	end object
from data d
order by 1,2
/

