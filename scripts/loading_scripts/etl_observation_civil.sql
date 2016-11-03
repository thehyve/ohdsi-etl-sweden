/* Civil/Marital status. Married, single, divorced, widow, etc.
   Retrieved from the inpatient and outpatient files.
*/

INSERT INTO observation (
        person_id,
        observation_concept_id,
        value_as_concept_id,
        observation_date,
        observation_type_concept_id,
        observation_source_value,
        qualifier_source_value
    )

SELECT
        lpnr,

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

        to_date(year,'yyyy') as observation_date,

        38000280 as measurement_type_concept_id, -- Observation recorded from EHR ,
        -- Save source values
        civil AS observation_source_value,
        'civil' AS qualifier_source_value
FROM etl_input.lisa as lisa
-- ONLY persons that are present in the person table! Otherwise foreign key constraint fails.
INNER JOIN person as person ON person.person_id = lisa.lpnr
WHERE civil IS NOT NULL -- Skip if civil is empty. No observation to record.
;
