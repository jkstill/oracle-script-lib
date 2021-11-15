
-- undo-mon-fast.sql
-- Jared Still
-- 2018   jkstill@gmail.com
--
-- monitor from v$fast_start_transactions
-- this is useful for when a proccess/session has been killed
-- and v$transaction cannot be used to monitor rollback
-- ( see undo-mon-trans.sql)
-- See this MOS note for more
-- Parallel Rollback may hang database, Parallel query servers get 100% cpu (Doc ID 144332.1)
--

select to_char(systimestamp,'hh24:mi:ssxff') currtime
	, usn
	, slt
	, seq
	, state
	, pid
	, undoblocksdone
	, undoblockstotal
	, to_char( ( undoblocksdone / undoblockstotal ) * 100,'990.9')||'%' pctdone
from v$fast_start_transactions
/

