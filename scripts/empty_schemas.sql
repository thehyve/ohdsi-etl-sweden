/* Empty the tables in reversed order of creation*/
SET client_min_messages TO WARNING; -- turns off cascading warnings

/* Delete and empty the non-omop schemas */
DROP TABLE IF EXISTS death_addendum CASCADE;
DROP SCHEMA IF EXISTS bayer CASCADE;
DROP SCHEMA IF EXISTS mappings CASCADE;

/* OR create a shadow database from template*/
-- DROP DATABASE mydb;
-- CREATE DATABASE mydb TEMPLATE my_template;
