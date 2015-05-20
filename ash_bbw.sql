
set linesize 120

/*
 when block type is not found in v$waitclass then it's undo/rbs segement 

OBJN                      OTYPE FILEN BLOCKN SQL_ID        BLOCK_TYPE
------------------------- ----------- ------ ------------- ------------------
53218 BBW_INDEX_VAL_I     INDEX     1  64826 97dgthz60u28d data block 1
53218 BBW_INDEX_VAL_I     INDEX     1  64826 gypmcfzruu249 data block 1
53218 BBW_INDEX_VAL_I     INDEX     1  64826 2vd1w5kgnfa5n data block 1
53218 BBW_INDEX_VAL_I     INDEX     1  64826 3p3qncvp2juxs data block 1
53218 BBW_INDEX_VAL_I     INDEX     1  64826 6avm49ys4k7t6 data block 1
53218 BBW_INDEX_VAL_I     INDEX     1  64826 1hsb81ypyrfs5 data block 1
53218 BBW_INDEX_VAL_I     INDEX     1  64652 2vd1w5kgnfa5n data block 1
53218 BBW_INDEX_VAL_I     INDEX     1  64826 3p3qncvp2juxs data block 1
53218 BBW_INDEX_VAL_I     INDEX     1  64923 5wqps1quuxqr4 data block 1
53218 BBW_INDEX_VAL_I     INDEX     1  64826 6avm49ys4k7t6 data block 1
-1                                  0      0 fm7zcsnd5fud6  39
-1                                  0      0 3qrw5v6d6qj4a  39
53218 BBW_INDEX_VAL_I     INDEX     1  64825 2vd1w5kgnfa5n segment header 4
53218 BBW_INDEX_VAL_I     INDEX     1  64826 gypmcfzruu249 data block 1
53218 BBW_INDEX_VAL_I     INDEX     1  64826 5x0fksgfwkn6s data block 1
53218 BBW_INDEX_VAL_I     INDEX     1  64826 2vd1w5kgnfa5n data block 1

*/


col block_type for a18
col objn for a25
col otype for a15
select
       --ash.p1,
       --ash.p2,
       --ash.p3,
       CURRENT_OBJ#||' '||o.object_name objn,
       o.object_type otype,
       CURRENT_FILE# filen,
       CURRENT_BLOCK# blockn,
       ash.SQL_ID,
       w.class ||' '||to_char(ash.p3) block_type
from v$active_session_history ash,
     ( select rownum class#, class from v$waitstat ) w,
      all_objects o
where event='buffer busy waits'
   and w.class#(+)=ash.p3
   and o.object_id (+)= ash.CURRENT_OBJ#
   --and w.class# > 18
Order by sample_time
/

