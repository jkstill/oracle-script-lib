
-- from Tim Sawmiller

column "RBS NAME" format a12
column username format a12

SELECT r.name "RBS NAME",
        l.sid "ORACLE PID", p.spid "SYS PID",
        NVL ( s.username, 'NO TRANSACTION' ) USERNAME,
        NVL ( s.osuser, '----' ) "LOGIN ID",
        s.terminal TERMINAL
 FROM v$lock l, v$process p, v$session s, v$rollname r
  WHERE l.sid = s.sid(+) AND TRUNC (l.id1(+)/65536) = r.usn
    AND l.type(+) = 'TX' AND l.lmode(+) = 6 AND s.paddr = p.addr
    ORDER BY r.name
/

