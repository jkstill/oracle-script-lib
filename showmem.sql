
@clears
set line 100

col sid format 9999
col name format a30
col value format 999,999,999,999

break on report
compute sum of value on report


SELECT
	v.sid,
	n.NAME,
	v.value
from
	v$statname n,
	v$sesstat v
where
	n.STATISTIC# = v.STATISTIC#
	and
	n.name in (
		'session uga memory',
		'session uga memory max',
		'session pga memory',
		'session pga memory max'
	)
order by v.sid, n.name
/
