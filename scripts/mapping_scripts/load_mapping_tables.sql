/* Load and create the manual mapping tables */
-- DROP SCHEMA IF EXISTS mappings CASCADE;
CREATE SCHEMA etl_mappings;

CREATE TABLE etl_mappings.snomed (
    source_code	varchar(50) PRIMARY KEY,
    frequency integer,
    intermediate_concept_id integer,
    intermediate_code varchar(50),
    intermediate_name varchar(200),
    intermediate_vocabulary varchar(50),
    target_concept_id integer,
    target_code varchar(50),
    target_name varchar(200),
    target_vocabulary varchar(50),
    domain_id varchar(50)
)
;

CREATE TABLE etl_mappings.nomesco (
    source_code	varchar(50) PRIMARY KEY,
    source_name varchar(255),
    target_name varchar(255),
    target_concept_id integer
)
;

CREATE TABLE etl_mappings.dose_form (
    source_code	varchar(50) PRIMARY KEY,
    frequency integer,
    source_code_description varchar(200),
    target_concept_id integer,
    target_description varchar(100)
)
;

CREATE TABLE etl_mappings.unit (
    source_code	varchar(50) PRIMARY KEY,
    frequency integer,
    target_concept_id integer,
    target_description varchar(100)
)
;

CREATE TABLE etl_mappings.icd10_ekod (
    source_code varchar(50) PRIMARY KEY,
    frequency integer,
    target_concept_id integer,
    target_concept_code varchar(10),
    target_concept_name varchar(255)
)
;

-- Load the tables
-- \copy etl_mappings.icd10 FROM './mapping_tables/icd10.csv'   WITH HEADER CSV
\copy etl_mappings.snomed FROM './mapping_tables/ICD10_SNOMED.csv'   WITH HEADER CSV
\copy etl_mappings.nomesco FROM './mapping_tables/NOMESCO.csv'   WITH HEADER CSV
\copy etl_mappings.dose_form FROM './mapping_tables/dose_form.csv'   WITH HEADER CSV
\copy etl_mappings.unit FROM './mapping_tables/unit.csv'   WITH HEADER CSV
\copy etl_mappings.icd10_ekod FROM './mapping_tables/ekod_icd10.csv'   WITH HEADER CSV

-- Mapping tables directly into cdm
\copy location (location_id, county) FROM './mapping_tables/lan_locations.csv' WITH HEADER CSV
\copy care_site ( care_site_id, care_site_source_value, care_site_name, location_id ) FROM './mapping_tables/sjukhus_care_site.csv' WITH HEADER CSV;
\copy provider (provider_id, provider_name, specialty_concept_id, specialty_source_value) FROM './mapping_tables/spkod_specialty.csv' WITH HEADER CSV

-- Set location_source_value to be the same as the location_id
UPDATE location
SET location_source_value = location_id
;
