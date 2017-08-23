-- shared_pool_advice.sql
-- see MetaLink Note 255409.1

col shared_pool_size_for_estimate format 999999 heading "Size of Shared Pool in MB"
col shared_pool_size_factor format 99.90 head "Size Factor"
col estd_lc_time_saved format 999,999,999 head "Time Saved in sec" 
col estd_lc_size format 99,999,999,999 head "Est libcache mem"
col estd_lc_memory_object_hits format 999,999,999,999 head 'libcache hits'

SELECT shared_pool_size_for_estimate 
   , shared_pool_size_factor 
   , estd_lc_size 
   , estd_lc_time_saved 
   , estd_lc_memory_object_hits
FROM v$shared_pool_advice
/


-- SHARED_POOL_SIZE_FOR_ESTIMATE Shared pool size for the estimate (in megabytes)
-- SHARED_POOL_SIZE_FACTOR       Size factor with respect to the current shared pool size
-- ESTD_LC_SIZE                  Estimated memory in use by the library cache (in megabytes)
-- ESTD_LC_MEMORY_OBJECTS        Estimated number of library cache memory objects in the shared pool of the specified size
-- ESTD_LC_TIME_SAVED            Estimated elapsed parse time saved (in seconds), owing to library cache memory objects being found in a shared pool of the specified size. This is the time that would have been spent in reloading the required objects in the shared pool had they been aged out due to insufficient amount of available free memory.
-- ESTD_LC_TIME_SAVED_FACTOR     Estimated parse time saved factor with respect to the current shared pool size
-- ESTD_LC_LOAD_TIME             Estimated elapsed time (in seconds) for parsing in a shared pool of the specified size
-- ESTD_LC_LOAD_TIME_FACTOR      Estimated load time factor with respect to the current shared pool size
-- ESTD_LC_MEMORY_OBJECT_HITS    Estimated number of times a library cache memory object was found in a shared pool of the specified size
