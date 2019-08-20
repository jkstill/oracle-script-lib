
-- oradebug_doc.sql
-- generate all docs for oradebug
-- 11g - not sure about 10g

@clear_for_spool

spool oradebug_docs.txt

prompt #############################
prompt ## oradebug doc event 
prompt #############################
prompt   ########################
prompt   ## name 
prompt   ########################
-- DIAG
oradebug doc event
oradebug doc event name
oradebug doc event name trace
oradebug doc event name disable_dde_action
oradebug doc event name ams_trace
oradebug doc event name ams_rowsrc_trace
oradebug doc event name trace sweep_verification
oradebug doc event name trace enable_xml_inc_staging

-- RDBMS
oradebug doc event name alert_text
oradebug doc event name sql_monitor
oradebug doc event name sql_trace
oradebug doc event name pmon_startup
oradebug doc event name background_startup

-- GENERIC
oradebug doc event name kg_event

-- CLIENT
oradebug doc event name oci_trace

prompt   #############################
prompt   ## scope 
prompt   #############################
oradebug doc event scope
oradebug doc event scope sql

prompt   #############################
prompt   ## filter 
prompt   #############################
oradebug doc event filter
oradebug doc event filter occurence
oradebug doc event filter callstack
oradebug doc event filter tag
oradebug doc event filter process
oradebug doc event filter pgadep
oradebug doc event filter errarg

prompt   #############################
prompt   ## action 
prompt   #############################

oradebug doc event action

prompt     #############################
prompt     ## diag 
prompt     #############################

-- DIAG:
---------------------------
oradebug doc event action dumpFrameContext
oradebug doc event action dumpBuckets
oradebug doc event action kgsfdmp
oradebug doc event action dumpDiagCtx
oradebug doc event action dumpDbgecPopLoc
oradebug doc event action dumpDbgecMarks
oradebug doc event action dumpGenralConfiguration
oradebug doc event action dumpADRLockTable
oradebug doc event action act1
oradebug doc event action action1
oradebug doc event action action2
oradebug doc event action UTDumpGC
oradebug doc event action dbgvci_action_signal_crash

prompt     #############################
prompt     ## rdbms 
prompt     #############################

-- RDBMS:
---------------------------
oradebug doc event action incident
oradebug doc event action sqlmon_dump
oradebug doc event action flashfreeze
oradebug doc event action oradebug
oradebug doc event action debugger
oradebug doc event action debug
oradebug doc event action crash
oradebug doc event action eventdump
oradebug doc event action kdlut_bucketdump_action
oradebug doc event action kzxt_dump_action
oradebug doc event action dumpKernelDiagState
oradebug doc event action HMCHECK
oradebug doc event action DATA_BLOCK_INTEGRITY_CHECK
oradebug doc event action CF_BLOCK_INTEGRITY_CHECK
oradebug doc event action DB_STRUCTURE_INTEGRITY_CHECK
oradebug doc event action REDO_INTEGRITY_CHECK
oradebug doc event action TRANSACTION_INTEGRITY_CHECK
oradebug doc event action SQL_TESTCASE_REC
oradebug doc event action SQL_TESTCASE_REC_DATA
oradebug doc event action ORA_12751_DUMP
oradebug doc event action sqladv_dump_dumpctx
oradebug doc event action ORA_4030_DUMP
oradebug doc event action HNGDET_MEM_USAGE_DUMP_NOARGS
oradebug doc event action kcfis_action
oradebug doc event action exadata_dump_modvers
oradebug doc event action QUERY_BLOCK_DUMP
oradebug doc event action ASM_MOUNT_FAIL_CHECK
oradebug doc event action ASM_ALLOC_FAIL_CHECK
oradebug doc event action ASM_ADD_DISK_CHECK
oradebug doc event action ASM_FILE_BUSY_CHECK
oradebug doc event action KJZN_ASYNC_SYSTEM_STATE
oradebug doc event action KSI_GET_TRACE
oradebug doc event action TRACE_BUFFER_ON
oradebug doc event action TRACE_BUFFER_OFF
oradebug doc event action LATCHES
oradebug doc event action XS_SESSION_STATE
oradebug doc event action PROCESSSTATE
oradebug doc event action SYSTEMSTATE
oradebug doc event action INSTANTIATIONSTATE
oradebug doc event action CONTEXTAREA
oradebug doc event action HEAPDUMP
oradebug doc event action POKE_LENGTH
oradebug doc event action POKE_VALUE
oradebug doc event action POKE_VALUE0
oradebug doc event action GLOBAL_AREA
oradebug doc event action REALFREEDUMP
oradebug doc event action FLUSH_JAVA_POOL
oradebug doc event action PGA_DETAIL_GET
oradebug doc event action PGA_DETAIL_DUMP
oradebug doc event action PGA_DETAIL_CANCEL
oradebug doc event action PGA_SUMMARY
oradebug doc event action MODIFIED_PARAMETERS
oradebug doc event action ERRORSTACK
oradebug doc event action CALLSTACK
oradebug doc event action RECORD_CALLSTACK
oradebug doc event action BG_MESSAGES
oradebug doc event action ENQUEUES
oradebug doc event action KSTDUMPCURPROC
oradebug doc event action KSTDUMPALLPROCS
oradebug doc event action KSTDUMPALLPROCS_CLUSTER
oradebug doc event action KSKDUMPTRACE
oradebug doc event action DBSCHEDULER
oradebug doc event action LDAP_USER_DUMP
oradebug doc event action LDAP_KERNEL_DUMP
oradebug doc event action DUMP_ALL_OBJSTATS
oradebug doc event action DUMPGLOBALDATA
oradebug doc event action HANGANALYZE
oradebug doc event action HANGANALYZE_PROC
oradebug doc event action HANGANALYZE_GLOBAL
oradebug doc event action HNGDET_MEM_USAGE_DUMP
oradebug doc event action GES_STATE
oradebug doc event action OCR
oradebug doc event action CSS
oradebug doc event action CRS
oradebug doc event action SYSTEMSTATE_GLOBAL
oradebug doc event action DUMP_ALL_COMP_GRANULE_ADDRS
oradebug doc event action DUMP_ALL_COMP_GRANULES
oradebug doc event action DUMP_ALL_REQS
oradebug doc event action DUMP_TRANSFER_OPS
oradebug doc event action DUMP_ADV_SNAPSHOTS
oradebug doc event action CONTROLF
oradebug doc event action FLUSH_CACHE
oradebug doc event action BUFFERS
oradebug doc event action SET_TSN_P1
oradebug doc event action BUFFER
oradebug doc event action BC_SANITY_CHECK
oradebug doc event action SET_NBLOCKS
oradebug doc event action CHECK_ROREUSE_SANITY
oradebug doc event action DUMP_PINNED_BUFFER_HISTORY
oradebug doc event action REDOLOGS
oradebug doc event action LOGHIST
oradebug doc event action REDOHDR
oradebug doc event action LOCKS
oradebug doc event action GC_ELEMENTS
oradebug doc event action FILE_HDRS
oradebug doc event action KRB_TRACE
oradebug doc event action FBINC
oradebug doc event action FBHDR
oradebug doc event action FLASHBACK_GEN
oradebug doc event action KTPR_DEBUG
oradebug doc event action DUMP_TEMP
oradebug doc event action DROP_SEGMENTS
oradebug doc event action TREEDUMP
oradebug doc event action KDLIDMP
oradebug doc event action ROW_CACHE
oradebug doc event action LIBRARY_CACHE
oradebug doc event action CURSORDUMP
oradebug doc event action CURSOR_STATS
oradebug doc event action SHARED_SERVER_STATE
oradebug doc event action LISTENER_REGISTRATION
oradebug doc event action JAVAINFO
oradebug doc event action KXFPCLEARSTATS
oradebug doc event action KXFPDUMPTRACE
oradebug doc event action KXFXSLAVESTATE
oradebug doc event action KXFXCURSORSTATE
oradebug doc event action WORKAREATAB_DUMP
oradebug doc event action OBJECT_CACHE
oradebug doc event action SAVEPOINTS
oradebug doc event action RULESETDUMP
oradebug doc event action FAILOVER
oradebug doc event action OLAP_DUMP
oradebug doc event action AWR_FLUSH_TABLE_ON
oradebug doc event action AWR_FLUSH_TABLE_OFF
oradebug doc event action ASHDUMP
oradebug doc event action ASHDUMPSECONDS
oradebug doc event action HM_FW_TRACE
oradebug doc event action IR_FW_TRACE
oradebug doc event action HEAPDUMP_ADDR
oradebug doc event action POKE_ADDRESS
oradebug doc event action CURSORTRACE
oradebug doc event action RULESETDUMP_ADDR

prompt     #############################
prompt     ## generic 
prompt     #############################

-- GENERIC:
oradebug doc event action xdb_dump_buckets
oradebug doc event action dumpKGERing
oradebug doc event action dumpKGEState

prompt     #############################
prompt     ## client 
prompt     #############################

-- CLIENT:
oradebug doc event action kpuActionDefault
oradebug doc event action kpuActionSignalCrash
oradebug doc event action kpudpaActionDpapi

-- ######################################################################
-- ######################################################################
-- ######################################################################

prompt #############################
prompt ## oradebug doc component 
prompt #############################

oradebug doc component

spool off

prompt
prompt #####################################################
prompt ## output is in oradebug_docs.txt
prompt #####################################################
prompt


@clears

