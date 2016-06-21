
-- show all available init.ora parameters
-- version >= 7.3
-- must connect as sys
-- jkstill - 11/19/2008 - updated to use x$ksppcv2
-- this is what v$parameter2 is based on so that items
-- this multiple entries appear on multiple lines
-- eg. control_files and event

@clears 

col stat new_value statname noprint
set feed off term off
select '&&1' stat from dual;
set feed on term on
undef 1

set trimspool on
set pages 60
set linesize 200 trimspool on

@title 'Initialization Parms for Version >= 7.3.X' 160

col num format 999999999999999
col name format a60 head 'PARAMETER NAME'
col value format a30 head 'VALUE'
col description format a30 head 'DESCRIPTION'
column isses_modifiable head 'SESS|MOD?' format a4
column issys_modifiable head 'SYS|MOD?' format a4
column isdefault head 'DEF|VAL?' format a4
column ismodified head 'MODI|FIED?' format a5
column isadjusted head 'ADJU|STED?' format a5

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
and  a.KSPPINM like '%&&statname%' escape '\'
order by name
/


