
@@columns

col description format a50
col name format a40
set linesize 200 trimspool on
set pagesize 100

select
	--a.INDX NUM
	a.KSPPINM NAME
	--a.KSPPITY TYPE
	, a.KSPPDESC DESCRIPTION
	, b.KSPFTCTXVL VALUE
	, decode(b.KSPFTCTXDF,'TRUE','Y','N') ISDEFAULT
	, decode(bitand(ksppiflg/256,1),1,'Y' ,'N') ISSES_MODIFIABLE
	, decode(bitand(ksppiflg/65536,3),1,'I',2,'D', 3,'I','N') ISSYS_MODIFIABLE
	-- M = MODIFIED S = SYSTEM_MOD
	, decode(bitand(KSPFTCTXVF,7),1,'M',4,'S','N') ISMODIFIED
	, decode(bitand(KSPFTCTXVF,2),2,'Y','N') ISADJUSTED
from X$KSPPI a, x$ksppcv2 b
--where a.indx = b.indx
where b.kspftctxpn = a.indx+1
	and decode(bitand(ksppiflg/256,1),1,'Y' ,'N') = 'Y'
	and (
		b.KSPFTCTXVL in ('TRUE','FALSE')
		or regexp_like(b.KSPFTCTXVL,'^[[:digit:]]+$')
	)
order by name
/
