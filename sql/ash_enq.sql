select
       substr(event,0,20)                  lock_name,
       ash.session_id                      waiter,
       mod(ash.p1,16)                     lmode,
       ash.p2                                   p2,
       ash.p3                                   p3,
       o.object_name                      object,
       o.object_type                        otype,
       CURRENT_FILE#                filen,
       CURRENT_BLOCK#           blockn,
       ash.SQL_ID                          waiting_sql,
       BLOCKING_SESSION         blocker
       --,ash.xid
from
         v$active_session_history ash,
         all_objects o
where
           event like 'enq: %'
   and o.object_id (+)= ash.CURRENT_OBJ#
/

