
-- get-schema-size.sql
-- Jared Still
-- estimate of size for export
-- indexes are excluded
-- most system accounts excluded
-- use the 'oracle_maintained' column if available
-- the hard coded list is here so it would work on 10g

set linesize 200 trimspool on
set tab off
set pagesize 100

col owner format a30
col segment_name format a30
col segment_type format a30
col size_m format 99,999,999


clear break
break on owner skip 1 on segment_type on report
compute sum of size_m on owner
compute sum of size_m on segment_type
compute sum of size_m on report

select distinct
   owner
   , segment_type
   --, segment_name
   , sum(( s.blocks * ts.block_size) / power(2,20)) over (partition by owner, segment_type)  size_m
from dba_segments s
join dba_tablespaces ts on ts.tablespace_name = s.tablespace_name
where
   segment_type not like 'INDEX%'
   and segment_type not in (
      'CLUSTER'
      ,'ROLLBACK'
      ,'SYSTEM STATISTICS'
      ,'TYPE2 UNDO'
   )
   and owner not in (
   'ANONYMOUS'
   ,'APPQOSSYS'
   ,'AUDSYS'
   ,'CTXSYS'
   ,'DBSFWUSER'
   ,'DBSNMP'
   ,'DIP'
   ,'DVF'
   ,'DVSYS'
   ,'GGSYS'
   ,'GSMADMIN_INTERNAL'
   ,'GSMCATUSER'
   ,'GSMROOTUSER'
   ,'GSMUSER'
   ,'LBACSYS'
   ,'MDDATA'
   ,'MDSYS'
   ,'OJVMSYS'
   ,'OLAPSYS'
   ,'ORACLE_OCM'
   ,'ORDDATA'
   ,'ORDPLUGINS'
   ,'ORDSYS'
   ,'OUTLN'
   ,'REMOTE_SCHEDULER_AGENT'
   ,'SI_INFORMTN_SCHEMA'
   ,'SYS$UMF'
   ,'SYS'
   ,'SYSBACKUP'
   ,'SYSDG'
   ,'SYSKM'
   ,'SYSRAC'
   ,'SYSTEM'
   ,'WMSYS'
   ,'XDB'
   ,'XS$NULL'
)
order by
   owner
   , segment_type
   --, segment_name
/
