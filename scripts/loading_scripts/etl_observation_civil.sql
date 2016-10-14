/* Civil/Marital status. Married, single, divorced, widow, etc.
   Retrieved from the inpatient and outpatient files.
*/

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

        CASE civil
            WHEN 'G' THEN 4338692   -- Married
            WHEN 'OG' THEN 4053842  -- Single Person
            WHEN 'O' THEN 0         -- Not mappable
            WHEN 'S' THEN 4069297   -- Divorced
            WHEN 'Ä' THEN 4143188   -- Widower
            WHEN 'RP' THEN 4325710  -- Domestic partnership
            WHEN 'SP' THEN 4069297  -- Divorced
            WHEN 'EP' THEN 4143188  -- Widower
            ELSE 0
        END as observation_concept_id,
        4188539 as value_as_concept_id, -- Yes

        to_date( indatuma::varchar, 'yyyymmdd'),

        38000280 as measurement_type_concept_id, -- Observation recorded from EHR ,
        -- Save source values
        civil AS observation_source_value,
        'civil' AS qualifier_source_value
FROM (
    -- Civil status only in sluten and oppen registries
    SELECT DISTINCT lpnr, indatuma, utdatuma, civil, visit_id
    FROM etl_input.patient_sluten_long

    UNION ALL

    SELECT DISTINCT lpnr, indatuma, indatuma as utdatuma, civil, visit_id
    FROM etl_input.patient_oppen_long

) patient_reg
WHERE civil IS NOT NULL -- Skip if civil is empty. No observation to record.
;
