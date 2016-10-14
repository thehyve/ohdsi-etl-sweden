/* Visit planned or not.
*/
INSERT INTO observation (
        person_id,
        observation_concept_id,
        value_as_concept_id,
        observation_date,
        observation_type_concept_id,
        observation_source_value,
        qualifier_source_value,
        visit_occurrence_id
    )
SELECT  lpnr,

        CASE pvard
            WHEN 1 THEN 4228491     -- Planned admission
            WHEN 2 THEN 44803024    -- Unplanned local admission
            ELSE 0 -- Not mappable
        END AS observation_concept_id,
        4188539 as value_as_concept_id, -- Yes to suggestive statement

        to_date(indatuma::varchar, 'yyyymmdd'),
        38000280 as observation_type_concept_id, -- Observation recorded from EHR
        pvard as observation_source_value,
        'pvard' as qualifier_source_value,
        visit_id
FROM (
    -- pvard status only in sluten and oppen registries
    SELECT DISTINCT lpnr, indatuma, pvard, visit_id
    FROM etl_input.patient_sluten_long

    UNION ALL

    SELECT DISTINCT lpnr, indatuma, pvard, visit_id
    FROM etl_input.patient_oppen_long
) A
;
