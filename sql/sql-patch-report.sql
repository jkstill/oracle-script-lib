

-- sql-patch-report.sql
-- report on sql patches created with dbms_diag

set linesize 200 trimspool on
set pagesize 100

col name           format a30 head 'Name'
col created        format a28 head 'Created'
col last_modified  format a28 head 'Last Modified'
col description    format a50 head 'Description'
col status         format a8  head 'Status'
col force_matching format a3  head 'Frc|Mtch'

select
	name
	--, created
	, last_modified
	, description
	, status
	, force_matching
from dba_sql_patches p
order by name
/

