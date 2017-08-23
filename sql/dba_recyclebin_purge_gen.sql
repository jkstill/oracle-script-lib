

-- dba_recyclebin_purge_gen.sql
-- genearate SQL that can be used to remove objects from the dba_recyclebin
-- ojbects that appear only once in the dba_recyclebin will be ignored
-- objects that appear 1+ times will leave the most recently dropped object
-- in the dba_recyclebin
--
-- to see only must recent inluding single objects
-- remove the 'having count' and change the 'not in' to in
--
-- apparently this will not work as sysdba
-- generating SQL works, but you cannot execute the 
-- generated SQL as sysdba - must login as owner

set line 200 trimspool on
set head off pagesize 0 feed on

with multbin as (
	select owner, original_name, type
	from dba_recyclebin
	group by owner, original_name, type
	having count(*) > 1
	order by 1,2
),
-- get all objects in recylebin that have 1+ copies
purgeobjects as (
	select rb.owner, rb.original_name, rb.object_name, rb.type, rb.droptime
	from dba_recyclebin rb
	join multbin mb on mb.owner = rb.owner and mb.original_name = rb.original_name
	-- do not include the most recent object
	where (rb.owner,rb.original_name,rb.droptime) not in (
		select rb.owner, rb.original_name, max(rb.droptime)
		from dba_recyclebin rb
		join multbin mb on mb.owner = rb.owner and mb.original_name = rb.original_name
		group by rb.owner, rb.original_name
	)
)
select 'purge ' || type || ' ' || owner || '."' || object_name || '";'
from purgeobjects
/

set head on pagesize 60


