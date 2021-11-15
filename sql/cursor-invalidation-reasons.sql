
-- cursor-invalidation-reasons.sql
-- show why cursors have been invalidated
-- Jared Still
-- jkstill@gmail.com
-- 
-- 2015-08-22
--
-- 2017-11-02 jkstill - see v-dollar-sql_shared_cursor-bug.txt for an issue with v$sql_shared_cursor 
--            (may not be a bug, but my misunderstanding the relationship of the parameter and reason columns)
-- 2017-11-08 jkstill - used xmltable() to decode reason column
--            filter on a single sql_id
--            included optimizer modes, though that does not seem to get populated

col sql_id format a13
col address format a16
col child_address format a16
col child_number format 9999999 head 'CHILD#'
col parameter format a25
col reason format a60
col optimizer_mode_cursor  format a10 head 'OPTIMIZER|MODE|CURSOR'
col optimizer_mode_current  format a10 head 'OPTIMIZER|MODE|CURRENT'

set long 10000

prompt
prompt 'SQL_ID?: '
prompt

ttitle off
set term off head off verify off pause off

col u_sql_id new_value u_sql_id noprint

select '&1' u_sql_id from dual;
set term on feed on head on


set linesize 200 trimspool on

select 
	s.sql_id
	, s.address
	, s.child_address
	, s.child_number
	, decode(x.optimizer_mode_cursor, 1, 'ALL_ROWS',
		2, 'FIRST_ROWS', 
		3, 'RULE', 
		4, 'CHOOSE', x.optimizer_mode_cursor,
		'NA'
	) AS optimizer_mode_cursor
	, decode(x.optimizer_mode_current, 1, 'ALL_ROWS',
		2, 'FIRST_ROWS', 
		3, 'RULE', 
		4, 'CHOOSE', x.optimizer_mode_current,
		'NA'
	) AS optimizer_mode_current
	, s.parameter
	, x.reason
from (
	select sql_id, address, child_address, child_number, reason
		, unbound_cursor , sql_type_mismatch , optimizer_mismatch , outline_mismatch
		, stats_row_mismatch , literal_mismatch , force_hard_parse , explain_plan_cursor
		, buffered_dml_mismatch , pdml_env_mismatch , inst_drtld_mismatch , slave_qc_mismatch
		, typecheck_mismatch , auth_check_mismatch , bind_mismatch , describe_mismatch
		, language_mismatch , translation_mismatch , bind_equiv_failure , insuff_privs
		, insuff_privs_rem , remote_trans_mismatch , logminer_session_mismatch , incomp_ltrl_mismatch
		, overlap_time_mismatch , edition_mismatch , mv_query_gen_mismatch , user_bind_peek_mismatch
		, typchk_dep_mismatch , no_trigger_mismatch , flashback_cursor , anydata_transformation
		, pddl_env_mismatch , top_level_rpi_cursor , different_long_length , logical_standby_apply
		, diff_call_durn , bind_uacs_diff , plsql_cmp_switchs_diff , cursor_parts_mismatch
		, stb_object_mismatch , crossedition_trigger_mismatch , pq_slave_mismatch , top_level_ddl_mismatch
		, multi_px_mismatch , bind_peeked_pq_mismatch , mv_rewrite_mismatch , roll_invalid_mismatch
		, optimizer_mode_mismatch , px_mismatch , mv_staleobj_mismatch , flashback_table_mismatch
		, litrep_comp_mismatch , plsql_debug , load_optimizer_stats , acl_mismatch
		, flashback_archive_mismatch , lock_user_schema_failed , remote_mapping_mismatch , load_runtime_heap_failed
		, hash_match_failed , purged_cursor , bind_length_upgradeable , use_feedback_stats
	from v$sql_shared_cursor
	where sql_id = '&u_sql_id'
)
UNPIVOT (invalidated 
	for parameter in(
		unbound_cursor as           'unbound_cursor'           , sql_type_mismatch as        'sql_type_mismatch'        
		, optimizer_mismatch as       'optimizer_mismatch'       , outline_mismatch as         'outline_mismatch'         
		, stats_row_mismatch as       'stats_row_mismatch'       , literal_mismatch as         'literal_mismatch'         
		, force_hard_parse as         'force_hard_parse'         , explain_plan_cursor as      'explain_plan_cursor'      
		, buffered_dml_mismatch as    'buffered_dml_mismatch'    , pdml_env_mismatch as        'pdml_env_mismatch'        
		, inst_drtld_mismatch as      'inst_drtld_mismatch'      , slave_qc_mismatch as        'slave_qc_mismatch'        
		, typecheck_mismatch as       'typecheck_mismatch'       , auth_check_mismatch as      'auth_check_mismatch'      
		, bind_mismatch as            'bind_mismatch'            , describe_mismatch as        'describe_mismatch'        
		, language_mismatch as        'language_mismatch'        , translation_mismatch as     'translation_mismatch'     
		, bind_equiv_failure as       'bind_equiv_failure'       , insuff_privs as             'insuff_privs'             
		, insuff_privs_rem as         'insuff_privs_rem'         , remote_trans_mismatch as    'remote_trans_mismatch'    
		, logminer_session_mismatch as 'logminer_session_mismatch' , incomp_ltrl_mismatch as     'incomp_ltrl_mismatch'     
		, overlap_time_mismatch as    'overlap_time_mismatch'    , edition_mismatch as         'edition_mismatch'         
		, mv_query_gen_mismatch as    'mv_query_gen_mismatch'    , user_bind_peek_mismatch as  'user_bind_peek_mismatch'  
		, typchk_dep_mismatch as      'typchk_dep_mismatch'      , no_trigger_mismatch as      'no_trigger_mismatch'      
		, flashback_cursor as         'flashback_cursor'         , anydata_transformation as   'anydata_transformation'   
		, pddl_env_mismatch as        'pddl_env_mismatch'        , top_level_rpi_cursor as     'top_level_rpi_cursor'     
		, different_long_length as    'different_long_length'    , logical_standby_apply as    'logical_standby_apply'    
		, diff_call_durn as           'diff_call_durn'           , bind_uacs_diff as           'bind_uacs_diff'           
		, plsql_cmp_switchs_diff as   'plsql_cmp_switchs_diff'   , cursor_parts_mismatch as    'cursor_parts_mismatch'    
		, stb_object_mismatch as            'stb_object_mismatch'           , crossedition_trigger_mismatch as  'crossedition_trigger_mismatch' 
		, pq_slave_mismatch as              'pq_slave_mismatch'             , top_level_ddl_mismatch as         'top_level_ddl_mismatch'        
		, multi_px_mismatch as              'multi_px_mismatch'             , bind_peeked_pq_mismatch as        'bind_peeked_pq_mismatch'       
		, mv_rewrite_mismatch as            'mv_rewrite_mismatch'           , roll_invalid_mismatch as          'roll_invalid_mismatch'         
		, optimizer_mode_mismatch as        'optimizer_mode_mismatch'       , px_mismatch as                    'px_mismatch'                   
		, mv_staleobj_mismatch as           'mv_staleobj_mismatch'          , flashback_table_mismatch as       'flashback_table_mismatch'      
		, litrep_comp_mismatch as           'litrep_comp_mismatch'          , plsql_debug as                    'plsql_debug'                   
		, load_optimizer_stats as           'load_optimizer_stats'          , acl_mismatch as                   'acl_mismatch'                  
		, flashback_archive_mismatch as     'flashback_archive_mismatch'    , lock_user_schema_failed as        'lock_user_schema_failed'       
		, remote_mapping_mismatch as        'remote_mapping_mismatch'       , load_runtime_heap_failed as       'load_runtime_heap_failed'      
		, hash_match_failed as              'hash_match_failed'             , purged_cursor as                  'purged_cursor'                 
		, bind_length_upgradeable as        'bind_length_upgradeable'       , use_feedback_stats as             'use_feedback_stats'  
	)
) s,
-- XML from Troubleshooting Oracle Performance Version 2, Christian Antognini
XMLTable('/Root'
	PASSING XMLType('<Root>'||reason||'</Root>')
	COLUMNS child_number NUMBER                  PATH '/Root/ChildNode[1]/ChildNumber',
		id NUMBER                            PATH '/Root/ChildNode[1]/ID',
		reason VARCHAR2(100)                 PATH '/Root/ChildNode[1]/reason',
		optimizer_mode_hinted_cursor NUMBER  PATH '/Root/ChildNode[1]/optimizer_mode_hinted_cursor',
		optimizer_mode_cursor NUMBER         PATH '/Root/ChildNode[1]/optimizer_mode_cursor',
		optimizer_mode_current NUMBER        PATH '/Root/ChildNode[1]/optimizer_mode_current'
) x
where invalidated = 'Y'
order by sql_id, child_number
/


