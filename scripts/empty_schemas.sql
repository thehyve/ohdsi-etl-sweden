/* Empty the tables in reversed order of creation*/
SET client_min_messages TO WARNING; -- turns off cascading warnings

/* Delete and empty the non-omop schemas */
DROP TABLE IF EXISTS death_addendum CASCADE;
DROP SCHEMA IF EXISTS etl_input CASCADE;
DROP SCHEMA IF EXISTS etl_mappings CASCADE;

/* Delete the manually added vocabularies */
DELETE FROM vocabulary WHERE vocabulary_concept_id = 0;
TRUNCATE source_to_concept_map; 
