
-- plsql_called_objects.sql
-- show PL/SQL entry objects and currently executing objects
-- as shown in v$session
-- requireds 10g+

SELECT sid
,      serial#
,      username
,      ( SELECT max( substr( sql_text , 1, 40 )) FROM v$sql sq WHERE sq.sql_id = se.sql_id ) AS sql_text
,      ( SELECT object_name    FROM dba_procedures WHERE object_id = plsql_entry_object_id AND subprogram_id = 0) AS plsql_entry_object
,      ( SELECT procedure_name FROM dba_procedures WHERE object_id = plsql_entry_object_id AND subprogram_id = plsql_entry_subprogram_id) AS plsql_entry_subprogram
,      ( SELECT object_name    FROM dba_procedures WHERE object_id = plsql_object_id       AND subprogram_id = 0) AS plsql_entry_object
,      ( SELECT procedure_name FROM dba_procedures WHERE object_id = plsql_object_id       AND subprogram_id = PLSQL_SUBPROGRAM_ID) AS plsql_entry_subprogram
--,      se.*
FROM   v$session se
WHERE  1=1
-- AND    se.status = 'ACTIVE'
AND    sid = 369
-- AND    plsql_entry_object_id IS NOT NULL
ORDER BY se.sid
