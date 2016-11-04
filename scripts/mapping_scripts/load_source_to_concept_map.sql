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
       nomesco.target_concept_id,
       concept.vocabulary_id,
       0 as source_concept_id,
       now(),
       to_date('31-12-2099','dd-mm-yyyy') -- Default
FROM etl_mappings.procedures_processed as nomesco
JOIN cdm5.concept
    ON nomesco.target_concept_id = concept.concept_id
;

/* ICD10SE */
INSERT INTO vocabulary VALUES ('ICD10-SE','International Classification of Diseases Swedish Dialect','http://www.socialstyrelsen.se/klassificeringochkoder/diagnoskodericd-10','',0);

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
SELECT icd10se.source_code,
       'ICD10-SE' as source_vocabulary_id,
       '' as source_description,
       icd10se.target_concept_id,
       concept.vocabulary_id,
       CASE WHEN intermediate_concept_id IS NULL
            THEN 0
            ELSE intermediate_concept_id
       END as source_concept_id,
       now(),
       to_date('31-12-2099','dd-mm-yyyy') -- Default
FROM etl_mappings.icd10_snomed as icd10se
JOIN cdm5.concept
    ON icd10se.target_concept_id = concept.concept_id
;

/* ATC drug */
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
SELECT atc,
       'ATC' as source_vocabulary_id,
       vnr_mapping.lnamn as source_description,
       vnr_mapping.target_concept_id,
       concept.vocabulary_id,
       CASE WHEN atc_concept_id IS NULL
            THEN 0
            ELSE atc_concept_id
       END as source_concept_id,
       now(),
       to_date('31-12-2099','dd-mm-yyyy') -- Default
FROM etl_mappings.vnr_mapping
JOIN drugmap.vnr_to_ingredient
    ON source_concept_id = vnr_to_ingredient.vnr
JOIN drugmap.unique_varunr
    ON unique_varunr.varunr = source_concept_id
JOIN cdm5.concept
    ON vnr_mapping.target_concept_id = concept.concept_id
ON CONFLICT DO NOTHING -- If unique constraint violated, then skip the row (happens if same atc_code and target_concept_id, different brand)
;
