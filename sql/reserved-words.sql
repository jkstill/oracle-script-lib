select keyword,
	res_type || res_attr || res_semi || duplicate attributes
from v$reserved_words
where reserved = 'Y'
order by 2,1
/
