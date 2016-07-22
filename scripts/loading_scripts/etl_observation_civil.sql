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
        4053609 AS observation_concept_id, -- Marital status

        CASE civil
            WHEN 'G' THEN 4338692 -- Married
            WHEN 'OG' THEN 4053842 -- Single Person
            WHEN 'O' THEN 0 -- Not mappable
            WHEN 'S' THEN 4069297 -- Divorced
            WHEN 'Ä' THEN 4143188 -- Widower
            WHEN 'RP' THEN 4325710 -- Domestic partnership
            WHEN 'SP' THEN 4069297 -- Divorced
            WHEN 'EP' THEN 4143188 -- Widower
            ELSE 0
        END as value_as_concept_id,

        to_date( indatuma::varchar, 'yyyymmdd'),

        38000280 as measurement_type_concept_id, -- Observation recorded from EHR ,
        -- Save source value both as observation_source and value_as_string
        'civil' AS observation_source_value,
        civil AS value_as_string
FROM (
    -- Civil status only in sluten and oppen registries
    SELECT DISTINCT lpnr, indatuma, utdatuma, civil, visit_id
    FROM bayer.patient_sluten_long

    UNION ALL

    SELECT DISTINCT lpnr, indatuma, indatuma as utdatuma, civil, visit_id
    FROM bayer.patient_oppen_long

) patient_reg
WHERE civil IS NOT NULL -- Skip if civil is empty. No observation to record.
;
