
-- dbms_space_asa_rpt.sql
-- report showing recommendations from Automatic Segment Advisor
-- Jared Still - 2013-06-01
-- 
-- jkstill@gmail.com

-- change to 'TRUE' to show findings only rather than recommendations
define show_findings_only='FALSE'

/* columns returned in pipelined function dbms_space.asa_recommendations
tablespace_name	 : Name of the tablespace containing the object
segment_owner		 : Name of the schema
segment_name		 : Name of the object
segment_type		 : Type of the segment 'TABLE','INDEX' and so on
partition_name		 : Name of the partition
allocated_space	 : Space allocated to the segment
used_space			 : Space actually used by the segment
reclaimable_space  : Reclaimable free space in the segment
chain_rowexcess	 : Percentage of excess chain row pieces that can be eliminated
recommendations	 : Recommendation or finding for this segment
c1						 : Command associated with the recommendation
c2						 : Command associated with the recommendation
c3						 : Command associated with the recommendation
task_id				 : Advisor Task that processed this segment
mesg_id				 : Message ID corresponding to the recommendation
*/


col tablespace_name	 format a20 head 'TABLESPACE'
col segment_owner		 format a15 head 'OWNER'
col segment_name		 format a30 head 'SEGMENT'
col segment_type		 format a18 head 'SEGMENT TYPE'
col partition_name	 format a30 head 'PARTITION NAME'
col allocated_space	 format 999,999,999,999 head 'ALLOCATED SPACE'
col used_space			 format 999,999,999,999 head 'USED SPACE'
col reclaimable_space format 999,999,999,999 head 'RECLAIMABLE|SPACE'
col chain_rowexcess	 format 999,999,999,999 head 'CHAIN ROW EXCESS'
col recommendations	 format a120
col c1					 format a120 head 'CMD-1'
col c2					 format a120 head 'CMD-2'
col c3					 format a120 head 'CMD-3'


set line 140
set pagesize 50000

spool dbms_space_asa_rpt.txt

select
	lpad('=',140,'=') separator
	, tablespace_name
	, segment_owner
	, segment_name
	, segment_type
	, partition_name
	, allocated_space
	, used_space
	, reclaimable_space
	, chain_rowexcess
	, recommendations
	, c1
	, c2
	, c3
from table(
	-- named parameters not working in 10.2.0.4
	dbms_space.asa_recommendations ('TRUE','TRUE','&&show_findings_only')
/*
10g bug - does not work in 10.2.0.4
			 does work in 11.2.0.3
	dbms_space.asa_recommendations(show_findings => '&&show_findings_only')
*/
)
/

ed dbms_space_asa_rpt.txt
