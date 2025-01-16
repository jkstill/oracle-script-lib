
-- bitwalk.sql
-- Jared Still 2021
-- jkstill@gmail.com 

/*

 Many SYS tables have data encoded into a 'flags' column that is actually a bitmap.

 this script can be used to determine which bits are set

 bit twiddling
 bitmap

*/

col bit format 999 head 'BIT'
col mask format 9999999999999999999 head 'MASK'
col hex_mask format a17 head 'HEX MASK'
col bitset format a7 head 'BITSET'


with data as (
	select flags
	--select 23299785858490872343 flags
	from container$
	where con_id# = 1
),
masked as (
select flags
	, level -1  bit
	, power(2,level -1) mask
	--, bitand(flags, (power(2,level -1))) masked_value
from data
connect by level <= 64
order by level
)
select
	bit
	, decode( bitand(flags, mask), 0, 'NOT SET', '    SET'  )  bitset
	, mask
	, to_char(mask,'0XXXXXXXXXXXXXXX') hex_mask
from masked
/


