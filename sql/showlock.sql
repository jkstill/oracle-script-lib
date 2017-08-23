-- showlock.sql - show all user locks
-- 
-- see ML Note 1020008.6 for fully decoded locking script
-- parts of the that script to not work correctly, but the
-- lock types are current 
-- (script doesn't find object that is locked )
--
-- speeded up greatly by changing order of where clause,
-- jks 04/09/1997 - show lock addresses and lockwait

-- jks 04/09/1997 - outer join on all_objects
--                  encountered situation on 7.2
--                  where there was a lock with no
--                  matching object_id
-- jks 02/24/1999 - join to dba_waiters to show waiters and blockers
-- jkstill 05/22/2006 - revert back to previous version without tmp tables
--                      update lock info
--                      add lock_description and rearrange output
-- jkstill 04/28/2008 - added command column
--                      updated lock types
--                      removed one outer join by using inline view on sys.user$
-- jkstill 04/28/2008 - added subquery factoring
--                      converted to ANSI joins
--                      changed alias for v$lock to l and v$session to s
-- jkstill 07/16/2010 - use audit_actions table to resolve commands (eliminate decode)
--                      use 'connect by level' to replace a very long decode
--

set trimspool on 
ttitle off
set linesize 150
set pagesize 60
column command format a15
column osuser heading 'OS|Username' format a7 truncate
column process heading 'OS|Process' format a7 truncate
column machine heading 'OS|Machine' format a10 truncate
column program heading 'OS|Program' format a18 truncate
column object heading 'Database|Object' format a25 truncate
column lock_type heading 'Lock|Type' format a4 truncate
column lock_description heading 'Lock Description'format a16 truncate
column mode_held heading 'Mode|Held' format a15 truncate
column mode_requested heading 'Mode|Requested' format a10 truncate
column sid heading 'SID' format 999
column username heading 'Oracle|Username' format a7 truncate
column image heading 'Active Image' format a20 truncate
column sid format 99999
col waiting_session head 'WATR' format 9999
col holding_session head 'BLKR' format 9999

with 
cmdtypes as (
	select action, name from audit_actions
) ,
-- use the v$lock_type table instead of this in 10g+
-- locktypes as (select type lock_type, name lock_name from v$lock_type)
locktypes as (
	select lock_type, lock_name
	from (
		select
		  level,
		  case mod(level,2)
		  when 1 then substr(cmd,instr(cmd,',',1,level)+1, instr(cmd,',',1,level+1) - instr(cmd,',',1,level) -1 )
		  else null
		  end lock_type,
		  case mod(level,2)
		  when 1 then substr(cmd,instr(cmd,',',1,level+1)+1, instr(cmd,',',1,level+2) - instr(cmd,',',1,level+1)-1)
		  else null
		  end lock_name
		from (select
		',AB,Auto BMR,AD,ASM Disk AU Lock,AE,Edition Lock,AF,Advisor Framework,AG,Analytic Workspace Generation,AK,GES Deadlock Test,AM,ASM Enqueue,AO,MultiWriter ObjectAccess,AR,ASM Relocation Lock,AS,Service Operations,AT,Alter Tablespace,AU,Audit index file,AV,ASM volume locks,AW,Analytic Workspace,AY,KSXA Test Affinity Dictionary,BB,Global Transaction Branch,BF,BLOOM FILTER,BR,Backup/Restore,CA,Calibration,CF,Controlfile Transaction,CI,Cross-Instance Call Invocation,CL,Label Security cache,CM,ASM Instance Enqueue,CN,KTCN REG enq,CO,KTUCLO Master Slave enq,CQ,Cleanup querycache registrations,CR,Reuse Block Range,CT,Block Change Tracking,CU,Cursor,DB,DbsDriver,DD,ASM Local Disk Group,DF,Datafile Online in RAC,DG,ASM Disk Group Modification,DI,GES Internal,DL,Direct Loader Index Creation,DM,Database Mount/Open,DN,Diskgroup number generator,DO,ASM Disk Online Lock,DP,LDAP Parameter,DQ,ASM RBAL doorbell,DR,Distributed Recovery,DS,Database Suspend,DT,Default Temporary Tablespace,DV,Diana Versioning,DW,In memory Dispenser,DX,Distributed Transaction,E ,Library Cache Lock 2,FA,ASM File Access Lock,FB,Format Block,FC,Disk Group Chunk Mount,FD,Flashback Database,FE,KTFA Recovery,FG,ACD Relocation Gate Enqueue,FL,Flashback database log,FM,File Mapping,FP,File Object,FR,Disk Group Recovery,FS,File Set / Dictionary Check,FT,Disk Group Redo Generation,FU,DBFUS,FW,Flashback Writer,FX,ACD Xtnt Info CIC,FZ,ASM Freezing Cache Lock,G ,Library Cache Pin 2,HD,ASM Disk Header,HP,Queue Page,HQ,Hash Queue,HV,Direct Loader High Water Mark,HW,Segment High Water Mark,IA,Internal,ID,NID,IL,Label Security,IM,Kti blr lock,IR,Instance Recovery,IS,Instance State,IT,In-Mem Temp Table Meta Creation,IV,Library Cache Invalidation,IZ,INSTANCE LOCK,JD,Job Queue Date,JI,Materialized View,JQ,Job Queue,JS,Job Scheduler,JX,SQL STATEMENT QUEUE,KD,Scheduler Master DBRM,KE,ASM Cached Attributes,KK,Kick Instance to Switch Logs,KL,LOB KSI LOCK,KM,Scheduler,KO,Multiple Object Checkpoint,KP,Kupp Process Startup,KQ,ASM Attributes Enque,KT,Scheduler Plan,L ,Library Cache Lock 1,MD,Materialized View Log DDL,MH,AQ Notification Mail Host,MK,Master Key,ML,AQ Notification Mail Port,'
		cmd
		from dual ) d
		where mod(level,2) = 1
		connect by level <= 220
		--
		union all
		select
		  level,
		  case mod(level,2)
		  when 1 then substr(cmd,instr(cmd,',',1,level)+1, instr(cmd,',',1,level+1) - instr(cmd,',',1,level) -1 )
		  else null
		  end lock_type,
		  case mod(level,2)
		  when 1 then substr(cmd,instr(cmd,',',1,level+1)+1, instr(cmd,',',1,level+2) - instr(cmd,',',1,level+1)-1)
		  else null
		  end lock_name
		from (select 
		',MN,LogMiner,MO,MMON restricted session,MR,Media Recovery,MS,Materialized View Refresh Log,MV,Online Datafile Move,MW,MWIN Schedule,MX,ksz synch,N ,Library Cache Pin 1,OC,Outline Cache,OD,Online DDLs,OL,Outline Name,OQ,OLAPI Histories,OW,Encryption Wallet,PD,Property Lock,PE,Parameter,PF,Password File,PG,Global Parameter,PH,AQ Notification Proxy,PI,Remote PX Process Spawn Status,PL,Transportable Tablespace,PM,ASM PST Signalling,PR,Process Startup,PS,PX Process Reservation,PT,ASM Partnership and Status Table,PV,KSV slave startup,PW,Buffer Cache PreWarm,Q ,Row Cache,RB,ASM Rollback Recovery,RC,Result Cache Enqueue,RD,RAC Load,RE,Block Repair/Resilvering,RF,Data Guard Broker,RK,wallet_set_mkey,RL,RAC Encryption Wallet Lock,RM,GES Resource Remastering,RN,Redo Log Nab Computation,RO,Multiple Object Reuse,RP,Resilver / Repair,RR,Workload Capture and Replay,RS,Reclaimable Space,RT,Redo Thread,RU,Rolling Migration,RW,Materialized View Flags,RX,ASM Extent Relocation Lock,SB,LogicalStandby,SC,System Change Number,SE,Session Migration,SF,AQ Notification Sender,SH,Active Session History Flushing,SI,Streams Table Instantiation,SJ,KTSJ Slave Task Cancel,SK,Shrink Segment,SL,Serialize Lock request,SM,SMON Serialization,SO,Shared Object,SP,Spare Enqueue,SQ,Sequence Cache,SR,Synchronized Replication,SS,Sort Segment,ST,Space Transaction,SU,SaveUndo Segment,SV,Sequence Ordering,SW,Suspend Writes,TA,Instance Undo,TB,SQL Tuning Base Existence Cache,TC,Tablespace Checkpoint,TD,KTF map table enqueue,TE,KTF broadcast,TF,Temporary File,TH,Threshold Chain,TK,Auto Task Serialization,TL,Log Lock,TM,DML,TO,Temp Object,TP,Runtime Fixed Table Purge,TQ,Queue table enqueue,TS,Temporary Segment,TT,Tablespace,TW,Cross-Instance Transaction,TX,Transaction,UL,User-defined,US,Undo Segment,V ,Library Cache Lock 3,WA,AQ Notification Watermark,WF,AWR Flush,WG,Write gather local enqueue,WL,Being Written Redo Log,WM,WLM Plan Operations,WP,AWR Purge,WR,LNS archiving log,WS,LogWriter Standby,XB,ASM Group Block lock,XC,XDB Configuration,XD,Auto Online Exadata disks,XH,AQ Notification No-Proxy,XL,ASM Extent Fault Lock,XQ,ASM Extent Relocation Enqueue,XR,Quiesce / Force Logging,XY,Internal Test,Y ,Library Cache Pin 3,ZA,Audit Partition,ZF,FGA Partition,ZG,File Group,ZH,Compression Analyzer,ZZ,Global Context Action,'
		cmd
		from dual) d
		where mod(level,2) = 1
		connect by level <= 220
	)
	where lock_type is not null
),
dblocks as (
select /*+ ordered gather_plan_statistics */
	l.kaddr,
	s.sid,
	s.username,
	lock_waiter.waiting_session,
	lock_blocker.holding_session,
	(
		select name 
		from sys.user$ 
		where user# = o.owner#
	) ||'.'||o.name
	object,
   ct.name COMMAND,
	-- lock type
	-- will always be TM, TX or possible UL (user supplied) for user locks
	l.type lock_type,
	lt.lock_name lock_description,
	decode
	(
		l.lmode,
		0, 'None',           /* Mon Lock equivalent */
		1, 'No Lock',           /* N */
		2, 'Row-S (SS)',     /* L */
		3, 'Row-X (SX)',     /* R */
		4, 'Share',          /* S */
		5, 'S/Row-X (SRX)',  /* C */
		6, 'Exclusive',      /* X */
		to_char(l.lmode)
	) mode_held,
	decode
	(
		l.request,
		0, 'None',           /* Mon Lock equivalent */
		1, 'No Lock',           /* N */
		2, 'Row-S (SS)',     /* L */
		3, 'Row-X (SX)',     /* R */
		4, 'Share',          /* S */
		5, 'S/Row-X (SSX)',  /* C */
		6, 'Exclusive',      /* X */
		to_char(l.request)
	) mode_requested,
	s.osuser,
	s.machine,
	s.program,
	s.process
from
	v$lock l
	join v$session s on s.sid = l.sid
	left outer join sys.dba_waiters lock_blocker on lock_blocker.waiting_session = s.sid
	left outer join sys.dba_waiters lock_waiter on lock_waiter.holding_session = s.sid
	left outer join sys.obj$ o on o.obj# = l.id1
	left outer join cmdtypes ct on ct.action = s.command
	left outer join locktypes lt on lt.lock_type = l.type
where s.type != 'BACKGROUND'
)
select 
	--kaddr,
	sid,
	username,
	waiting_session,
	holding_session,
	object,
	command,
	lock_type,
	lock_description,
	mode_held,
	mode_requested,
	--osuser,
	--machine,
	program,
	process
from dblocks
where object != 'SYS.ORA$BASE'
order by sid, object
/

