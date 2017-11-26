
-- asm-partners.sql
-- this must be run on an ASM instance
-- see:
-- How to Validate Normal or High Redundancy Diskgroups and ASM Disks Partnership (White Paper) (Doc ID 1961372.1)
-- http://afatkulin.blogspot.com/2012/07/displaying-asm-partner-disks.html

set echo off verify off 
set term on head on feed on

col u_group_num new_value u_group_num noprint

prompt
prompt Group Number:
prompt

set term off feed off
select '&1' u_group_num from dual;
set term on feed on

set linesize 200 trimspool on
set pagesize 100 

column p format a80
variable group_number number
exec :group_number := 1;

select d||' => '||listagg(p, ',') within group (order by p) p
from (
	select ad1.failgroup||'('||to_char(ad1.disk_number, 'fm000')||')' d,
	 ad2.failgroup||'('||listagg(to_char(p.number_kfdpartner, 'fm000'), ',') within group (order by ad1.disk_number)||')' p
	 from v$asm_disk ad1, x$kfdpartner p, v$asm_disk ad2
	 where ad1.disk_number = p.disk
	  and p.number_kfdpartner=ad2.disk_number
	  and ad1.group_number = p.grp
	  and ad2.group_number = p.grp
	  and p.grp = :group_number
	 group by ad1.failgroup, ad1.disk_number, ad2.failgroup
) group by d
order by d
/

