

-- blocker-tree.sql
-- Jared Still  jkstill@gmail.com
-- show tree of blocked sessions and blockers
-- 

/*

Examples:

@blocker-tree

SID                  USERNAME                       PROGRAM                                                 LEVEL
-------------------- ------------------------------ -------------------------------------------------- ----------
  15                 LGWR                           oracle@rac19c01.jks.com (LGWR)                              1
    68               JKSTILL                        perl@poirot.jks.com (TNS V1-V3)                             2
    293              JKSTILL                        perl@poirot.jks.com (TNS V1-V3)                             2
    309              JKSTILL                        perl@poirot.jks.com (TNS V1-V3)                             2
  49                 JKSTILL                        perl@poirot.jks.com (TNS V1-V3)                             1
    71               JKSTILL                        perl@poirot.jks.com (TNS V1-V3)                             2

6 rows selected.


@blocker-tree

SID                  USERNAME                       PROGRAM
-------------------- ------------------------------ --------------------------------------------------
  15                 LGWR                           oracle@rac19c01.jks.com (LGWR)
    56               JKSTILL                        perl@poirot.jks.com (TNS V1-V3)
    62               JKSTILL                        perl@poirot.jks.com (TNS V1-V3)
    73               JKSTILL                        perl@poirot.jks.com (TNS V1-V3)
    324              JKSTILL                        perl@poirot.jks.com (TNS V1-V3)
  253                CKPT                           oracle@rac19c01.jks.com (CKPT)
    254              SMON                           oracle@rac19c01.jks.com (SMON)
      58             JKSTILL                        perl@poirot.jks.com (TNS V1-V3)


*/


set linesize 150 trimspool on
set pagesize 100

col sid format a20
col username format a30
col program format a50

with blockers as (
	select distinct
		s.sid, null blocking_sid, nvl(s.username,b.name) username, s.program
	from v$session s
		join v$process p on  p.addr = s.paddr
		left outer join v$bgprocess b on b.paddr = s.paddr
	where s.sid in (select blocking_session from v$session)
	and blocking_session is null
),
blocked as (
	select s.sid, s.blocking_session blocking_sid, nvl(s.username,b.name) username, s.program
	from v$session s
		join v$process p on  p.addr = s.paddr
		left outer join v$bgprocess b on b.paddr = s.paddr
	where blocking_session is not null
),
all_data as (
	select sid, blocking_sid, username, program
	from blockers
	union all
	select sid, blocking_sid, username, program
	from blocked
)
select
	lpad(' ',(level)*2,' ') || sid sid
	, username
	, program
	--, level
from  all_data
connect by blocking_sid = prior sid
start with blocking_sid is null
/


