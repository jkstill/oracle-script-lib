

/*

STATUS         SID NAME         PROGRAM                     CPU    WAITING    IO  TOTAL
------------ ----- ------------ ------------------------- ----- ---------- ----- ------
CONNECTED      165 SYS          ORACLE.EXE (CKPT)           232        173     0    405
DISCONNECTED   158 SYS          ORACLE.EXE (J003)            43          6   303    352
DISCONNECTED   141 SYS          ORACLE.EXE (J002)            13          3   333    349
CONNECTED      162 SYS          ORACLE.EXE (CJQ0)           149         14     2    165
CONNECTED      167 SYS          ORACLE.EXE (DBW0)            26        116     0    142
CONNECTED      166 SYS          ORACLE.EXE (LGWR)            46         94     0    140
CONNECTED      161 SYS          ORACLE.EXE (MMON)            34         13    16     63
CONNECTED      170 SYS          ORACLE.EXE (PMON)            59          0     0     59
DISCONNECTED   147 SYS          ORACLE.EXE (m000)             0         24    12     36


*/


col name for a12
col program for a25
col CPU for 9999
col IO for 9999
col TOTAL for 99999
col WAIT for 9999
col user_id for 99999
col sid for 9999

set linesize 120

select
        decode(nvl(to_char(s.sid),-1),-1,'DISCONNECTED','CONNECTED')
                                                        "STATUS",
        topsession.sid             "SID",
        u.username  "NAME",
        topsession.program                  "PROGRAM",
        max(topsession.CPU)              "CPU",
        max(topsession.WAIT)       "WAITING",
        max(topsession.IO)                  "IO",
        max(topsession.TOTAL)           "TOTAL"
        from (
select * from (
select
     ash.session_id sid,
     ash.session_serial# serial#,
     ash.user_id user_id,
     ash.program,
     sum(decode(ash.session_state,'ON CPU',1,0))     "CPU",
     sum(decode(ash.session_state,'WAITING',1,0))    -
     sum(decode(ash.session_state,'WAITING',
        decode(wait_class,'User I/O',1, 0 ), 0))    "WAIT" ,
     sum(decode(ash.session_state,'WAITING',
        decode(wait_class,'User I/O',1, 0 ), 0))    "IO" ,
     sum(decode(session_state,'ON CPU',1,1))     "TOTAL"
from v$active_session_history ash
group by session_id,user_id,session_serial#,program
order by sum(decode(session_state,'ON CPU',1,1)) desc
) where rownum < 10
   )    topsession,
        v$session s,
        all_users u
   where
        u.user_id =topsession.user_id and
        /* outer join to v$session because the session might be disconnected */
        topsession.sid         = s.sid         (+) and
        topsession.serial# = s.serial#   (+)
   group by  topsession.sid, topsession.serial#,
             topsession.user_id, topsession.program, s.username,
             s.sid,s.paddr,u.username
   order by max(topsession.TOTAL) desc
/

