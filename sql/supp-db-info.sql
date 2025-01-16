
-- supp-db-info.sql
-- show supplemental logging info for the database

@clears

set linesize 200 trimspool on

col supplemental_log_data_all format a6 head 'SUPP|ALL'
col supplemental_log_data_fk format a6 head 'SUPP|FK'
col supplemental_log_data_min format a6 head 'SUPP|MIN'
col supplemental_log_data_pk format a6 head 'SUPP|PK'
col supplemental_log_data_pl format a6 head 'SUPP|PL'
col supplemental_log_data_ui	format a6 head 'SUPP|UI'

set linesize 200 trimspool oni
set pagesize 100


select
	supplemental_log_data_all
	, supplemental_log_data_fk
	, supplemental_log_data_min
	, supplemental_log_data_pk
	, supplemental_log_data_pl
	, supplemental_log_data_ui
from v$database
/
