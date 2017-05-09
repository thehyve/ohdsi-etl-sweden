/* Load and create the manual mapping tables */
CREATE SCHEMA etl_mappings;

CREATE TABLE etl_mappings.icd10_snomed (
    source_code	varchar(50) PRIMARY KEY,
    intermediate_code varchar(50),
    intermediate_concept_id integer,
    intermediate_name varchar(255),
    intermediate_vocabulary varchar(50),
    target_concept_id integer,
    target_name varchar(255),
    target_vocabulary varchar(50)
)
;

CREATE TABLE etl_mappings.nomesco (
    source_code	varchar(50) PRIMARY KEY,
    source_name varchar(255),
    target_concept_id integer,
    target_name varchar(255)
)
;

CREATE TABLE etl_mappings.kva (
    source_code	 varchar(50) PRIMARY KEY,
    source_name  varchar(255),
    target_concept_id  integer,
    target_name  varchar(255)
)
;

CREATE TABLE etl_mappings.nomesco_kva_description (
    source_code	varchar(50) PRIMARY KEY,
    source_description varchar(511)
)
;

CREATE TABLE etl_mappings.dose_form (
    source_code	varchar(50) PRIMARY KEY,
    source_code_description varchar(255),
    target_concept_id integer,
    target_description varchar(255)
)
;

CREATE TABLE etl_mappings.unit (
    source_code	varchar(50) PRIMARY KEY,
    target_concept_id integer,
    target_description varchar(255)
)
;

-- Load the tables. All csv mapping tables should be UTF8 encoded
\copy etl_mappings.icd10_snomed FROM './mapping_tables/ICD10se.csv'   WITH HEADER CSV
\copy etl_mappings.nomesco FROM './mapping_tables/nomesco.csv'   WITH HEADER CSV
\copy etl_mappings.kva FROM './mapping_tables/procedures_kva.csv'   WITH HEADER CSV
\copy etl_mappings.nomesco_kva_description FROM './mapping_tables/nomesco_kva_description.csv'   WITH HEADER CSV
\copy etl_mappings.dose_form FROM './mapping_tables/dose_form.csv'   WITH HEADER CSV
\copy etl_mappings.unit FROM './mapping_tables/unit.csv'   WITH HEADER CSV

-- Mapping tables directly into cdm
\copy location (location_id, county) FROM './resources/lan_locations.csv' WITH HEADER CSV
\copy care_site ( care_site_id, care_site_source_value, care_site_name, location_id ) FROM './resources/sjukhus_care_site.csv' WITH HEADER CSV;
\copy provider (provider_id, provider_name, specialty_concept_id, specialty_source_value) FROM './resources/spkod_specialty.csv' WITH HEADER CSV

-- Set location_source_value to be the same as the location_id
UPDATE location
SET location_source_value = location_id
;
