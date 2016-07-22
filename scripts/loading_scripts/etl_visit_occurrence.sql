/* Visit occurrence table.
   For every record in the patient registry, create a visit occurrence.
   Indatum empty for some dag_kiru rows. Use 01-01-1900 as default value.
   Unique visit identifier (visit_id) stored in the long tables.
*/

INSERT INTO visit_occurrence (visit_occurrence_id, person_id,
        visit_start_date, visit_end_date, visit_concept_id, visit_source_value,
        care_site_id, visit_type_concept_id)

    SELECT  DISTINCT visit_id,
            lpnr,
            CASE WHEN indatuma IS NULL
                THEN to_date( '19000101', 'yyyymmdd')
                ELSE to_date( indatuma::varchar, 'yyyymmdd')
            END,

            CASE WHEN utdatuma IS NULL
                THEN to_date( '19000101', 'yyyymmdd')
                ELSE to_date( utdatuma::varchar, 'yyyymmdd')
            END,

            CASE visit_source_value
                WHEN 'sluten' THEN 9201
                WHEN 'oppen' THEN 9202
                WHEN 'dag kiru' THEN 45878057
                ELSE 0
            END as visit_concept_id,

            visit_source_value,
            care_site.care_site_id,
            44818518 AS visit_type_concept_id -- 'Visit derived from EHR record'
    FROM (
        SELECT lpnr, indatuma, utdatuma, sjukhus, visit_id, 'sluten' AS visit_source_value -- 'Outpatient'
        FROM bayer.patient_sluten_long

        UNION ALL

        SELECT lpnr, indatuma, indatuma as utdatuma, sjukhus, visit_id, 'oppen' AS visit_source_value -- 'Inpatient'
        FROM bayer.patient_oppen_long

        UNION ALL

        SELECT lpnr, indatuma, indatuma as utdatuma, sjukhus, visit_id, 'dag kiru' AS visit_source_value -- 'Ambulant Surgery'
        FROM bayer.patient_dag_kiru_long
    ) patient_reg

    -- It is possible that hospitals in patient registries
    -- are missing in care_site table. Thus, left join.
    LEFT JOIN care_site care_site
        ON patient_reg.sjukhus = care_site.care_site_source_value
;
