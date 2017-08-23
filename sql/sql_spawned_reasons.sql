
-- sql_spawned_reasons.sql
-- show reasons why new sql spawned
-- 


@clears

col v_sqlid new_value v_sqlid noprint
col v_childnum new_value v_childnum noprint

prompt
prompt SQL_ID:
set term off feed off
select '&1' v_sqlid from dual;
set term on feed on

prompt
prompt Child #:
set term off feed off
select '&2' v_childnum from dual;
set term on feed on


with cols as (
	--select 'INST_ID' colname from dual union all
	select 'SQL_ID' colname from dual union all
	select 'ADDRESS' colname from dual union all
	select 'CHILD_ADDRESS' colname from dual union all
	select 'CHILD_NUMBER' colname from dual union all
	select 'UNBOUND_CURSOR' colname from dual union all
	select 'SQL_TYPE_MISMATCH' colname from dual union all
	select 'OPTIMIZER_MISMATCH' colname from dual union all
	select 'OUTLINE_MISMATCH' colname from dual union all
	select 'STATS_ROW_MISMATCH' colname from dual union all
	select 'LITERAL_MISMATCH' colname from dual union all
	--select 'SEC_DEPTH_MISMATCH' colname from dual union all  -- 10g
	select 'EXPLAIN_PLAN_CURSOR' colname from dual union all
	select 'BUFFERED_DML_MISMATCH' colname from dual union all
	select 'PDML_ENV_MISMATCH' colname from dual union all
	select 'INST_DRTLD_MISMATCH' colname from dual union all
	select 'SLAVE_QC_MISMATCH' colname from dual union all
	select 'TYPECHECK_MISMATCH' colname from dual union all
	select 'AUTH_CHECK_MISMATCH' colname from dual union all
	select 'BIND_MISMATCH' colname from dual union all
	select 'DESCRIBE_MISMATCH' colname from dual union all
	select 'LANGUAGE_MISMATCH' colname from dual union all
	select 'TRANSLATION_MISMATCH' colname from dual union all
	--select 'ROW_LEVEL_SEC_MISMATCH' colname from dual union all -- 10g
	select 'INSUFF_PRIVS' colname from dual union all
	select 'INSUFF_PRIVS_REM' colname from dual union all
	select 'REMOTE_TRANS_MISMATCH' colname from dual union all
	select 'LOGMINER_SESSION_MISMATCH' colname from dual union all
	select 'INCOMP_LTRL_MISMATCH' colname from dual union all
	select 'OVERLAP_TIME_MISMATCH' colname from dual union all
	--select 'SQL_REDIRECT_MISMATCH' colname from dual union all -- 10g
	select 'MV_QUERY_GEN_MISMATCH' colname from dual union all
	select 'USER_BIND_PEEK_MISMATCH' colname from dual union all
	select 'TYPCHK_DEP_MISMATCH' colname from dual union all
	select 'NO_TRIGGER_MISMATCH' colname from dual union all
	select 'FLASHBACK_CURSOR' colname from dual union all
	select 'ANYDATA_TRANSFORMATION' colname from dual union all
	--select 'INCOMPLETE_CURSOR' colname from dual union all -- 10g
	select 'TOP_LEVEL_RPI_CURSOR' colname from dual union all
	select 'DIFFERENT_LONG_LENGTH' colname from dual union all
	select 'LOGICAL_STANDBY_APPLY' colname from dual union all
	select 'DIFF_CALL_DURN' colname from dual union all
	select 'BIND_UACS_DIFF' colname from dual union all
	select 'PLSQL_CMP_SWITCHS_DIFF' colname from dual union all
	select 'CURSOR_PARTS_MISMATCH' colname from dual union all
	select 'STB_OBJECT_MISMATCH' colname from dual union all
	--select 'ROW_SHIP_MISMATCH' colname from dual union all -- 10g
	select 'PQ_SLAVE_MISMATCH' colname from dual union all
	select 'TOP_LEVEL_DDL_MISMATCH' colname from dual union all
	select 'MULTI_PX_MISMATCH' colname from dual union all
	select 'BIND_PEEKED_PQ_MISMATCH' colname from dual union all
	select 'MV_REWRITE_MISMATCH' colname from dual union all
	select 'ROLL_INVALID_MISMATCH' colname from dual union all
	select 'OPTIMIZER_MODE_MISMATCH' colname from dual union all
	select 'PX_MISMATCH' colname from dual union all
	select 'MV_STALEOBJ_MISMATCH' colname from dual union all
	select 'FLASHBACK_TABLE_MISMATCH' colname from dual union all
	select 'LITREP_COMP_MISMATCH' colname from dual
),
reasons as (
select c.colname,
case c.colname
	--when 'INST_ID' then to_char(s.INST_ID)
	when 'SQL_ID' then s.SQL_ID
	when 'ADDRESS' then rawtohex(s.ADDRESS)
	when 'CHILD_ADDRESS' then rawtohex(s.CHILD_ADDRESS)
	when 'CHILD_NUMBER' then to_char(s.CHILD_NUMBER)
	when 'UNBOUND_CURSOR' then s.UNBOUND_CURSOR
	when 'SQL_TYPE_MISMATCH' then s.SQL_TYPE_MISMATCH
	when 'OPTIMIZER_MISMATCH' then s.OPTIMIZER_MISMATCH
	when 'OUTLINE_MISMATCH' then s.OUTLINE_MISMATCH
	when 'STATS_ROW_MISMATCH' then s.STATS_ROW_MISMATCH
	when 'LITERAL_MISMATCH' then s.LITERAL_MISMATCH
	--when 'SEC_DEPTH_MISMATCH' then s.SEC_DEPTH_MISMATCH -- 10g
	when 'EXPLAIN_PLAN_CURSOR' then s.EXPLAIN_PLAN_CURSOR
	when 'BUFFERED_DML_MISMATCH' then s.BUFFERED_DML_MISMATCH
	when 'PDML_ENV_MISMATCH' then s.PDML_ENV_MISMATCH
	when 'INST_DRTLD_MISMATCH' then s.INST_DRTLD_MISMATCH
	when 'SLAVE_QC_MISMATCH' then s.SLAVE_QC_MISMATCH
	when 'TYPECHECK_MISMATCH' then s.TYPECHECK_MISMATCH
	when 'AUTH_CHECK_MISMATCH' then s.AUTH_CHECK_MISMATCH
	when 'BIND_MISMATCH' then s.BIND_MISMATCH
	when 'DESCRIBE_MISMATCH' then s.DESCRIBE_MISMATCH
	when 'LANGUAGE_MISMATCH' then s.LANGUAGE_MISMATCH
	when 'TRANSLATION_MISMATCH' then s.TRANSLATION_MISMATCH
	--when 'ROW_LEVEL_SEC_MISMATCH' then s.ROW_LEVEL_SEC_MISMATCH -- 10g
	when 'INSUFF_PRIVS' then s.INSUFF_PRIVS
	when 'INSUFF_PRIVS_REM' then s.INSUFF_PRIVS_REM
	when 'REMOTE_TRANS_MISMATCH' then s.REMOTE_TRANS_MISMATCH
	when 'LOGMINER_SESSION_MISMATCH' then s.LOGMINER_SESSION_MISMATCH
	when 'INCOMP_LTRL_MISMATCH' then s.INCOMP_LTRL_MISMATCH
	when 'OVERLAP_TIME_MISMATCH' then s.OVERLAP_TIME_MISMATCH
	--when 'SQL_REDIRECT_MISMATCH' then s.SQL_REDIRECT_MISMATCH -- 10g
	when 'MV_QUERY_GEN_MISMATCH' then s.MV_QUERY_GEN_MISMATCH
	when 'USER_BIND_PEEK_MISMATCH' then s.USER_BIND_PEEK_MISMATCH
	when 'TYPCHK_DEP_MISMATCH' then s.TYPCHK_DEP_MISMATCH
	when 'NO_TRIGGER_MISMATCH' then s.NO_TRIGGER_MISMATCH
	when 'FLASHBACK_CURSOR' then s.FLASHBACK_CURSOR
	when 'ANYDATA_TRANSFORMATION' then s.ANYDATA_TRANSFORMATION
	--when 'INCOMPLETE_CURSOR' then s.INCOMPLETE_CURSOR -- 10g
	when 'TOP_LEVEL_RPI_CURSOR' then s.TOP_LEVEL_RPI_CURSOR
	when 'DIFFERENT_LONG_LENGTH' then s.DIFFERENT_LONG_LENGTH
	when 'LOGICAL_STANDBY_APPLY' then s.LOGICAL_STANDBY_APPLY
	when 'DIFF_CALL_DURN' then s.DIFF_CALL_DURN
	when 'BIND_UACS_DIFF' then s.BIND_UACS_DIFF
	when 'PLSQL_CMP_SWITCHS_DIFF' then s.PLSQL_CMP_SWITCHS_DIFF
	when 'CURSOR_PARTS_MISMATCH' then s.CURSOR_PARTS_MISMATCH
	when 'STB_OBJECT_MISMATCH' then s.STB_OBJECT_MISMATCH
	--when 'ROW_SHIP_MISMATCH' then s.ROW_SHIP_MISMATCH -- 10g
	when 'PQ_SLAVE_MISMATCH' then s.PQ_SLAVE_MISMATCH
	when 'TOP_LEVEL_DDL_MISMATCH' then s.TOP_LEVEL_DDL_MISMATCH
	when 'MULTI_PX_MISMATCH' then s.MULTI_PX_MISMATCH
	when 'BIND_PEEKED_PQ_MISMATCH' then s.BIND_PEEKED_PQ_MISMATCH
	when 'MV_REWRITE_MISMATCH' then s.MV_REWRITE_MISMATCH
	when 'ROLL_INVALID_MISMATCH' then s.ROLL_INVALID_MISMATCH
	when 'OPTIMIZER_MODE_MISMATCH' then s.OPTIMIZER_MODE_MISMATCH
	when 'PX_MISMATCH' then s.PX_MISMATCH
	when 'MV_STALEOBJ_MISMATCH' then s.MV_STALEOBJ_MISMATCH
	when 'FLASHBACK_TABLE_MISMATCH' then s.FLASHBACK_TABLE_MISMATCH
	when 'LITREP_COMP_MISMATCH' then s.LITREP_COMP_MISMATCH
end value
--from gv$sql_shared_cursor s
from v$sql_shared_cursor s
cross join cols c
--where s.inst_id = 1
where s.sql_id = '&&v_sqlid'
	and s.child_number = &&v_childnum
)
select *
from reasons
where value != 'N'
/


