
-- defaults-demo.sql
-- jared still
-- 2024-10-25

-- technique to use defaults for susbstitution variables found at: https://vbegun.blogspot.com/2008/04/on-sqlplus-defines.html
/*
@ defaults-demo test_1 test_2

PARM1              PARM2
------------------ ------------------
test_1             test_2

1 row selected.

@ defaults-demo test_1

PARM1              PARM2
------------------ ---------------------------------------------
test_1             def_parm2_value

1 row selected.

@ defaults-demo

PARM1                                         PARM2
--------------------------------------------- ---------------------------------------------
def_parm1_value                               def_parm2_value

1 row selected.
*/

@@defaults

col parm1 new_value parm1
col parm2 new_value parm2

set term off verify off feedback off
select '&1' parm1, '&2' parm2 from dual;
set term on feedback on

def def_parm1='def_parm1_value'
def def_parm2='def_parm2_value'

select nvl('&parm1','&def_parm1') parm1, nvl('&parm2','&def_parm2') parm2 from dual;

undef 1 2

