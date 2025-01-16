
/*

If the version is 11 or less, the substitution variable legacy_db will be set to '--'

Use this to preface sections that only work in 12c+

ie.

 <ampersand_here>legacy_db and i.con_id = c.con_id

*/

set term off feed off echo off tab off

col legacy_db new_value legacy_db noprint
select decode(substr(version,1,instr(version,'.')-1),9,'--',10,'--',11,'--','') legacy_db from v$instance;
set term on feed on

