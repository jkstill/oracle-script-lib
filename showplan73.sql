
-- showplan73.sql
-- works with 7.3+

SET PAUSE OFF
SET VERIFY OFF
set trimspool on
set line 200 arraysize 1
clear break
clear compute

break on report
compute sum of cost on report

col operation format a50
col options format a12
col object_name format a30
col cost format 999999 heading 'COST'
col position format 999 heading 'POS'
col optimizer format a10
col cardinality format 99,999,999 head 'CARD'
col bytes format 99,999,999 head 'BYTES'
col total_rows format a10 head '      ROWS'


SELECT
	position,
	lpad('  ',2*(level-1))||operation || ' ' || options operation,
	object_name,
	cost,
	lpad(decode(cardinality,null,'  ',
		decode( sign(cardinality-1000), 
			-1, cardinality||' ',
			decode(sign(cardinality-1000000), 
				-1, trunc(cardinality/1000)||'K',
				decode( sign(cardinality-1000000000), 
					-1, trunc(cardinality/1000000)||'M',
					trunc(cardinality/1000000000)||'G'
				)
			)
		)
	), 10, ' ' ) total_rows,
	bytes,
	optimizer
FROM plan_table
START WITH id = 0 and statement_id = '&1'
CONNECT BY PRIOR id = parent_id AND statement_id = '&1'
ORDER BY id, position
/


UNDEF StatementID

