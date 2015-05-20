

col v_oversion_minor new_value v_oversion_minor

select 
	substr(version,1,instr(version,'.',1,2)-1)  v_oversion_minor
from product_component_version
where product like 'Oracle%'
/

