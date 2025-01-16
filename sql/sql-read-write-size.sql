
-- sql-read-write-size.sql
-- get write sizes per sql_id
-- use for estimating which SQL statements generate the most redo
-- Jared Still -  jkstill@gmail.com
-- 2023

set echo off term on verify off pause off
set feed on head one

col force_matching_signature format 999999999999999999999999
col exact_matching_signature format 999999999999999999999999
col physical_write_bytes format 999,999,999,999,999
col physical_read_bytes format 999,999,999,999,999
col sql_ids format a104

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
	select
		&v_signature_match_column
		, listagg(sql_id,',') within group(order by &v_signature_match_column ) sql_ids
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
	, physical_write_bytes
	, physical_read_bytes
	, sql_ids
from sql_info i
join sql_metrics m on m.&v_signature_match_column = i.&v_signature_match_column
/

