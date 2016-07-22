/* Drop all, except the tables for the standard vocabulary.
   Has to be rebuild again in next step. Without constraints
   Has two goals: empty the table and remove constraints*/
SET client_min_messages TO WARNING; -- turns off cascading warnings
DROP TABLE IF EXISTS care_site CASCADE;
DROP TABLE IF EXISTS cdm_source CASCADE;
DROP TABLE IF EXISTS cohort CASCADE;
DROP TABLE IF EXISTS cohort_attribute CASCADE;
DROP TABLE IF EXISTS condition_era CASCADE;
DROP TABLE IF EXISTS condition_occurrence CASCADE;
DROP TABLE IF EXISTS death CASCADE;
DROP TABLE IF EXISTS device_cost CASCADE;
DROP TABLE IF EXISTS device_exposure CASCADE;
DROP TABLE IF EXISTS dose_era CASCADE;
DROP TABLE IF EXISTS drug_cost CASCADE;
DROP TABLE IF EXISTS drug_era CASCADE;
DROP TABLE IF EXISTS drug_exposure CASCADE;
DROP TABLE IF EXISTS fact_relationship CASCADE;
DROP TABLE IF EXISTS location CASCADE;
DROP TABLE IF EXISTS measurement CASCADE;
DROP TABLE IF EXISTS note CASCADE;
DROP TABLE IF EXISTS observation CASCADE;
DROP TABLE IF EXISTS observation_period CASCADE;
DROP TABLE IF EXISTS payer_plan_period CASCADE;
DROP TABLE IF EXISTS person CASCADE;
DROP TABLE IF EXISTS procedure_cost CASCADE;
DROP TABLE IF EXISTS procedure_occurrence CASCADE;
DROP TABLE IF EXISTS provider CASCADE;
DROP TABLE IF EXISTS specimen CASCADE;
DROP TABLE IF EXISTS visit_cost CASCADE;
DROP TABLE IF EXISTS visit_occurrence CASCADE;
