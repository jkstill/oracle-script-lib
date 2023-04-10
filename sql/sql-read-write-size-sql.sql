
-- sql-read-write-size-sql.sql
-- get write sizes per sql_id
-- use for estimating which SQL statements generate the most redo - shows SQL statement
-- Jared Still -  jkstill@gmail.com
-- 2023

set echo off term on verify off pause off
set feed on head on

col force_matching_signature format 999999999999999999999999
col exact_matching_signature format 999999999999999999999999
col physical_write_bytes format 999,999,999,999,999
col physical_read_bytes format 999,999,999,999,999
col sql_id format a13
col sql_text format a100 wrap

set pagesize 100
set linesize 200 trimspool on

-- use force_matching_signature if cursor_sharing = FORCE
-- use exact_matching_signature if cursor_sharing != FORCE

col v_signature_match_column new_value v_signature_match_column noprint

select case upper(value) 
	when 'FORCE' then 'force_matching_signature'
	else 'exact_matching_signature'
	end v_signature_match_column
from v$parameter
where name like 'cursor_sharing';

with sql_info as (
	select &v_signature_match_column
	from v$sqlstats
	where &v_signature_match_column != 0
	group by &v_signature_match_column
	order by count(*)
),
	sql_metrics as (
	select
		&v_signature_match_column
		, sum(physical_write_bytes) physical_write_bytes
		, sum(physical_read_bytes) physical_read_bytes
	from v$sqlstats
	where &v_signature_match_column != 0
	group by &v_signature_match_column
	having sum(physical_write_bytes) > 0
)
select
	i.&v_signature_match_column
	, m.physical_write_bytes
	, m.physical_read_bytes
	, s.sql_id
	, s.sql_text
	--, s.sql_fulltext
from sql_info i
join sql_metrics m on m.&v_signature_match_column = i.&v_signature_match_column
join v$sqlstats s on s.&v_signature_match_column =  i.&v_signature_match_column
left outer join v$sqltext t on t.sql_id = s.sql_id
	and t.piece = 1
	and t.command_type not in (3,47) -- SELECT and PL/SQL Execute
order by m.physical_write_bytes 
/

