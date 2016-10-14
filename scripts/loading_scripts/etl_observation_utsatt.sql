INSERT INTO observation (
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

        CASE utsatt
        	WHEN 1 THEN 4142018 -- Discharge to hospital
        	WHEN 2 THEN 4143443 -- Discharge to nursing home
        	WHEN 3 THEN 4140634 -- Discharge to home
        	WHEN 4 THEN 4081608 -- Patient died in hospital
            ELSE 0
        END as observation_concept_id,
        4188539 as value_as_concept_id, -- Yes to suggestive statement

        to_date(utdatuma::varchar, 'yyyymmdd'),

        38000280 AS observation_type_concept_id, -- Observation recorded from EHR

        utsatt AS observation_source_value,
        'utsatt' AS qualifier_source_value
FROM (
    -- Utsatt only in sluten registry
    SELECT DISTINCT lpnr, indatuma, utdatuma, utsatt, visit_id
    FROM etl_input.patient_sluten_long

) patient_reg
WHERE utsatt IS NOT NULL -- Skip if utsatt is empty. No observation to record.
;
