
-- idle-sessions-histogram.sql
-- Jared Still jkstill@gmail.com 2021

set tab off
set pagesize 100

col username format a15
break on username skip 1

-- five minutes
def i_bucket_size=10
def i_bucket_count=30

-- change value below to '--' for regular report, '' for CSV
def CSVOUT='--'

col u_which_format noprint new_value u_which_format
col u_which_clears noprint new_value u_which_clears

set term off
select decode('&CSVOUT','--','rpt_format','csv_format') u_which_format from dual;
select decode('&CSVOUT','--','clears.sql','clear_for_spool.sql') u_which_clears from dual;

@&u_which_clears

clear breaks
break on report
compute sum of idle_count on report

col username format a20

set term on

with buckets as (
	select &i_bucket_size * (level-1) bucket_size
	from dual
	connect by level <= &i_bucket_count + 1
),
histogram_data as (
	select
		s.username,
		--last_call_et,
		last_call_et - mod(last_call_et,&i_bucket_size) idle_seconds_bucket
	from gv$session s
	where s.username is not null
	and s.status = 'INACTIVE'
	order by username, sid
),
rpt_format as (
	select
		-- gets any idle sessions outside the 5 minute windows (i_bucket_size * i_bucket_count)
		nvl(hb.bucket_size,hd.idle_seconds_bucket)  bucket_size
		, hd.username
		--, hd.idle_seconds_bucket
		, count( hd.idle_seconds_bucket) idle_count
	from
	histogram_data hd
		full outer join buckets hb on hd.idle_seconds_bucket = hb.bucket_size
	group by bucket_size, username, idle_seconds_bucket
	order by bucket_size, username, idle_seconds_bucket
),
csv_format as (
	select 'bucket_size' 
		|| ',' || 'username'
		|| ',' || 'idle_seconds_bucket'  
	from dual
	union all
	select * from 
	(
		select
			nvl(hb.bucket_size,hd.idle_seconds_bucket)
			|| ',' || hd.username
			|| ',' || count( hd.idle_seconds_bucket)
		from
		histogram_data hd
			full outer join buckets hb on hd.idle_seconds_bucket = hb.bucket_size
		group by bucket_size, username, idle_seconds_bucket
		order by bucket_size, username, idle_seconds_bucket
	)
)
select * from &u_which_format
/


