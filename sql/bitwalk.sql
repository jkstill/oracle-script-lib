
-- bitwalk.sql
-- Jared Still 2021
-- jkstill@gmail.com still@pythian.com

/*

 Many SYS tables have data encoded into a 'flags' column that is actually a bitmap.

 this script can be used to determine which bits are set

 bit twiddling
 bitmap

*/

with data as (
	select flags
	from container$
	where con_id# = 3
),
masked as (
select flags
	, level -1  bit
	, power(2,level -1) mask
	--, bitand(flags, (power(2,level -1))) masked_value
from data
connect by level <= 38
order by level
)
select
	bit
	, mask
	, decode( bitand(flags, mask), 0, 'NOT SET', '    SET'  )  bitset
from masked
/

