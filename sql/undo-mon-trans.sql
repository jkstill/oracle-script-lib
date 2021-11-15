
-- undo-mon-trans.sql
-- Jared Still
-- 2018   jkstill@gmail.com

-- monitor rollback for transactions
-- see undo-mon-fast.sql to monitor rollback for killed sessions

select to_char(systimestamp,'hh24:mi:ssxff') currtime
	, xidusn, xidslot, used_ublk, used_urec
from v$transaction
/

