/* Procedures
*/

INSERT INTO cdm5.condition_occurrence (
    condition_occurrence_id, person_id, condition_concept_id, condition_start_date,
    condition_type_concept_id, visit_occurrence_id, condition_source_value
)

    SELECT  row_number() OVER (ORDER BY lpnr) as condition_occurrence_id,
            lpnr,
            CASE WHEN condition_map.target_concept_id IS NULL
                 THEN 0 -- cannot be mapped
                 ELSE condition_map.target_concept_id
            END as concept_id,

            CASE WHEN indatuma IS NULL
                THEN to_date( '19000101', 'yyyymmdd')
                ELSE to_date( indatuma::varchar, 'yyyymmdd')
            END as condition_start_date,

            CASE code_type
                WHEN 'hdia' THEN 44786627 -- Primary Condition
                WHEN 'bdia1' THEN 44786628 -- First Position Condition
                ELSE 44786629 -- Secondary Condition (for bdia2+)
            END as condition_type_concept_id,

            visit_id,
            code as condition_source_value
    FROM (
        SELECT lpnr, indatuma, code_type, code, visit_id
        FROM bayer.patient_sluten_long

        UNION ALL

        SELECT lpnr, indatuma, code_type, code, visit_id
        FROM bayer.patient_oppen_long

        UNION ALL

        SELECT lpnr, indatuma, code_type, code, visit_id
        FROM bayer.patient_dag_kiru_long
    ) patient_reg

    LEFT JOIN mappings.snomed AS condition_map
      ON code = condition_map.source_code

    -- Only diagnostic codes
    WHERE code_type = 'hdia' or code_type like 'bdia%'
    -- and condition_map.target_concept_id is not null
;
