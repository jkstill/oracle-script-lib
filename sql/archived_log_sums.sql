

-- archived_log_sums.sql
-- see 'prompts' below for info
-- jared still - 2011-05-12
-- 10.2.0.3 seems to have a bug displaying dates in this script
-- 10.2.0.4 is Ok

col  num_days new_value num_days noprint

set feed on term on echo off tab off

prompt
prompt report how much space N days of archive logs consume
prompt for each day and the preceding (N-1) days
prompt
prompt the first (N-1) days of the report are inaccurate
prompt 

prompt Calculate archive log sums for how many days? :
set term off feed off 
select '&1' num_days from dual;
set term on feed on

col log_date format a20 head 'LOG DATE'
col bytes format 99,999,999,999,999
col bytes_today format 99,999,999,999,999
col bytes_Nday format 99,999,999,999,999

set pagesize 100
set linesize 200 trimspool on

-- for repeated use a temp table of archive logs
-- is *much* faster

--define src_table='archlogs'
define src_table='v$archived_log'

with rawlogs as (
	select distinct a.first_time, a.sequence#, a.thread#, a.block_size, a.blocks
	from &src_table a
	order by a.first_time, a.sequence#,a.thread#
),
logdaysums as (
	select
		trunc(r.first_time) log_date
		, sum(block_size * blocks) bytes
	from rawlogs r
	group by trunc(r.first_time)
),
ndaysums as (
	select
		l.log_date
		, &num_days days
		, l.bytes bytes_today
		, sum(l.bytes)
			over (order by l.log_date rows (&num_days - 1) preceding) bytes_Nday
	from logdaysums l
	group by log_date, &num_days, bytes
	order by l.log_date
)
select to_char(n.log_date,'yyyy-mm-dd') log_date, n.days, n.bytes_today, n.bytes_Nday
from ndaysums n
union all
select '== AVG N DAYS =====', null, null,null from dual
union all
select 'AVERAGES' log_date, n.days, avg(n.bytes_today) bytes_today, avg(n.bytes_Nday) bytes_Nday
from ndaysums n
group by 'AVERAGES', n.days
union all
select '== MEDIAN N DAYS ===', null, null,null from dual
union all
select 'MEDIAN' log_date, n.days, median(n.bytes_today) bytes_today, median(n.bytes_Nday) bytes_Nday
from ndaysums n
group by 'MEDIAN', n.days
union all
select '== MIN N DAYS =====', null, null,null from dual
union all
select to_char(n2.log_date,'yyyy-mm-dd') log_date, n2.days, null, n2.bytes_Nday
from ndaysums n2
where (n2.bytes_Nday) in (
	select min(n3.bytes_Nday) bytes_Nday
	from ndaysums n3
)
union all
select '== MAX N DAYS =====', null, null,null from dual
union all
select to_char(n2.log_date,'yyyy-mm-dd') log_date, n2.days, null, n2.bytes_Nday
from ndaysums n2
where (n2.bytes_Nday) in (
	select max(n3.bytes_Nday) bytes_Nday
	from ndaysums n3
)
/

undef 1

