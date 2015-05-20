
@clears

set line 80

col cprofile new_value uprofile noprint

col profile format a15
col resource_name format a30 head 'RESOURCE NAME'
col limit format a20

prompt which profile? 
set term off feed off
select '&&1' cprofile from dual;
set term on feed on

break on profile skip 1

ttitle 'Profile Resources for &&uprofile'

select a.profile, a.resource_name, a.limit 
from dba_profiles a
where a.profile like upper('%&&uprofile%')
order by 1,2
/


undef 1

