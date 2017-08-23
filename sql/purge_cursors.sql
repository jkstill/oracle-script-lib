-- purge_cursors.sql
-- purge the cursors from the shared spool

col dsqlid new_value dsqlid noprint

prompt SQL_ID:  

set echo off term off feed off
select '&1' dsqlid from dual;
set term on feed on

var vsqlid varchar2(13)

exec :vsqlid := '&&dsqlid'

select invalidations, executions, child_number
from v$sql
where sql_id = :vsqlid;


set serveroutput on size unlimited

declare
        v_cursor_locator varchar2(60);
        c_count integer;
begin

        for sqlrec in (
                select address, hash_value, sql_id
                from v$sqlarea
                where sql_id = :vsqlid
        )
        loop
                v_cursor_locator := sqlrec.address || ',' || sqlrec.hash_value;
					 dbms_output.put_line('Purging SQL_ID ' || :vsqlid || ' Cursor: ' || v_cursor_locator );
                -- use address and hash_value to purge
                -- eg. dbms_shared_pool.purge ('0000000382E80750,1052545619','C');
                sys.dbms_shared_pool.purge(v_cursor_locator,'C');
        end loop;

        for sqlrec in (
                select column_value sql_id
                from (
                        table( sys.odcivarchar2list(:vsqlid))
                )
        )
        loop

                select count(*) into c_count
                from v$sqlarea
                where sql_id = sqlrec.sql_id;

                dbms_output.put_line(sqlrec.sql_id || ': ' || to_char(c_count));
        end loop;

end;
/

undef 1

set serveroutput off

select invalidations, executions, child_number
from v$sql
where sql_id = :vsqlid;


