
-- stat.sql
-- Timur Akhmadeev - akhmadeev@.com
--
-- @stat table_name
-- or
-- @stat table_name owner

set echo off feed off termout off
set linesize 180 trimspool on
set pagesize 60

repheader off
ttitle off

col num_rows                format a6                   heading 'Num|rows'                  justify right
col avg_row_len             format 9999                 heading 'Avg|len'
col blocks                  format a6                   heading 'Blocks'                    justify right
col seg_size                format 9999.99              heading 'Segment|GB'
col sample_size             format a6                   heading 'Sample'                    justify right
col user_stats              format a5                   heading 'User|stats'
col temporary               format a2                   heading 'Te|mp'
col degree                  format a3                   heading 'DOP'
col partitioned             format a3                   heading 'Partitioned'
col iot_type                format a3                   

col data_type               format a15                  truncate
col avg_col_len             format 9999                 heading 'Avg|len'
col num_distinct            format a6                   heading 'Num di|stinct'
col density                 format 9.99EEEE
col num_nulls               format a6                   heading 'Num|nulls'                 justify right
col num_buckets             format 999                  heading 'Buck|ets'
col low_value               format a20                                                      trunc
col high_value              format a20                                                      trunc

col index_name              format a30                  
col column_name             format a30                  truncate
col prefix_length           format 99                   heading 'Pre|fix'
col avg_leaf_blocks_per_key format 999,999              heading 'Leafs|per key'
col avg_data_blocks_per_key format 999,999              heading 'Data|per key'
col clustering_factor       format a6                   heading 'Cluste|ring'               justify right
col blevel                  format 99                   heading 'BLev'
col leaf_blocks             format a6                   heading 'Leaf|blocks'               justify right
col distinct_keys           format 999,999,999          heading 'Distinct|keys'
col rows_per_key            format 999,999,999          heading 'Rows per key'

col p1 new_value 1
col p2 new_value 2
select null p1, null p2 from dual where 1 = 2;

var tab_name varchar2(30)
var owner varchar2(30)
exec :tab_name := upper('&1');
exec :owner := case when upper('&2') is null then user else upper('&2') end;

set termout on

ttitle left 'Table statistics'

select lpad(case when num_rows < 1e5 then num_rows || ' '
                 when num_rows < 1e8 then round(num_rows / 1e3) || 'K'
                 when num_rows < 1e11 then round(num_rows / 1e6) || 'M'
                 else round(num_rows / 1e9) || 'G'
            end, 6, ' '
       ) num_rows
     , avg_row_len
     , lpad(case when blocks < 1e5 then blocks || ' '
                 when blocks < 1e8 then round(blocks / 1e3) || 'K'
                 when blocks < 1e11 then round(blocks / 1e6) || 'M'
                 else round(blocks / 1e9) || 'G'
            end, 6, ' '
       ) blocks
     , (select sum(bytes)/1024/1024/1024 from dba_segments where segment_name = table_name and owner = :owner) seg_size
     , lpad(case when sample_size < 1e5 then sample_size || ' '
                 when sample_size < 1e8 then round(sample_size / 1e3) || 'K'
                 when sample_size < 1e11 then round(sample_size / 1e6) || 'M'
                 else round(sample_size / 1e9) || 'G'
            end, 6, ' '
       ) sample_size
     , last_analyzed
     , user_stats
     , temporary
     , compression
     , substr(replace(degree, ' '), 1, 3) degree
     , partitioned
     , iot_type
  from dba_tables t 
 where table_name = :tab_name
   and owner = :owner;

ttitle left "Column statistics"

select column_name
     , avg_col_len
     , data_type || decode(data_type, 'NUMBER', '(' || data_precision || decode(data_scale, 0, null, ',' || data_scale) || ')'
                                    , 'VARCHAR2', '(' || data_length || ')'
                                    , null
       ) data_type
     , lpad(case when num_distinct < 1e5 then num_distinct || ' '
                 when num_distinct < 1e8 then round(num_distinct / 1e3) || 'K'
                 when num_distinct < 1e11 then round(num_distinct / 1e6) || 'M'
                 else round(num_distinct / 1e9) || 'G'
            end, 6, ' '
       ) num_distinct
     , density
     , lpad(case when num_nulls < 1e5 then num_nulls || ' '
                 when num_nulls < 1e8 then round(num_nulls / 1e3) || 'K'
                 when num_nulls < 1e11 then round(num_nulls / 1e6) || 'M'
                 else round(num_nulls / 1e9) || 'G'
            end, 6, ' '
       ) num_nulls
     , num_buckets
     , user_stats
     , lpad(case when sample_size < 1e5 then sample_size || ' '
                 when sample_size < 1e8 then round(sample_size / 1e3) || 'K'
                 when sample_size < 1e11 then round(sample_size / 1e6) || 'M'
                 else round(sample_size / 1e9) || 'G'
            end, 6, ' '
       ) sample_size
     , decode(data_type, 'NUMBER', to_char(utl_raw.cast_to_number(low_value)),
                         'VARCHAR2', utl_raw.cast_to_varchar2(low_value),
                         'CHAR', utl_raw.cast_to_varchar2(low_value)
       ) low_value
     , decode(data_type, 'NUMBER', to_char(utl_raw.cast_to_number(high_value)),
                         'VARCHAR2', utl_raw.cast_to_varchar2(high_value),
                         'CHAR', utl_raw.cast_to_varchar2(high_value)
       ) high_value
  from dba_tab_cols
 where table_name = :tab_name
   and owner = :owner
 order by column_id;
 
ttitle left Histogram data for NUMBER columns
select *
  from dba_tab_histograms h
 where 1=0
  

ttitle left "Index statistics"
break on index_name skip 1

select ui.index_name
     , uic.column_name
     , prefix_length
     , blevel
     , lpad(case when leaf_blocks < 1e5 then leaf_blocks || ' '
                 when leaf_blocks < 1e8 then round(leaf_blocks / 1e3) || 'K'
                 when leaf_blocks < 1e11 then round(leaf_blocks / 1e6) || 'M'
                 else round(leaf_blocks / 1e9) || 'G'
            end, 6, ' '
       ) leaf_blocks
     , avg_leaf_blocks_per_key
     , avg_data_blocks_per_key
--     , distinct_keys
     , (num_rows / nullif(distinct_keys, 0)) rows_per_key
     , lpad(case when num_rows < 1e5 then num_rows || ' '
                 when num_rows < 1e8 then round(num_rows / 1e3) || 'K'
                 when num_rows < 1e11 then round(num_rows / 1e6) || 'M'
                 else round(num_rows / 1e9) || 'G'
            end, 6, ' '
       ) num_rows
     , lpad(case when clustering_factor < 1e5 then clustering_factor || ' '
                 when clustering_factor < 1e8 then round(clustering_factor / 1e3) || 'K'
                 when clustering_factor < 1e11 then round(clustering_factor / 1e6) || 'M'
                 else round(clustering_factor / 1e9) || 'G'
            end, 6, ' '
       ) clustering_factor
     , lpad(case when sample_size < 1e5 then sample_size || ' '
                 when sample_size < 1e8 then round(sample_size / 1e3) || 'K'
                 when sample_size < 1e11 then round(sample_size / 1e6) || 'M'
                 else round(sample_size / 1e9) || 'G'
            end, 6, ' '
       ) sample_size
     , user_stats
     , substr(replace(degree, ' '), 1, 3) degree
     , last_analyzed
  from dba_indexes ui
     , dba_ind_columns uic
 where ui.table_name = :tab_name
   and ui.owner = :owner
   and ui.index_name = uic.index_name
   and ui.table_name = uic.table_name
 order by index_name, column_position;

ttitle off
repheader on
