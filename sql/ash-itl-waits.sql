
-- ash-itl-waits.sql
-- show historic blocking , sql_id and whether mode 4 (ITL) or mode 6 (rowlock)
-- Jared Still
-- 
-- jkstill@gmail.com

/*

As seen in an AWR report for 'Top Event P1/P2/P3 Values'

Event	                     % Event P1, P2, P3 Values	               % Activity  Parameter 1 Parameter 2   Parameter 3
enq: TX - index contention	22.52	  "1415053316","19529734","1548062"	1.65 	      name|mode   usn<<16|slot   sequence

P1 of 1415053316 is a mode 4 ITL wait
P1 of 1415053318 is a mode 6 ITL wait

This can be seen from the binary representation of these values

Mode 4
1415053316
0x54580004
1010100010110000000000000000100

$  perl -e 'print 1415053316 & 0xFFFF, "\n"'
4

Mode 6
1415053318
0x54580006
1010100010110000000000000000110

$  perl -e 'print 1415053318 & 0xFFFF, "\n"'
6

*/


@clears

--@get_date_range

col owner format a15
col object format a30
col object_type format a10
col index_name format a30
col table_name format a30
col lockmode format a20
col event_name format a40 head 'EVENT NAME'
col sql_id format a13
col instance_number format 9999 head 'INST'

set line 200 trimspool on
set pagesize 60


-- d_date_format set by get_date_range.sql

with waits as (
   select
      sh.inst_id instance_number
      , sh.blocking_inst_id
      , sh.sql_id
      , n.name event_name
		, chr(bitand(sh.p1,-16777216)/16777215)||
		       chr(bitand(sh.p1, 16711680)/65535) LOCKNAME
      , bitand(sh.p1,65535) lockmode
		, sh.current_obj#
   from gv$active_session_history sh
   join v$event_name n on sh.event_id = n.event_id
   where sh.blocking_inst_id is not null
   --and sh.event_id = ( select event_id from v$event_name where name like 'enq: TX - row lock contention')
   and sh.event_id in ( select event_id from v$event_name where name like 'enq:%')
	and sh.current_obj# is not null
	and sh.current_obj# > 0
),
itlwaits as (
	select distinct
   	w.instance_number
   	, w.event_name
   	, w.sql_id
		--, w.lockname
		, current_obj#
		, count(*) itl_wait_count
	from waits w
	where w.lockname = 'TX'
		and lockmode = 4 -- ITL
		-- in this case just interested in indexes
		--and w.event_name = 'enq: TX - index contention'
	group by w.instance_number, w.event_name, w.sql_id, current_obj#
)
select 
	w.instance_number
	, w.sql_id
	, w.itl_wait_count
	, decode(i.owner,null,t.owner,i.owner) owner
	, o.object_type
	, decode(i.index_name,null,t.table_name,i.index_name) object
	, decode(i.ini_trans,null,t.ini_trans,i.ini_trans) ini_trans
	, decode(i.max_trans,null,t.max_trans,i.max_trans) max_trans
from itlwaits w
join dba_objects o on o.object_id  = w.current_obj#
left outer join dba_indexes i on i.owner = o.owner
	and i.index_name = o.object_name
left outer join dba_tables t on t.owner = o.owner
	and t.table_name = o.object_name
order by w.itl_wait_count
/

