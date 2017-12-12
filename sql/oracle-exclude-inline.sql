-- oracle-exclude-inline.sql
-- show oracle owned schemas in 11g+
-- designed for inclusion in other queries
-- THERE MUST BE NO BLANK LINES
-- Pythian 2017
-- Jared Still still@pythian.com jkstill@gmail.com
-- see oracle-exclude-demo.sql for example usage
excluded_schemas as (
	select name schema_to_exclude
	from system.LOGSTDBY$SKIP_SUPPORT
	where action = 0
)
