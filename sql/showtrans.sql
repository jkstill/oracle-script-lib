

@clears
set line 200
set pagesize 100
set tab off
 
col inst_id format 9999 head 'INST|ID'
col sql_id format a13
col osuser format a8 heading 'O/S|User' 
col username format a10 heading 'Oracle|Userid' 
col sid format 9999 head 'SID'
col segment_name format a6 heading 'R-S|Name' 
col space format a5 head 'Space|Trans'
col recursive format a5 head 'Recur|sive|Trans'
col noundo format a5 head 'No|Undo'
col used_ublk format 999,999,999 head 'Used|Rbs|Blks'
col used_urec format 999,999,999 head 'Used|RBS|Recs'
col log_io format 9,999,999,999 head 'Logical|IO Blks'
col phy_io format 9,999,999,999 head 'Physical|IO Blks'
col txt format a30 heading 'Current|Statement' word  
col rollback_status format a5 head 'RB|Status'
col command_name format a20 head 'Command|Name'
 
--spool showtrans.txt
 
select 
	s.inst_id
	,s.osuser
	,s.username
	,s.sid
	,c.command_name
	,r.segment_name
	,t.space
	,t.recursive
	--,t.noundo
	-- rollback state
	-- thanks to Mark Powell for this
	-- RB is rolling back
	-- No RB is not rolling backe
	, case when bitand(t.flag,power(2,7)) > 0 then 'RB'
		else 'No RB'
		end as rollback_status
	,t.used_ublk
	,t.used_urec
	,t.log_io
	,t.phy_io
	,s.sql_id
	,substr(sa.sql_text,1,200) txt
from gv$session s,
	gv$transaction t,
	dba_rollback_segs r,
	gv$sql sa,
	v$sqlcommand c
where s.saddr=t.ses_addr
	and s.inst_id = t.inst_id
and   t.xidusn=r.segment_id(+)
	and t.inst_id = r.instance_num(+)
and   s.sql_address=sa.address(+)
	and s.inst_id = sa.inst_id(+)
and  s.command = c.command_type
/

--spool off 
 

