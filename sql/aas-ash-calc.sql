
-- aas-ash-calc.sql
-- Jared Still  jkstill@gmail.com
-- 2019 
-- calculate AAS from ASH data
-- gv$sysmetric history records this data (aas.sql)
-- under test conditions the sysmetric values seemed low
-- while these calculated values were closer to what was 
-- occuring at the time

set pagesize 100
set linesize 200 trimspool on
set echo off pause off term on feed on

col begin_time format a26
col end_time format a26
col currtime format a35
col inst_id format 9999 head 'INST'
col elapsed_seconds format 990.999990 head 'ELAPSED|SECONDS'
col aas format 990.9 head 'AAS'


with snapshots as (
	select distinct
		sample_id
		, inst_id
		, min(sample_time) over (partition by sample_id, inst_id  order by sample_time ) sample_time
	from gv$active_session_history
),
ash_data as (
	select distinct sample_id 
		, inst_id
		, sample_time begin_interval_time
		, lead(sample_time) over (partition by inst_id order by sample_id) end_interval_time
		, lead(sample_time) over (partition by inst_id order by sample_id) - sample_time time_diff
	from snapshots
),
data as (
-- the values seen in dba_hist_sysmetric_history for AAS are at times suspiciously very high
-- now calculating them from dba_hist_sysmetric_history
-- doing so may take a few minutes - 5 minutes observed on a db with AWR retentionn of 30 days
-- this was a server with 4T RAM and 80 cores.
	select begin_time,end_time,inst_id,elapsed_seconds,AAS
	from (
		select
			--to_char(begin_interval_time,'yyyy-mm-dd hh24:mi:ss.ff6') begin_time
			--, to_char(end_interval_time,'yyyy-mm-dd hh24:mi:ss.ff6') end_time
			begin_interval_time begin_time
			, end_interval_time end_time
			, inst_id
			, elapsed_seconds
			/*
				normally AAS would be db_time / elapsed_seconds (I think)
				the problem is that ASH snapshots do not always come 1 second apart
				during periods during which there is little activity, ASH snapshots
				may be 20-40 seconds apart
				using db_time / elapsed_seconds yields an artificially low number in those cases
				--	
				then it would seem we should use something like ( elapsed_seconds * db_time ) / elapsed_seconds)
				which is kind of silly, as it is the same value as db_time
				so that is what I am using for AAS when the time between samples > 1.5 seconds
			*/
			, case 
			when elapsed_seconds > 1.5 then db_time
			else db_time / elapsed_seconds 
			end aas
		from (
			select distinct h.sample_id
				, h.inst_id
				, h.begin_interval_time
				, h.end_interval_time
				, count(*) over (partition by h.sample_id, h.inst_id) db_time
				, (extract ( day from h.time_diff ) * 86400)
	  				+ (extract ( hour from h.time_diff ) * 3600)
	  				+ (extract ( minute from h.time_diff ) * 60)
	  				+ (extract ( second from h.time_diff )) elapsed_seconds
			from ash_data h
			join gv$active_session_history s on s.sample_id = h.sample_id
				and s.inst_id = h.inst_id
			where time_diff is not null
			and (
				( s.session_state = 'WAITING' and s.wait_class not in ('Idle') )
				or
				s.session_state = 'ON CPU'
			)
			--and rownum <= 200
		)
		order by 2 desc
	)
),
rpt as (
	select
		begin_time
		, end_time
		, inst_id
		, elapsed_seconds
		, aas
	from data
	where begin_time > systimestamp - numtodsinterval('1', 'hour')
	order by begin_time desc, inst_id
)
--select systimestamp currtime, rpt.*
select rpt.*
from rpt
where rownum <= 20
/*
   the following line may be used to get the most recent AAS per instance
	this assumes no overlap in begin_time between instances
   otherwise AAS from as single instance may appear more than once in RAC
*/
--where rownum <= (select count(*) from gv$instance)
order by begin_time, inst_id
/

