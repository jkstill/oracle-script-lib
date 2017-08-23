SET VERIFY OFF
SET LINESIZE 300

COLUMN value FORMAT 9999999
COLUMN sql_feature FORMAT A35
COLUMN optimizer_feature_enable FORMAT A9
COLUMN event format 999999

SELECT *
FROM   v$system_fix_control
order by sql_feature
/

undef 1 2

