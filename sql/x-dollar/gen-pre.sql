select rownum id, column_value varchar2_data 
from (
	table(
		sys.odcivarchar2list(
