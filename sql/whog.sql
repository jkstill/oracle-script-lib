

-- whog.sql
-- jared still
-- jkstill@gmail.com
-- show user sessions for all instances
-- included PDB/CDB/ROOT for 12c

@clears

@oversion_major

define v_10gopts = ''
var v_10gopts varchar2(10)

define v_12copts = ''
var v_12copts varchar2(10)

declare
	i_oversion integer := '&&v_oversion_major';
begin
	if i_oversion <10 then
		:v_10gopts := '--';
	else
		:v_10gopts := '';
	end if;

	if i_oversion <12 then
		:v_12copts := '--';
	else
		:v_12copts := '';
	end if;

end;
/

-- enable or disable SQL_ID and other 10g+ stuff
set  term off feed off
col v_10gopts noprint new_value v_10gopts
col v_12copts noprint new_value v_12copts
select :v_10gopts v_10gopts from dual;
select :v_12copts v_12copts from dual;
set term on feed on


col username heading 'USERNAME' format a10
col inst_id head 'INST' format 9999
col pdb head 'PDB' format a10
col sid heading 'SID' format 99999
col machine format a25 head 'MACHINE'
col osuser format a10

set recsep off term on pause off verify off echo off
set line 220
set pagesize 100
set trimspool on

clear break
break on username skip 1


with pdbs as (
	&&v_12copts select inst_id, con_id, name
	&&v_12copts from gv$pdbs
	&&v_12copts union all
	select rownum inst_id, 0 con_id, 'CDB' name
	from gv$instance
	union all
	select rownum inst_id, 1 con_id, 'ROOT' name
	from gv$instance
)
select distinct
	s.username,
	s.inst_id,
	&&v_12copts pdb.name pdb,
	s.machine,
	s.osuser,
	count(s.username) over 
	(
		partition by 
		s.username
		, s.inst_id
		&&v_12copts, pdb.name 
		, s.machine
		, s.osuser
	) user_count
from gv$session s
-- use outer join to show sniped sessions in
-- v$session that don't have an OS process
-- uncomment to see only your own session
left outer join gv$process p on s.inst_id = p.inst_id
	and p.addr = s.paddr
&&v_12copts join pdbs  pdb
	&&v_12copts on pdb.inst_id = s.inst_id
	&&v_12copts and pdb.con_id = s.con_id
where s.username is not null
	--and userenv('SESSIONID') = s.audsid
order by username--, sid
/

set recsep wrapped

