
col wait_class format a20
col wc_symbol format a1

with wc_symbols as
(
   select rownum id, column_value wc_symbol
   from (
      table(
         -- the alternative list with punctuation looks more interesting
         --sys.odcivarchar2list('M','P','L','C','R','G','D','N','O','Q','S','I','U')
           sys.odcivarchar2list('!','@','#','$','%','^','*','=','+','-',':','<','>')
      )
   )
) ,
-- currently known classes
classes as (
   select rownum id, column_value wait_class
   from (
      table (
         sys.odcivarchar2list(
            'Administrative'  -- 'M' or !
            ,'Application'    -- 'P' or @
            ,'Cluster'        -- 'L' or #
            ,'Commit'         -- 'C' or $
            ,'Concurrency'    -- 'R' or %
            ,'Configuration'  -- 'G' or ^
            ,'Idle'           -- 'D' or *
            ,'Network'        -- 'N' or =
            ,'Other'          -- 'O' or +
            ,'Queueing'       -- 'Q' or -
            ,'Scheduler'      -- 'S' or :
            ,'System I/O'     -- 'I' or <
            ,'User I/O'       -- 'U' or >
         )
      )
   )
)
select c.wait_class, s.wc_symbol
from wc_symbols s
join classes c on c.id = s.id
/
