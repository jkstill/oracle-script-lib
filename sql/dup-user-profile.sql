
@clears

col v_source_profile new_value v_source_profile noprint
col v_target_profile new_value v_target_profile noprint

prompt source profile: 
set term off
select upper('&1') v_source_profile from dual;
set term on

prompt target profile: 
set term off
select upper('&2') v_target_profile from dual;
set term on

@clear_for_spool

select 'create profile &v_target_profile' from dual
union all
select '  limit' from dual
union all
select 
	'     ' || lower(a.resource_name) || ' ' || lower(a.limit)
from dba_profiles a
where a.profile like '&v_source_profile'
/

@clears

