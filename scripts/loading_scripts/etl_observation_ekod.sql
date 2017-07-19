INSERT INTO observation (
        person_id,
        observation_concept_id,
        value_as_concept_id,
        observation_date,
        observation_type_concept_id,
        observation_source_value,
        qualifier_source_value,
        visit_occurrence_id
    )
SELECT  lpnr,

        CASE WHEN condition_map.target_concept_id IS NULL
             THEN 0 -- cannot be mapped
             ELSE condition_map.target_concept_id
        END as observation_concept_id,
        4188539 as value_as_concept_id, -- Yes to suggestive statement

        to_date(indatuma::varchar, 'yyyymmdd'),
        38000280 as observation_type_concept_id, -- Observation recorded from EHR
        code as observation_source_value,
        'ekod' as qualifier_source_value,
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
) patient_registry
LEFT JOIN source_to_concept_map AS condition_map
  ON condition_map.source_vocabulary_id = 'ICD10-SE'
  AND TRIM(trailing '-xXpPtT' from patient_registry.code) = condition_map.source_code
;
