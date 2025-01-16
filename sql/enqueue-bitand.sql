
-- enqueue-bitand.sql
-- Jared Still  jkstill@gmail.com
-- 2016-11-03
--

/*

From the Oracle Support Document:

WAITEVENT: "enqueue" Reference Note (Doc ID 34566.1)

This note is commonly referenced decoding the type of enqueue waits as found in v$session

While the v$lock view does have this directly, that information is not available in AWR.

When querying dba_hist_active_sess_history it is still necessary to decode the actual enqueue name and mode from the view.

And so this Oracle Note is still relevant, if a bit puzzling.  

The note refers to the hexadecimal value of P1 for enqueues.

This is a rather old document, and the hexadecimal capabilities of the to_char() function were likely not available then.

Using string functions the type of enqueue and the mode can be extracted as shown in the SQL statement following this comment.

Where it seems really puzzling though is the use of a negative number with bitand.

The example code used:

SELECT chr(to_char(bitand(p1,-16777216))/16777215)
	|| chr(to_char(bitand(p1, 16711680))/65535) "Lock",
	to_char( bitand(p1, 65535) )    "Mode"
FROM v$session_wait
WHERE event = 'enqueue'

Each of the following values are bitmasks used with bitand in the example SQL

-16777216 = FFFFFFFFFF000000
 16777215 = FFFFFF
 16711680 = FF0000
    65535 = FFFF


Why use the negative number?

I can see where it may be useful where this particular bitmask is required, but that does not seem to be the case here.

In fact the values used in the example do not return integer values.

What is needed is to just mask the byte of each of the two characters in P1 that represent the lock name

See the examples following.

*/


-- this value translates to TX Mode 6
-- it is the number that will appear in v$session.p1
define p1 = 1415053318

prompt 
prompt using string manipulation
prompt enq: TX mode 6
prompt 

set echo on

-- this SQL is rather verbose for demonstration purposes
with hex as (
	select trim(to_char(&p1,'XXXXXXXXXXXXXXXX')) hexnum from dual
),
hexbreak as (
	select hexnum
		, to_number(substr(hexnum,1,2),'XXXXXXXX') enq_name_byte_1
		, to_number(substr(hexnum,3,2),'XXXXXXXX') enq_name_byte_2
		, to_number(substr(hexnum,5),'XXXXXXXX') enq_mode
from hex
)
select 
	hexnum
	, chr(enq_name_byte_1) 
	|| chr(enq_name_byte_2) enqueue_type
	, enq_mode
from hexbreak
/

set echo off


prompt
prompt The Oracle recommended bit twiddly method
prompt Note the values returned for enq_name_byte_1 and enq_name_byte_1 are not integers
prompt

with data as (
	select &p1 p1
		, bitand(&p1,-16777216)/16777215 enq_name_byte_1
		, bitand(&p1, 16711680)/65535 enq_name_byte_2
		, bitand(&p1, 65535) mode_byte
	from dual
)
select
	enq_name_byte_1
	, enq_name_byte_2
	, chr(enq_name_byte_1) || chr(enq_name_byte_2) enqueue_type
	, mode_byte
from data;


prompt
prompt Now use the bit-twiddly method with reasonable values
prompt The following Hex numbers are used to mask the two bytes needed for the characters of the enqueue name
prompt The returned results will be integer values
prompt
prompt 
prompt 0xFF000000 = 4278190080
prompt 0x00FF0000 =   16711680
prompt
prompt The value of 16711680 does not change from what is used in the document
prompt However the values of 16777215 and 65535 are both increased by 1 (off by 1 error)
prompt
prompt

set echo on

with data as (
	select &p1 p1
		, bitand(&p1,4278190080)/16777216 enq_name_byte_1
		, bitand(&p1, 16711680)/65536 enq_name_byte_2
		, bitand(&p1, 65535) mode_byte
	from dual
)
select
	enq_name_byte_1
	, enq_name_byte_2
	, chr(enq_name_byte_1) || chr(enq_name_byte_2) enqueue_type
	, mode_byte
from data;

set echo off

prompt
prompt Making the code perhaps a little more readable...
prompt

set echo on

with data as (
	select &p1 p1
		, bitand(&p1,4278190080)/power(2,24) enq_name_byte_1
		, bitand(&p1, 16711680)/power(2,16) enq_name_byte_2
		, bitand(&p1, power(2,16)-1) mode_byte
	from dual
)
select
	enq_name_byte_1
	, enq_name_byte_2
	, chr(enq_name_byte_1) || chr(enq_name_byte_2) enqueue_type
	, mode_byte
from data;

set echo off

