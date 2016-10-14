INSERT INTO observation (
        person_id,
        observation_concept_id,
        value_as_concept_id,
        observation_date,
        observation_type_concept_id,
        observation_source_value,
        qualifier_source_value,
        observation_source_concept_id,
        visit_occurrence_id
    )
SELECT  lpnr,

        CASE WHEN icd10_to_snomed.target_concept_id IS NULL
             THEN 0 -- cannot be mapped
             ELSE icd10_to_snomed.target_concept_id
        END as observation_concept_id,
        4188539 as value_as_concept_id, -- Yes to suggestive statement

        to_date(indatuma::varchar, 'yyyymmdd'),
        38000280 as observation_type_concept_id, -- Observation recorded from EHR
        code as observation_source_value,
        'ekod' as qualifier_source_value,
        icd10_to_snomed.intermediate_concept_id as observation_source_concept_id,
        visit_id
FROM (
    -- ekod status only in sluten and oppen registries
    SELECT DISTINCT lpnr, indatuma, utdatuma, code, visit_id
    FROM etl_input.patient_sluten_long
    WHERE code_type LIKE 'ekod%'

    UNION ALL

    SELECT DISTINCT lpnr, indatuma, indatuma as utdatuma, code, visit_id
    FROM etl_input.patient_oppen_long
    WHERE code_type LIKE 'ekod%'
) A
LEFT JOIN etl_mappings.icd10_snomed icd10_to_snomed
  ON code = source_code
;
