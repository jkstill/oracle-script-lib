-- showsort.sql 
--
-- 
--
-- Author: Jared Still - , jkstill@gmail.com
--
-- Changelog: 
--
-- 2017-04-17 17:09:01 - Jared Still   - script added to repo
--

col mem_disk_sort_ratio format 999.99

select
	d.inst_id,
	m.mem_sorts,
	d.disk_sorts,
	trim(to_char( m.mem_sorts / decode(d.disk_sorts,0,1,&d) , '999,999,990')) || ':' ||
		trim(to_char( m.mem_sorts / decode(d.disk_sorts,0,1,d.disk_sorts) / decode(d.disk_sorts,0,m.mem_sorts,d.disk_sorts), '999,999,990.0' )) ratio
from (
	select inst_id, value disk_sorts
	from gv$sysstat
	where name like '%sort%disk%'
) d,
(
	select inst_id, value mem_sorts
	from gv$sysstat
	where name like '%sort%mem%'
) m
where m.inst_id = d.inst_id
order by 1
/

