
COLUMN property_name FORMAT A30
COLUMN property_value FORMAT A30
COLUMN description FORMAT A50
SET LINESIZE 200

SELECT *
FROM   database_properties
WHERE  property_name like '%TABLESPACE';

