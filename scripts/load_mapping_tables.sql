/* Load and create the manual mapping tables */
-- DROP SCHEMA IF EXISTS mappings CASCADE;
CREATE SCHEMA mappings;

-- CREATE TABLE mappings.icd10 (
--     source_code	varchar(50),-- primary key,
--     source_concept_id integer,
--     source_vocabulary_id varchar(50), -- manual
--     source_code_description	varchar(200), -- frequency
--     target_concept_id integer,
--     target_vocabulary_id varchar(50), -- concept_class_id
--     valid_start_date varchar(20), -- target_code
--     valid_end_date varchar(20), -- target_name
--     invalid_reason varchar(5)
-- )
-- ;
CREATE TABLE mappings.snomed (
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

CREATE TABLE mappings.nomesco (
    source_code	varchar(50) PRIMARY KEY,
    source_concept_id integer,
    source_vocabulary_id varchar(50),
    source_code_description	varchar(200),
    target_concept_id integer,
    target_vocabulary_id varchar(50),
    valid_start_date varchar(20),
    valid_end_date varchar(20),
    invalid_reason varchar(5)
)
;

CREATE TABLE mappings.dose_form (
    source_code	varchar(50) PRIMARY KEY,
    frequency integer,
    source_code_description varchar(200),
    target_concept_id integer,
    target_description varchar(100)
)
;

CREATE TABLE mappings.unit (
    source_code	varchar(50) PRIMARY KEY,
    frequency integer,
    target_concept_id integer,
    target_description varchar(100)
)
;

-- Load the tables
-- \copy mappings.icd10 FROM './mapping_tables/icd10.csv'   WITH HEADER CSV
\copy mappings.snomed FROM './mapping_tables/ICD10_SNOMED.csv'   WITH HEADER CSV
\copy mappings.nomesco FROM './mapping_tables/NOMESCO.csv'   WITH HEADER CSV
\copy mappings.dose_form FROM './mapping_tables/dose_form.csv'   WITH HEADER CSV
\copy mappings.unit FROM './mapping_tables/unit.csv'   WITH HEADER CSV

-- Mapping tables directly into cdm
\copy cdm5.location (location_id, county) FROM './mapping_tables/lan_locations.csv' WITH HEADER CSV
\copy cdm5.care_site ( care_site_id, care_site_source_value, care_site_name, location_id ) FROM './mapping_tables/sjukhus_care_site.csv' WITH HEADER CSV;
\copy cdm5.provider (provider_id, provider_name, specialty_concept_id, specialty_source_value) FROM './mapping_tables/spkod_provider.csv' WITH HEADER CSV

-- Set location_source_value to be the same as the location_id
UPDATE cdm5.location
SET location_source_value = location_id
;
