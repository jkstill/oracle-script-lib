
-- segment-space-statistics.sql
-- link to sss.sql for ease of use
-- Jared Still 2023

/*

 get the current block changes per object
 this can be used to gauge the amount of redo per segment.

 oracle does not usually recreate full blocks in the redo. 

 the size of redo is dependent on just how much was changed in a block

*/

set linesize 200 trimspool on
set pagesize 100
set feed on term on
set tab off echo off pause off

col owner format a20
col object_name format a30
col tbs_name format a30
col inst_id format 9999 head 'INST|ID'
col con_id format 999
col statistic_name format a30
col value format 99,999,999,999 head 'VALUE'


--break on object_name

with
statnames as (
	select
		sn.inst_id
		, sn.statistic#
		, sn.name
		, sn.sampled
		, sn.con_id -- included for completeness, though essentially useless as it is always 0
	from gv$segstat_name sn
	--/*
	where sn.name in (
		-- all values availabe in gv$segstat_name as of 23c FREE
		-- uncomment the desired statistic names
		---
		-- IM: In Memory
		--'IM db block changes'
		--,'IM non local db block changes'
		--,'IM populate CUs'
		--,'IM prepopulate CUs'
		--,'IM repopulate (trickle) CUs'
		--,'IM repopulate CUs'
		--,'IM scans'
		--,'ITL waits'
		--,'buffer busy waits'
		'db block changes'
		--,'gc buffer busy'
		--,'gc cr blocks received'
		--,'gc current blocks received'
		--,'gc remote grants'
		--,'logical reads'
		--,'optimized physical reads'
		--,'optimized physical writes'
		--,'physical read requests'
		--,'physical reads'
		--,'physical reads direct'
		--,'physical write requests'
		--,'physical writes'
		--,'physical writes direct'
		--,'row lock waits'
		--,'segment scans'
		--,'space allocated'
		--,'space used'
	)
	--*/
),
users as (
/*
-- no blank lines allowed in these comments
--
-- Joining DBA_USERS on 23c may perform poorly for this SQL, at least has been my experience
-- poorly as in 2-30 seconds or more when 19c is ~ 0.2 seconds.
-- If so, then gather data dictionary stats, and that should take care of the problem
-- ie:  exec dbms_stats.gather_dictionary_stats
*/
	select 
		/*+ 
			-- hints in this block may be commented out individually
			no_parallel
			gather_plan_statistics
			qb_name(users) 
		*/
		username
	from dba_users
	-- comment out both to see all users
	-- only system user accounts
	--where oracle_maintained = 'Y'
	-- non-system accounts
	--where oracle_maintained = 'N'
),
data as (
	select
		/*+ qb_name(data) */
		ss.inst_id	
		, ss.con_id
		, o.owner
		, o.object_name
		--, tbs.name tbs_name -- uncomment if needed
		, sn.name statistic_name
		, ss.value
	from gv$segstat ss
	--join gv$segstat_name sn 
	join statnames sn
		on sn.statistic# = ss.statistic#
		and sn.inst_id = ss.inst_id
		-- joining on (g)v$segstat_name with (g)v$segstat_name.con_id may result in 0 rows returned
		-- that is due to (g)v$segstat_name.con_id always being 0 - checked up through 23c FREE
		--and sn.con_id = 0
		and ss.value > 0
	join dba_objects o on o.object_id = ss.obj#
		and o.data_object_id = ss.dataobj#
	join sys.ts$ tbs on tbs.ts# = ss.ts#
	where o.owner in (select username from users u )
)
select 
	/*+ qb_name(main) */
	*
from data
order by owner, object_name, con_id, inst_id
/


