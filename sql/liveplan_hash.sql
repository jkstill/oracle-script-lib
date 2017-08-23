
-- liveplan_hash.sql
-- show hash value and SQL for currently used
-- sql for a session
-- use hash values as input to liveplan.sql
-- this is for 9i and earlier
-- see liveplan_10g.sql


@clears
@columns

col machine format a10
col username format a15
col status format a10
col osuser format a15
col client_program format a20

set line 120
select
	s.username,
	s.sid,
	s.status,
	s.machine,
	s.osuser,
	substr(s.program,1,20) client_program
from v$session s, v$process p
where s.username is not null
	-- use outer join to show sniped sessions in
	-- v$session that don't have an OS process
	and p.addr(+) = s.paddr
order by username, sid
/

col csid noprint new_value usid
prompt Get SQL for which SID? : 
set term off feed off
select '&1' csid from dual;
set term on feed on


col sql_text format a64
set line 120

break on username skip 1 on hash_value skip 1

select /*+ ordered */
	s.username
	,st.hash_value
	,st.sql_text
from
	v$session s
	,v$open_cursor oc
	,v$sqltext st
where
	s.sid = &&usid
	and s.saddr = oc.saddr
	and st.address = oc.address and st.hash_value = oc.hash_value
order by  s.username, st.hash_value , st.piece
/

undef 1

