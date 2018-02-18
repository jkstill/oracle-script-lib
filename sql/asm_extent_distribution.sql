
-- asm_extent_distribution.sql
-- need to add parameter inputs


col phys_extent format 999999
col virt_extent format 999999
col disk_num format 9999
col au_num format 999999

select PXN_KFFXP phys_extent,
	XNUM_KFFXP virt_extent,
	DISK_KFFXP disk_num,
	AU_KFFXP au_num
from X$KFFXP
where NUMBER_KFFXP=256 -- ASM file 256
AND GROUP_KFFXP=2      -- diskgroup number 2
order by 1
/

