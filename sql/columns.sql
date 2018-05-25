
col sid format 9999
col directory_path format a60
col blocks format 99,999,999 head 'BLOCKS'
col db_link format a30 head 'DB LINK'
col db_link_instance format a30 head 'DB LINK|INSTANCE'
col db_link_username format a10 head 'DB LINK|USERNAME'
col empty_blocks format 99,999,999 head 'EMPTY BLOCKS'
col host format a10 head 'HOST'
col index_name format a30 head 'INDEX NAME'
col initial_extent format 9,999,999,999 head 'INITIAL|EXTENT'
col instance format a4 head 'INST'
col max_blocks format 9,999,999 head 'MAX BLOCKS'
col max_bytes format 999,999,999,999 head 'MAX BYTES'
col bytes format 999,999,999,999 head 'BYTES'
col max_extents format 999,999 head 'MAX|EXTENTS'
col min_extents format 999 head 'MIN|EXT'
col next_extent format 9,999,999,999 head 'NEXT|EXTENT'
col object_name format a30 head 'OBJECT NAME'
col owner format a12 head 'OWNER'
col pct_free format 999 head 'PCT|FREE'
col pct_increase format 999 head 'PCT|INC'
col pct_used format 999 head 'PCT|USED'
col synonym_name format a30 head 'SYNONYM NAME'
col table_name format a30 head 'TABLE NAME'
col table_owner format a12 head 'TABLE|OWNER'
col tablespace_name format a15 head 'TABLESPACE|NAME'
col timestamp format a19 head 'TIME STAMP'
col username format a20 head 'USERNAME'
col last_ddl_time head 'LAST DDL|TIME'
col created head 'CREATED'
col procedure_name format a30 head 'PROCEDURE NAME'
col function_name format a30 head 'FUNCTION NAME'
col package_name format a30 head 'PACKAGE NAME'
col package_body_name format a30 head 'PACKAGE BODY NAME'
col segment_name format a30 head 'SEGMENT NAME'
col column_name format a30 head 'COLUMN'
col constraint_name format a30
col columns format a30
col last_name format a20
col first_name format a15
col person_type format a20
col name format a30
col value format a60

-- show paramater/spparameter settings

column   sid_col_plus_show_spparam      on      format    a8   heading sid
column   value_col_plus_show_spparam    on      format   a28   heading value
column   name_col_plus_show_spparam     on      format   a29   heading name
column   value_col_plus_show_param      on      format   a30   heading value
column   name_col_plus_show_param       on      format   a36   heading name


