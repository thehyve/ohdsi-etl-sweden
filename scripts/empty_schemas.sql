/* Empty the tables in reversed order of creation*/
SET client_min_messages TO WARNING; -- turns off cascading warnings

/* Delete and empty the non-omop schemas */
DROP TABLE IF EXISTS death_addendum CASCADE;
DROP SCHEMA IF EXISTS etl_input CASCADE;
DROP SCHEMA IF EXISTS etl_mappings CASCADE;
