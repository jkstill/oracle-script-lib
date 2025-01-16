
-- parms-version-diff.sql
-- Jared Still 2023
-- generate version named csv file of all parameters, including 'hidden' or '_underscore' parameters
-- compare two versions of parameters
-- requires SYSDBA

/*

diff <(cut -f1 -d, parms-19c.csv) <(cut -f1 -d, parms-23c.csv) | grep -- '^<'| cut -f2 -d' '> parms-only-19c.log

diff <(cut -f1 -d, parms-19c.csv) <(cut -f1 -d, parms-23c.csv) | grep -- '^>'| cut -f2 -d' '> parms-only-23c.log

$  wc -l parms-only*.log
  125 parms-only-19c.log
 1551 parms-only-23c.log
 1676 total

*/


set pause off echo off timing off verify off tab off feed off head off

clear col
clear break
clear computes

btitle ''
ttitle ''

btitle off
ttitle off

set newpage 1

set pagesize 0
set linesize 500 trimspool on

col u_version new_value u_version noprint

set term off
select version u_version from v$instance;

spool parms-&u_version..csv

prompt name,description,value,isdefault,isses_modifiable,issys_modifiable,ismodified,isadjusted

select
	a.KSPPINM --NAME
	||','|| a.KSPPDESC --DESCRIPTION
	||','|| b.KSPFTCTXVL --VALUE
	||','|| decode(b.KSPFTCTXDF,'TRUE','Y','N') --ISDEFAULT
	||','|| decode(bitand(ksppiflg/256,1),1,'Y' ,'N') --ISSES_MODIFIABLE
	||','|| decode(bitand(ksppiflg/65536,3),1,'I',2,'D', 3,'I','N') --ISSYS_MODIFIABLE
	||','|| decode(bitand(KSPFTCTXVF,7),1,'M',4,'S','N') --ISMODIFIED
	||','|| decode(bitand(KSPFTCTXVF,2),2,'Y','N') --ISADJUSTED
from X$KSPPI a, x$ksppcv2 b
--where a.indx = b.indx
where b.kspftctxpn = a.indx+1
order by 1
/

spool off

set feed on head on
set pagesize 100

