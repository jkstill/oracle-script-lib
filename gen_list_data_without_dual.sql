
-- gen_list_data_without_dual.sql
-- Jared Still - 08/04/2010
-- jkstill at gmail.com

-- use the sys.odci*list data types
-- requires 10g+

col varchar2_data format a30
col number_data format 99999
col date_data format a22

select rownum id, column_value varchar2_data 
from (
	table(
		sys.odcivarchar2list('one','two','three','four','five','six','seven','eight','nine')
	)
)
/


select rownum id, column_value number_data 
from (
	table(
		sys.odcinumberlist(100,200,300,400,500,600,700,800,900)
	)
)
/



select rownum id, column_value date_data 
from (
	table(
		sys.odcidatelist(
			sysdate ,
			sysdate -1,
			sysdate -2,
			sysdate -3,
			sysdate -4,
			sysdate -5,
			sysdate -6,
			sysdate -7,
			sysdate -8
		)
	)
)
/




