

col v_oversion_major new_value v_oversion_major

select 
	substr(version,1,instr(version,'.',1,1)-1) v_oversion_major
from product_component_version
where product like 'Oracle%'
/
