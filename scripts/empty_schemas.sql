/* Empty the tables in reversed order of creation*/
SET client_min_messages TO WARNING; -- turns off cascading warnings
TRUNCATE TABLE cdm5.drug_exposure CASCADE;
TRUNCATE TABLE cdm5.condition_occurrence CASCADE;
TRUNCATE TABLE cdm5.visit_occurrence CASCADE;
TRUNCATE TABLE cdm5.observation_period CASCADE;
TRUNCATE TABLE cdm5.death CASCADE;
TRUNCATE TABLE cdm5.person CASCADE;
TRUNCATE TABLE cdm5.care_site CASCADE;
TRUNCATE TABLE cdm5.location CASCADE;

/* Delete and empty the schemas */
DROP TABLE IF EXISTS cdm5.death_addendum CASCADE;
DROP SCHEMA IF EXISTS bayer CASCADE;
DROP SCHEMA IF EXISTS mappings CASCADE;

-- Function to truncate whole schema
-- DO
-- $func$
-- BEGIN
--    RAISE NOTICE '%',
--    -- EXECUTE
--   (SELECT 'TRUNCATE TABLE '
--        || string_agg(quote_ident(schemaname) || '.' || quote_ident(tablename), ', ')
--        || ' CASCADE'
--    FROM   pg_tables
--    WHERE  schemaname = 'public'
--    -- AND tableowner = 'postgres' -- optionaly restrict to one user
--    );
-- END
-- $func$;

/* OR create a shadow database from template*/
-- DROP DATABASE mydb;
-- CREATE DATABASE mydb TEMPLATE my_template;
