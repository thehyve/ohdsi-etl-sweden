/* Drop all, except the tables for the standard vocabulary.
   Has to be rebuild again in next step. Without constraints
   Has two goals: empty the table and remove constraints*/
SET client_min_messages TO WARNING; -- turns off cascading warnings
DROP TABLE cdm5.care_site CASCADE;
DROP TABLE cdm5.cdm_source CASCADE;
DROP TABLE cdm5.cohort CASCADE;
DROP TABLE cdm5.cohort_attribute CASCADE;
DROP TABLE cdm5.condition_era CASCADE;
DROP TABLE cdm5.condition_occurrence CASCADE;
DROP TABLE cdm5.death CASCADE;
DROP TABLE cdm5.device_cost CASCADE;
DROP TABLE cdm5.device_exposure CASCADE;
DROP TABLE cdm5.dose_era CASCADE;
DROP TABLE cdm5.drug_cost CASCADE;
DROP TABLE cdm5.drug_era CASCADE;
DROP TABLE cdm5.drug_exposure CASCADE;
DROP TABLE cdm5.fact_relationship CASCADE;
DROP TABLE cdm5.location CASCADE;
DROP TABLE cdm5.measurement CASCADE;
DROP TABLE cdm5.note CASCADE;
DROP TABLE cdm5.observation CASCADE;
DROP TABLE cdm5.observation_period CASCADE;
DROP TABLE cdm5.payer_plan_period CASCADE;
DROP TABLE cdm5.person CASCADE;
DROP TABLE cdm5.procedure_cost CASCADE;
DROP TABLE cdm5.procedure_occurrence CASCADE;
DROP TABLE cdm5.provider CASCADE;
DROP TABLE cdm5.specimen CASCADE;
DROP TABLE cdm5.visit_cost CASCADE;
DROP TABLE cdm5.visit_occurrence CASCADE;
