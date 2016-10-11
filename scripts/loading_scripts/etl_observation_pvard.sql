/* Planned or not. observation = 'Planned', value = 'Yes' or 'No'.
*/
INSERT INTO observation (
        person_id,
        observation_concept_id,
        observation_date,
        observation_type_concept_id,
        observation_source_value,
        qualifier_source_value,
        visit_occurrence_id
    )
SELECT  lpnr,
        -- 4161676 as observation_concept_id, -- Planned, qualifier value

        CASE pvard
            WHEN 1 THEN 4228491 -- Planned admission
            WHEN 2 THEN 44803024 -- Unplanned local admission
            ELSE 0 -- Unknown
        END AS observation_concept_id,

        to_date(indatuma::varchar, 'yyyymmdd'),
        38000280 as observation_type_concept_id, -- Observation recorded from EHR
        pvard as observation_source_value,
        'pvard' as qualifier_source_value,
        visit_id
FROM (
    -- ekod status only in sluten and oppen registries
    SELECT DISTINCT lpnr, indatuma, pvard, visit_id
    FROM etl_input.patient_sluten_long

    UNION ALL

    SELECT DISTINCT lpnr, indatuma, pvard, visit_id
    FROM etl_input.patient_oppen_long
) A
;
