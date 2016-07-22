INSERT INTO observation (
        person_id,
        observation_concept_id,
        value_as_concept_id,
        observation_date,
        observation_type_concept_id,
        observation_source_value,
        value_as_string,
        visit_occurrence_id
    )
SELECT  lpnr,
        4081668 as observation_concept_id, -- Cause of accident type

        icd10.target_concept_id as value_as_concept_id,

        to_date(indatuma::varchar, 'yyyymmdd'),
        38000280 as observation_type_concept_id, -- Observation recorded from EHR
        'ekod' as observation_source_value,
        code as value_as_string,
        visit_id
FROM (
    -- ekod status only in sluten and oppen registries
    SELECT DISTINCT lpnr, indatuma, utdatuma, code, visit_id
    FROM bayer.patient_sluten_long
    WHERE code_type LIKE 'ekod%'

    UNION ALL

    SELECT DISTINCT lpnr, indatuma, indatuma as utdatuma, code, visit_id
    FROM bayer.patient_oppen_long
    WHERE code_type LIKE 'ekod%'
) A
LEFT JOIN mappings.icd10_ekod icd10
  ON code = source_code
;
