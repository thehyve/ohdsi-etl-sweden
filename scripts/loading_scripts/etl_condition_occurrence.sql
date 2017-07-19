/* Conditions.
For each diagnostic code in the long format patient registries, add a row in
condition_occurrence. Dates are
*/

INSERT INTO condition_occurrence (
    person_id,
    condition_concept_id,
    condition_start_date,
    condition_type_concept_id,
    visit_occurrence_id,
    condition_source_value
)

    SELECT  lpnr,
            CASE WHEN condition_map.target_concept_id IS NULL
                 THEN 0 -- cannot be mapped
                 ELSE condition_map.target_concept_id
            END as concept_id,

            CASE WHEN indatuma IS NULL
                THEN to_date( '19000101', 'yyyymmdd') -- Should not happen
                ELSE to_date( indatuma::varchar, 'yyyymmdd')
            END as condition_start_date,

            CASE code_type
                WHEN 'hdia' THEN 44786627   -- Primary Condition
                WHEN 'bdia1' THEN 44786628  -- First Position Condition
                ELSE 44786629               -- Secondary Condition (for bdia2+)
            END as condition_type_concept_id,

            visit_id,
            code as condition_source_value
    FROM (
        SELECT lpnr, indatuma, code_type, code, visit_id
        FROM etl_input.patient_sluten_long

        UNION ALL

        SELECT lpnr, indatuma, code_type, code, visit_id
        FROM etl_input.patient_oppen_long

        UNION ALL

        SELECT lpnr, indatuma, code_type, code, visit_id
        FROM etl_input.patient_dag_kiru_long
    ) patient_reg

    LEFT JOIN source_to_concept_map AS condition_map
      ON condition_map.source_vocabulary_id = 'ICD10-SE'
      AND TRIM(trailing '-xXpPtT' from patient_reg.code) = condition_map.source_code

    -- Only diagnostic codes
    WHERE code_type = 'hdia' or code_type like 'bdia%'
;
