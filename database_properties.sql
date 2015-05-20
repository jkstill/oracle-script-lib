

COLUMN property_name FORMAT A30
COLUMN property_value FORMAT A30
COLUMN description FORMAT A50
SET LINESIZE 200
SET PAGESIZE 60

SELECT *
FROM   database_properties
ORDER BY property_name;


