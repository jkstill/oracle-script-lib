
-- aas-awr-pdb-calc.sql
-- calculate AAS for PDBs from AWR
-- 
-- Jared Still 2020-11-10 
-- jkstill@gmail.com 
--
-- Note: Using SAMPLE_TIME/SAMPLE_ID rather than SNAP_ID, as SAMPLE_TIME is more granular
-- I have just been waiting for an opportunity to use 'granular'  ;)
--

col sample_time format a30
col lag_time format a30
col instance_number format 9999 head 'INST|ID'
col dbid format 999999999999999
col con_id format 999 head 'CON|ID'
col db_time format 999999.99 head 'DB_TIME'
col elapsed_time format 99999.999
col aas format 999999.99999990
col pdb_name format a20

with gettime as (
	/*
	   cannot easily get the lag_time here, as it creates nearly duplicate rows
		one with lag_time populated, and one without
	*/
	select distinct
        h.sample_time
		, h.snap_id
		, h.sample_id
		, h.instance_number
		, h.dbid
		, h.con_id
		, count(*) over (partition by h.sample_id, h.instance_number, h.con_id)  db_time
	from dba_hist_active_sess_history h
	where  (
		h.wait_class is null  -- on CPU
		or h.wait_class != 'Idle' -- wait events - ignore idle events
	)
),
getlag as (
	/*
		here we calculate the lag_time to the prior row, used to get elapsed time
	*/
	select
		h.sample_time
		, h.sample_id
		, lag(h.sample_time) over (partition by h.dbid,h.instance_number,h.con_id  order by h.sample_time ) lag_time
		, h.instance_number
		, h.dbid
		, h.con_id
		, db_time
	from gettime h
),
calctime as (
	/*
		extract the elapsed time
		the purpose of the getlag() is readability and ease of modification
		--
		without the getlag() section, then lag() would need to be duplicated for each extract()
	*/
	select
		sample_time
		, sample_id
		, lag_time
		, instance_number
		, dbid
		, con_id
		, db_time
		, (extract( day from (sample_time - lag_time ) )*24*60*60)+
			(extract( hour from (sample_time - lag_time ) )*60*60)+
			(extract( minute from (sample_time - lag_time ) )*60)+
			(extract( second from (sample_time - lag_time )))
		elapsed_time
	from getlag
)
select
	c.sample_time
	, c.sample_id
	, c.lag_time
	, c.instance_number
	, c.dbid
	--, c.con_id
	, p.name pdb_name
	, c.db_time
	, c.elapsed_time
	-- this line with decode should not normally be necessary
	-- if you are seeing divide-by-zero errors, there may be an error in the SQL
	-- or perhaps in the data
	--, db_time / decode(elapsed_time,null,10000,0,10000, elapsed_time)  aas
	, c.db_time / c.elapsed_time  aas
from calctime c
	join gv$pdbs p on p.inst_id = c.instance_number
		and p.con_id = c.con_id
order by
	c.con_id
	, c.sample_time
	, c.instance_number
/
