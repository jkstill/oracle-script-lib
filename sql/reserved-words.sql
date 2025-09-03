
col keyword format a30

col res_type format a5 head 'Use|as|Type|Name?'
col res_attr format a5 head 'Use|as|Attr|Name?'
col res_semi format a6 head 'Use|as|Idntfr|Name?'
col duplicate format a7 head 'Keyword|Dup?'
col reserved format a9 head 'Reserved?'

select keyword
	, reserved
	, res_type
	, res_attr
	, res_semi
	, duplicate
from v$reserved_words
--where keyword like '%YOUR_WORD_HERE%'
order by 2,1
/
