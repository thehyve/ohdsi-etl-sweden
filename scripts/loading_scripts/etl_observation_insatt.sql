INSERT INTO observation (
        -- observation_id is auto incremented by a sequence
        person_id,
        visit_occurrence_id,
        observation_concept_id,
        value_as_concept_id,
        observation_date,
        observation_type_concept_id,
        observation_source_value,
        qualifier_source_value
    )

SELECT
        lpnr,
        visit_id,
        -- 45884746 AS observation_concept_id,

        CASE insatt
        	WHEN 1 THEN 4164916 -- Hospital admission, transfer from other hospital or health care facility.
        	WHEN 2 THEN 8715 -- Hospital admission
        	WHEN 3 THEN 8715 -- Hospital admission
            ELSE 0
        END as observation_concept_id,
        4188539 as value_as_concept_id, -- Yes to suggestive statement

        to_date(indatuma::varchar, 'yyyymmdd'),

        38000280 AS observation_type_concept_id, -- Observation recorded from EHR

        insatt AS observation_source_value,
        'insatt' AS qualifier_source_value
FROM (
    -- Civil status only in sluten and oppen registries
    SELECT DISTINCT lpnr, indatuma, utdatuma, insatt, visit_id
    FROM etl_input.patient_sluten_long

) patient_reg
WHERE insatt IS NOT NULL -- Skip if utsatt is empty. No observation to record.
;
