

-- sp_plan_hash.sql
-- dependencies: sp_plan_table.sql - creates stats_plan_table view
-- inspired by Tom Kyte article
-- http://asktom.oracle.com/pls/ask/f?p=4950:8:::::F4950_P8_DISPLAYID:10353453905351
--
-- input is the hash value of the sql statement in stats$sqltext
-- this will be seen in reports created by spreport.sql in 9i+
-- where the snapshot level is 5+

@clears

col which_hash new_value which_hash noprint
prompt Hash Value of SQL from STAT$SQLTEXT:
set echo off term off head off
select '&1' which_hash from dual;
set term on head on

var hashvar number
begin
	:hashvar := &&which_hash;
end;
/

set line 120

select plan_table_output
from TABLE(
	dbms_xplan.display('stats_plan_table',
		(
			select distinct spu.plan_hash_value || '_stats'
			from stats$sqltext st, stats$sql_plan_usage spu
			where st.hash_value = :hashvar
			and spu.hash_value = st.hash_value
			and spu.text_subset = st.text_subset
		),
		'serial' 
	)
)
/

undef 1


