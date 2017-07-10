/* Nomesco */
INSERT INTO vocabulary VALUES ('NOMESCO','Nordic Medico-Statistical Committee (NOMESCO) Classification of Surgical Procedures and Klassifikation av vårdåtgärder (KVÅ)','http://nowbase.org/da','1.16',0);

INSERT INTO source_to_concept_map (
    source_code,
    source_vocabulary_id,
    source_code_description,
    target_concept_id,
    target_vocabulary_id,
    -- Required fields, but useless:
    source_concept_id,
    valid_start_date,
    valid_end_date
)
SELECT nomesco.source_code,
       'NOMESCO' as source_vocabulary_id,
       nomesco.source_description,
       CASE WHEN nomesco.target_concept_id IS NULL
            THEN 0
            ELSE nomesco.target_concept_id
       END AS target_concept_id,
       concept.vocabulary_id,
       0 as source_concept_id,
       now(),
       to_date('31-12-2099','dd-mm-yyyy') -- Default
FROM etl_mappings.procedures_processed as nomesco
LEFT JOIN cdm5.concept
    ON nomesco.target_concept_id = concept.concept_id
;

/* ICD10SE */
INSERT INTO vocabulary VALUES ('ICD10-SE','International Classification of Diseases Swedish Dialect','http://www.socialstyrelsen.se/klassificeringochkoder/diagnoskodericd-10','',0);

\copy source_to_concept_map FROM './mapping_tables/icd10-se_source_to_concept_map.csv' WITH HEADER CSV ENCODING 'UTF8'

/* VaruNummer */
INSERT INTO vocabulary VALUES ('VaruNummer','Swedish Drug Article Numbers','https://npl.mpa.se/','',0);

\copy source_to_concept_map FROM './mapping_tables/varunr_source_to_concept_map.csv' WITH HEADER CSV ENCODING 'UTF8'
