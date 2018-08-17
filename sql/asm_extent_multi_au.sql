
-- asm_extent_multi_au
-- show asm file extents that have AU count > 1
-- run as SYSASM

col dg_num format 9999 head 'DG#'
col disk_num format 99999 head 'DISK#'
col asmfile_num format 9999999 head 'ASM|FILE#'

set linesize 100
set pagesize 100

spool asm_extent_multi_au.log

select
        au.GROUP_KFDAT DG_NUM
        , au.NUMBER_KFDAT DISK_NUM
        , au.FNUM_KFDAT asmfile_num
        , au.XNUM_KFDAT asmfile_ext_num
        , count(au.V_KFDAT) asm_au_count -- allocated AU
from X$KFDAT au
where au.V_KFDAT = 'V' -- allocated AU: see MOS ORA-15041 DURING REBALANCE OR ADD DISK WHEN PLENTY OF SPACE EXISTS (Doc ID 473271.1)
	-- no file# 0
	-- see http://asmsupportguy.blogspot.com/2012/01/asm-file-number-1.html
	and au.FNUM_KFDAT > 0
group by GROUP_KFDAT
        , NUMBER_KFDAT
        , FNUM_KFDAT
        , XNUM_KFDAT
having count(*) > 1
order by 1,2,3
/

spool off

