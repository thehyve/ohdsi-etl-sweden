/* Procedure occurrence with nomesco codes.
Simple first letter mapping for nomesco chapters.
*/

INSERT INTO cdm5.procedure_occurrence (
    procedure_occurrence_id,
    person_id,
    procedure_concept_id,
    procedure_date,
    procedure_type_concept_id,

    visit_occurrence_id,
    procedure_source_value
)
    SELECT  row_number() OVER (ORDER BY lpnr),
            lpnr,
            CASE WHEN procedure_map.target_concept_id IS NULL
                 THEN 0 --not mappable
                 ELSE procedure_map.target_concept_id
            END as concept_id,

            CASE WHEN utdatuma IS NULL
                THEN to_date( '19000101', 'yyyymmdd') -- Have to give some date
                ELSE to_date( utdatuma::varchar, 'yyyymmdd')
            END as procedure_date,

            CASE WHEN code_type = 'op1'
                THEN 44786630 -- Primary Procedure
                ELSE 44786631 -- Secondary Procedure
            END as procedure_type_concept_id,

            visit_id,
            code as condition_source_value
    FROM (
        SELECT lpnr, indatuma, utdatuma, code_type, code, visit_id
        FROM bayer.patient_sluten_long

        UNION ALL

        SELECT lpnr, indatuma, indatuma as utdatuma, code_type, code, visit_id
        FROM bayer.patient_oppen_long

        UNION ALL

        SELECT lpnr, indatuma, indatuma as utdatuma, code_type, code, visit_id
        FROM bayer.patient_dag_kiru_long
    ) patient_reg

    LEFT JOIN mappings.nomesco AS procedure_map
      ON code = procedure_map.source_code OR
         -- Match on first letter. Only if complete code not in the mappping table (otherwise double entries)
         (SUBSTRING(code FROM 1 FOR 1) = procedure_map.source_code AND
          code NOT IN (SELECT source_code FROM mappings.nomesco) )

    -- Only diagnostic codes
    WHERE code_type like 'op%'
    -- and procedure_map.target_concept_id is null
;
