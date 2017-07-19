/* Populate death table */
WITH distinct_persons AS (
    -- Only one row per person. One death per person
    SELECT DISTINCT ON (lpnr) *
    FROM etl_input.death
), condition_map_one_to_one AS (
    -- Prevent inserting more than one row due to one to many mappings
    SELECT source_code, MIN(target_concept_id) AS target_concept_id
    FROM source_to_concept_map
    WHERE source_vocabulary_id = 'ICD10-SE'
    GROUP BY source_code
)
INSERT INTO death (person_id, death_date, cause_concept_id, cause_source_value, death_type_concept_id)
SELECT lpnr,
       convertDeathDate(dodsdat),
       CASE WHEN ulorsak_map.target_concept_id IS NULL
            THEN 0
            ELSE ulorsak_map.target_concept_id
       END as cause_concept_id,
       ulorsak,
       38003569 -- EHR record patient status "Deceased"

FROM distinct_persons AS death
LEFT JOIN condition_map_one_to_one AS ulorsak_map
  ON TRIM(trailing '-xXpPtT' from death.ulorsak) = ulorsak_map.source_code
;
