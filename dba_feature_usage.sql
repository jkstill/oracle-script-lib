
-- dba_feature_usage.sql
-- Jared Still - jkstill@gmail.com

@clears
col detected_usages head 'DETECTED|USAGES' format 9999999
col name format a45
col feature_info format a40 wrapped

spool feature_usage_report.log

-- this is somewhat useless
--select output from table(DBMS_FEATURE_USAGE_REPORT.display_text);

-- this is more better

@title 'Oracle Features Currently In Use' 200

SELECT NAME, detected_usages, last_usage_date, first_usage_date, feature_info
FROM dba_feature_usage_statistics
WHERE currently_used = 'TRUE'
order by name
/

@title 'Oracle Features NOT Currently in Use, But Have Been' 200

SELECT NAME, detected_usages, last_usage_date, first_usage_date, feature_info
FROM dba_feature_usage_statistics
WHERE currently_used = 'FALSE'
and detected_usages > 0
order by name
/

spool off

ed feature_usage_report.log
