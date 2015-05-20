
-- px.sql
-- query global px_process table to see all 
-- parallel processes across a cluster
-- works for single node database as well

clear break

col username for a12
col "QC SID" for A6
col "SID" for A6
col "QC/Slave" for A8
col "Req. DOP" for 9999
col "Actual DOP" for 9999
col "Slaveset" for A8
col "Slave INST" for A9
col "QC INST" for A6
col "SERIAL#" format a8
set pages 300 lines 300
col wait_event format a30

select
decode(
	px.qcinst_id,NULL,username,
	' - '||lower(substr(pp.SERVER_NAME, length(pp.SERVER_NAME)-4,4) ) 
) "Username",
decode(
	px.qcinst_id,NULL, 'QC', '(Slave)'
) "QC/Slave" ,
to_char( px.server_set) "SlaveSet",
to_char(s.sid) "SID",
to_char(s.serial#) "SERIAL#",
to_char(px.inst_id) "Slave INST",
decode(sw.state,'WAITING', 'WAIT', 'NOT WAIT' ) as STATE,
case  sw.state 
	WHEN 'WAITING' 
	THEN substr(sw.event,1,30) 
	ELSE NULL 
end as wait_event ,
decode(px.qcinst_id, NULL ,to_char(s.sid) ,px.qcsid) "QC SID",
to_char(px.qcinst_id) "QC INST",
px.req_degree "Req. DOP",
px.degree "Actual DOP"
from gv$px_session px,
	gv$session s ,
	gv$px_process pp,
	gv$session_wait sw
where px.sid=s.sid (+)
	and px.serial#=s.serial#(+)
	and px.inst_id = s.inst_id(+)
	and px.sid = pp.sid (+)
	and px.serial#=pp.serial#(+)
	and sw.sid = s.sid
	and sw.inst_id = s.inst_id
order by
	decode(px.QCINST_ID,  NULL, px.INST_ID,  px.QCINST_ID),
	px.QCSID,
	decode(px.SERVER_GROUP, NULL, 0, px.SERVER_GROUP),
	px.SERVER_SET,
	px.INST_ID
/

