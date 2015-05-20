select OBJECT_NAME, SUBOBJECT_NAME, TABLESPACE_NAME, 
       OBJECT_TYPE, STATISTIC_NAME, VALUE
  from v$segment_statistics 
  where statistic_name = 'ITL waits'
  and value > 0
  order by value desc;
