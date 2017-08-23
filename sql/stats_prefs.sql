
select 'METHOD_OPT' name, dbms_stats.get_prefs('METHOD_OPT') value  from dual
union all
select 'ESTIMATE_PERCENT' name, dbms_stats.get_prefs('ESTIMATE_PERCENT') value from dual
union all
select 'GRANULARITY' name, dbms_stats.get_prefs('GRANULARITY') value from dual
union all
select 'CONCURRENT STATS GATHER' name, dbms_stats.get_prefs('CONCURRENT','SH') from dual
/


