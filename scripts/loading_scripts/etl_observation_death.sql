INSERT INTO observation (
        person_id,
        observation_concept_id,
        value_as_concept_id,
        observation_date,
        observation_type_concept_id,
        observation_source_value,
        value_as_string
    )
SELECT  lpnr,
        4083743 as observation_concept_id, -- Cause Of Death (SNOMED CLINICAL FINDING)

        -- Translated snomed target_concept_id
        CASE WHEN snomed.target_concept_id IS NULL
             THEN 0
             ELSE snomed.target_concept_id
        END AS value_as_concept_id,

        convertDeathDate( dodsdat::varchar ) as observation_date,
        38000280 as observation_type_concept_id, -- Observation recorded from EHR
        code_type as observation_source_value,
        death.code as value_as_string -- Original source concept

FROM etl_input.death_long as death
-- ONLY persons that are present in the person table! Otherwise foreign key constraint fails.
INNER JOIN person as person ON person.person_id = death.lpnr
LEFT JOIN etl_mappings.snomed AS snomed
  ON death.code = snomed.source_code
WHERE death.code_type LIKE 'morsak%'
;
