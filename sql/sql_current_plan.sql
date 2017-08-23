

-- sql_current_plan.sql
-- must first run dynamic_plan_table.sql
-- get hash value from sql_current.sql
--
-- from Tom Kyte - http://asktom.oracle.com/pls/ask/f?p=4950:8:::::F4950_P8_DISPLAYID:10353453905351
-- plug in the hash value

@clears

set line 200

spool sql_current_plan.txt

select plan_table_output
from
	TABLE(
		dbms_xplan.display (
			'dynamic_plan_table',
			(
				select min(x) x
				from (
				select rawtohex(address)||'_'||child_number x
				from v$sql
				where hash_value = 3296599010
				)
			),
			'serial'
		)
	)
/

spool off

