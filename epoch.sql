select 
	(
		extract(day from(systimestamp - to_timestamp('1970-01-01', 'YYYY-MM-DD'))) * 86400000
		+ to_number(to_char(sys_extract_utc(systimestamp), 'SSSSSFF3'))
	) epoch
from dual
/
