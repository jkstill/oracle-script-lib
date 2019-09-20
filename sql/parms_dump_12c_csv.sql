
-- parms_dump_12c_csv.sql
-- dump all parameters to a CSV file
-- Jared Still


set pause off
set echo off
set timing off
set trimspool on
set feed on term on echo off verify off
set line 80
set pages 24 head on

clear col
clear break
clear computes

btitle ''
ttitle ''
btitle off
ttitle off

set newpage 1

set pages 0 lines 200 term on feed off 
set line 32767 trimspool on

col uinst_num new_value uinst_num noprint format a3
set feed off term off 
select to_char(instance_number) uinst_num from v$instance;
set term on

spool parameters_inst_&uinst_num..csv

prompt "INSTANCE","NAME","DESCRIPTION","VALUE","ISDEFAULT","ISSES_MODIFIABLE","ISSYS_MODIFIABLE","ISMODIFIED","ISADJUSTED"

select
	'"' || a.INST_ID
	|| '","' || a.KSPPINM
	|| '","' || a.KSPPDESC
	|| '","' || replace(b.KSPFTCTXVL,chr(10),' ')
	|| '","' || decode(b.KSPFTCTXDF,'TRUE','Y','N')
	|| '","' || decode(bitand(ksppiflg/256,1),1,'Y' ,'N')
	|| '","' || decode(bitand(ksppiflg/65536,3),1,'I',2,'D', 3,'I','N')
	|| '","' || decode(bitand(KSPFTCTXVF,7),1,'M',4,'S','N')
	|| '","' || decode(bitand(KSPFTCTXVF,2),2,'Y','N') || '"'
from X$KSPPI a, x$ksppcv2 b
--where a.indx = b.indx
where b.kspftctxpn = a.indx+1
order by 1
/

spool off

set line 200

set feed on term on

