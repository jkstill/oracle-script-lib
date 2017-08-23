

@clears
set line 140
 
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
 
--spool showtrans.txt
 
select s.osuser
	,s.username
	,s.sid
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
	,substr(sa.sql_text,1,200) txt
from v$session s,
	v$transaction t,
	dba_rollback_segs r,
	v$sql sa
where s.saddr=t.ses_addr
and   t.xidusn=r.segment_id(+)
and   s.sql_address=sa.address(+)
/
--spool off 
 

