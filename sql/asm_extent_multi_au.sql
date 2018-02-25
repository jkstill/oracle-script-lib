
-- asm_extent_multi_au
-- show asm file extents that have AU count > 1
-- run as SYSASM

col dg_num format 9999 head 'DG#'
col disk_num format 99999 head 'DISK#'
col asmfile_num format 99999 head 'ASM|FILE#'

set linesize 100

select
        GROUP_KFDAT DG_NUM
        , NUMBER_KFDAT DISK_NUM
        , FNUM_KFDAT asmfile_num
        , XNUM_KFDAT asmfile_ext_num
        , count(AUNUM_KFDAT) asm_au_count
        --, AUNUM_KFDAT asm_au_num
from X$KFDAT au
group by GROUP_KFDAT
        , NUMBER_KFDAT
        , FNUM_KFDAT
        , XNUM_KFDAT
having count(*) > 1
order by 1,2,3
/


