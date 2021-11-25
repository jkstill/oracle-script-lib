
col username format a15
col logon_time format a30

select
   sess.username, sess.sid, sess.serial#,
   name.name name,
   stat.value value,
   to_char(sess.logon_time, 'yyyy-mm-dd_hh24-mi-ss') logon_time
from gv$sesstat stat, v$statname name, gv$session sess
where
   stat.sid = sess.sid
   and sess.username is not null
   and stat.statistic# = name.statistic#
	and sess.inst_id = stat.inst_id
   and name in (
      'SQL*Net roundtrips to/from client'
      ,'SQL*Net roundtrips to/from dblink'
      ,'bytes received via SQL*Net from client'
      ,'bytes received via SQL*Net from dblink'
      ,'bytes sent via SQL*Net to client'
      ,'bytes sent via SQL*Net to dblink'
   )
--and sess.sid = 34 --and sess.serial# = 18799
order by sess.username, name.name
/
