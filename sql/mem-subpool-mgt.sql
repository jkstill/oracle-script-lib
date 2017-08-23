
-- mem-subpool-mgt.sql
-- How To Determine The Default Number Of Subpools Allocated During Startup [ID 455179.1] 
-- Gathering Initial Troubleshooting Information for Analysis of ORA-4031 Errors on the Shared Pool (Doc ID 1674929.1)
-- Gathering Initial Troubleshooting Information for Analysis of ORA-4031 Errors on the Large Pool (Doc ID 1674933.1)
-- info on Oracle Sub-Pool management
-- tags: subpool, sub-pool, asmm, amm, KSMCHIDX, x$ksmss, _kghdsidx_count
-- 
-- See also:
-- resize-ops-metric-awr.sql
-- resize-ops-metric.sql

set pagesize 60
set linesize 200 trimspool on
set verify off echo off pause off

set feedback off term off
alter session set nls_date_format = 'yyyy-mm-dd hh24:mi:ss';
set feedback on term on

col name format a60 head 'PARAMETER NAME'

prompt
prompt === Shared Pool ===
prompt

col name format a30
col value format 999,999,999,999,999

select name, to_number(value) value
from v$parameter2
where name like '%shared_pool%';

prompt
prompt === Shared Pool Free Memory ===
prompt

col pool format a20
col bytes format 999,999,999,999,999

select pool,name, bytes
from v$sgastat where pool='shared pool'
and name='free memory'
order by bytes desc;

prompt
prompt === Configured number of SGA SubPools ===
prompt


col num format 999999999999999
col value format a30 head 'VALUE'
col description format a30 head 'DESCRIPTION'
column isses_modifiable head 'SESS|MOD?' format a4
column issys_modifiable head 'SYS|MOD?' format a4
column isdefault head 'DEF|VAL?' format a4
column ismodified head 'MODI|FIED?' format a5
column isadjusted head 'ADJU|STED?' format a5

select
	a.KSPPINM NAME
	, a.KSPPDESC DESCRIPTION
	, b.KSPFTCTXVL VALUE
	, decode(b.KSPFTCTXDF,'TRUE','Y','N') ISDEFAULT
	, decode(bitand(ksppiflg/256,1),1,'Y' ,'N') ISSES_MODIFIABLE
	, decode(bitand(ksppiflg/65536,3),1,'I',2,'D', 3,'I','N') ISSYS_MODIFIABLE
	-- M = MODIFIED S = SYSTEM_MOD
	, decode(bitand(KSPFTCTXVF,7),1,'M',4,'S','N') ISMODIFIED
	, decode(bitand(KSPFTCTXVF,2),2,'Y','N') ISADJUSTED
from X$KSPPI a, x$ksppcv2 b
where b.kspftctxpn = a.indx+1
and  a.KSPPINM = '_kghdsidx_count'
/

prompt
prompt === Allocated SGA SubPools ===
prompt


break on subpool
compute sum of bytes on break
compute sum of bytes on report


prompt
prompt ## Some Details ##

select 
	ksmdsidx subpool
	, ksmssnam name
	, ksmsslen bytes 
from x$ksmss
where ksmssnam='free memory' 
	or ksmsslen > (10*1024*1024) --MORE THAN 10mbYTES
order by subpool, name;


prompt
prompt ## Summary ##

select 
	ksmdsidx subpool
	, sum(ksmsslen) bytes 
from x$ksmss
group by ksmdsidx
order by subpool;



