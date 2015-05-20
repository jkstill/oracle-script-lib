

@@getstat 'sorts'

var disk_sorts number;
var mem_sorts number;

set feed off
begin
	select value into :disk_sorts from v$sysstat where name like '%sort%disk%';
	select value into :mem_sorts from v$sysstat where name like '%sort%mem%';
end;
/

set feed on

select ( :disk_sorts / :mem_sorts )  * 100 from dual;



