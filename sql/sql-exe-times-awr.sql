

-- sql-exe-times-awr.sql
-- call with sql_id
-- Jared Still -  -  jkstill@gmail.com
-- 2017-11-21
-- Jared Still - 2017-11-22
-- was going about getting execution times all wrong
-- now deriving execution times based on begin and end times
-- for a sql_exec_id per inst_id,session_id,serial# during the period tested
--
-- standardized the histogram buckets
-- now asks how many days to look back in AWR


@clears

col u_days_back new_value u_days_back noprint
col u_sql_id new_value u_sql_id noprint
var v_sql_id varchar2(13) 

col total_seconds format 999,999,999,999
col avg_seconds format 99,990.09
col med_seconds format 99,990.09
col seconds format 99,990.099
col executions format 99,999,999,999
col histogram format a100
col bucket_name format a12 heading 'EXE SECONDS'


set linesize 200 trimspool on
set pagesize 100

prompt
prompt SQL_ID: 
prompt

set term off feed off verify off

select '&1' u_sql_id from dual;

set term on feed on

prompt
prompt Days to Look Back: 
prompt

set term off feed off verify off

select '&2' u_days_back from dual;

set term on feed on


def stats=''
def histo='--'

exec :v_sql_id := '&u_sql_id'

prompt
prompt Remember: AWR is sampled from ASH only every 10 seconds
prompt



with sql_data as (
	select distinct sql_id
		, session_id, session_serial#, sql_exec_id
		, min(sample_time) over (partition by sql_id, session_id, session_serial#, sql_exec_id order by session_id, session_serial#, sql_exec_id) min_sample_time
		, max(sample_time) over (partition by sql_id, session_id, session_serial#, sql_exec_id order by session_id, session_serial#, sql_exec_id) max_sample_time
	from dba_hist_active_sess_history h
	join dba_hist_snapshot s on s.snap_id = h.snap_id
		and s.dbid = h.dbid
		and s.instance_number = h.instance_number
	where s.begin_interval_time >= systimestamp - interval '&u_days_back' day
	--where s.snap_id between 130328 and 130329
		and h.sql_id = :v_sql_id
	order by sql_id
		, session_id
		, session_serial#
		, sql_exec_id
),
sql_seconds as (
	select distinct
		sql_id
		, session_id, session_serial#, sql_exec_id,
			(extract( day from (max_sample_time - min_sample_time) )*24*60*60)+
			(extract( hour from (max_sample_time - min_sample_time) )*60*60)+
			(extract( minute from (max_sample_time - min_sample_time) )*60)+
			(extract( second from (max_sample_time - min_sample_time)))
		seconds
	from sql_data
),
stats as (
	select distinct sql_id
		, count(sql_id) over () executions
		, min(seconds) over () min_seconds
		, avg(seconds) over () avg_seconds
		, median(seconds) over () med_seconds
		, max(seconds) over () max_seconds
		, sum(seconds) over () total_seconds
	from sql_seconds
),
histo_data as (
	select s.sql_id
		-- limit to 100 characters
		, substr(rpad('*',count(*) over (partition by s.seconds),'*'),1,100) histogram
		--, ' <= ' || to_char(s.seconds +1) bucket
		, s.bucket_name
		, s.seconds
	from 
	(
		select  sql_id
		, case
			when seconds <= 1 then '<= 1'
			when seconds <= 2 then '<= 2'
			when seconds <= 3 then '<= 3'
			when seconds <= 4 then '<= 4'
			when seconds <= 5 then '<= 5'
			when seconds <= 10 then '<= 10'
			when seconds <= 15 then '<= 15'
			when seconds <= 20 then '<= 20'
			when seconds <= 30 then '<= 30'
			when seconds <= 40 then '<= 40'
			when seconds <= 50 then '<= 50'
			when seconds <= 60 then '<= 60'
			when seconds <= 120 then '<= 120'
			when seconds <= 300 then '<= 300'
			else	'>300'
		end bucket_name
		, case
			when seconds <= 1 then 1
			when seconds <= 2 then 2
			when seconds <= 3 then 3
			when seconds <= 4 then 4
			when seconds <= 5 then 5
			when seconds <= 10 then 10
			when seconds <= 15 then 15
			when seconds <= 20 then 20
			when seconds <= 30 then 30
			when seconds <= 40 then 40
			when seconds <= 50 then 50
			when seconds <= 60 then 60
			when seconds <= 120 then 120
			when seconds <= 300 then 300
			else	301
		end seconds
		from sql_seconds s
	) s
), 
histogram as (
select
	count(*) exe_count
	, seconds
	, bucket_name
	, histogram
from histo_data
group by seconds, bucket_name, histogram
order by seconds
)
&stats select sql_id, executions, min_seconds, avg_seconds, med_seconds, max_seconds, total_seconds
&stats from stats
&histo select
	&histo exe_count
	--&histo , seconds
	&histo , bucket_name
	&histo , histogram
&histo from histogram
/


def stats='--'
def histo=''

/

