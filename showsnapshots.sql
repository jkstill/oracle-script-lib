
@clears

col owner format a15 head 'SNAPSHOT|OWNER' 
col rname format a12 head 'REFRESH|GROUP'
col refresh_mode format a8 head 'REFRESH|MODE'
col name format a30 head 'SNAPSHOT'
col last_refresh format a20 head 'LAST REFRESH' 
col next_refresh format a20 head 'NEXT REFRESH' 

break on owner skip on refresh_mode on rname 

set line 110

select
	s.owner owner
	,s.refresh_mode 
	--, decode(r.rname, null, '-NO REFRESH-',rname, decode(s.refresh_mode,'COMMIT','NA'), 'UNKNOWN') 
	-- , decode(r.rname, null,decode(s.refresh_mode,'COMMIT','NA','-NO REFRESH-'), r.rname) rname
	, case 
		when r.rname is null and s.refresh_mode = 'COMMIT' then 'NA'
		when r.rname is not null then r.rname
		else 'UNKNOWN'
	end rname
	,s.name name
	,to_char(s.last_refresh,'mm/dd/yyyy hh24:mi:ss' ) last_refresh
	,decode( r.next_date,
		null, s.next,
		to_char(r.next_date,'mm/dd/yyyy hh24:mi:ss')
	) next_refresh
from all_snapshots s, all_refresh r
where s.refresh_group = r.refgroup(+)
order by owner, refresh_mode, rname, name
/

