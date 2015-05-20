

/*

   only 10.2.0.3 and above

COUNT(*) SQL_ID        calling_code
--------- ------------- --------------------------------------------------------------------
        2 1xxksrhwtz3zf ORDERENTRY.NEWORDER  => DBMS_RANDOM.VALUE
        2 07p193phmhx3z ORDERENTRY.BROWSEPRODUCTS  => DBMS_APPLICATION_INFO.SET_ACTION
        2 1xxksrhwtz3zf ORDERENTRY.NEWORDER  => DBMS_LOCK.SLEEP
        3 1xxksrhwtz3zf ORDERENTRY.NEWORDER  => DBMS_APPLICATION_INFO.SET_ACTION
       13 1xxksrhwtz3zf ORDERENTRY.NEWORDER
       16 0bzhqhhj9mpaa ORDERENTRY.NEWCUSTOMER
       45 41zu158rqf4kf ORDERENTRY.BROWSEANDUPDATEORDERS
       70 0yas01u2p9ch4 ORDERENTRY.NEWORDER
       76 dw2zgaapax1sg ORDERENTRY.NEWORDER
       82 05s4vdwsf5802 ORDERENTRY.BROWSEANDUPDATEORDERS
      111 75621g9y3xmvd ORDERENTRY.NEWORDER
      120 75621g9y3xmvd ORDERENTRY.BROWSEPRODUCTS
      131 75621g9y3xmvd ORDERENTRY.BROWSEANDUPDATEORDERS
      163 0uuqgjq7k12nf ORDERENTRY.NEWORDER

*/


set linesize 120
col entry_package for a25
col entry_procedure for a25
col cur_package for a25
col cur_procedure for a25
col calling_code for a70
select 
    count(*), 
    sql_id,
    procs1.object_name || decode(procs1.procedure_name,'','','.')||
    procs1.procedure_name ||' '||
    decode(procs2.object_name,procs1.object_name,'',
	 decode(procs2.object_name,'','',' => '||procs2.object_name)) 
    ||
    decode(procs2.procedure_name,procs1.procedure_name,'',
        decode(procs2.procedure_name,'','',null,'','.')||procs2.procedure_name)
    "calling_code"
from v$active_session_history  ash,
     all_procedures procs1,
     all_procedures procs2
 where
       ash.PLSQL_ENTRY_OBJECT_ID  = procs1.object_id (+)
   and ash.PLSQL_ENTRY_SUBPROGRAM_ID = procs1.SUBPROGRAM_ID (+)
   and ash.PLSQL_OBJECT_ID   = procs2.object_id (+)
   and ash.PLSQL_SUBPROGRAM_ID  = procs2.SUBPROGRAM_ID (+)
   and ash.sample_time > sysdate - &minutes/(60*24)
group by procs1.object_name, procs1.procedure_name, 
         procs2.object_name, procs2.procedure_name,sql_id
order by count(*)
/ 

