INSERT INTO observation (
        -- observation_id is auto incremented by a sequence
        person_id,
        visit_occurrence_id,
        observation_concept_id,
        value_as_concept_id,
        observation_date,
        observation_type_concept_id,
        observation_source_value,
        value_as_string
    )

SELECT
        lpnr,
        visit_id,
        40757182 AS observation_concept_id,

        CASE utsatt
        	WHEN 1 THEN 4142018 -- Discharge to hospital
        	WHEN 2 THEN 4148614 -- Retirement home
        	WHEN 3 THEN 4140634 -- Discharge to home
        	WHEN 4 THEN 4081608 -- Patient died in hospital
        END as value_as_concept_id,

        to_date(indatuma::varchar, 'yyyymmdd'),

        38000280 AS observation_type_concept_id, -- Observation recorded from EHR

        'utsatt' AS observation_source_value,
        utsatt AS value_as_string
FROM (
    -- Civil status only in sluten and oppen registries
    SELECT DISTINCT lpnr, indatuma, utdatuma, utsatt, visit_id
    FROM etl_input.patient_sluten_long

) patient_reg
WHERE utsatt IS NOT NULL -- Skip if utsatt is empty. No observation to record.
;
