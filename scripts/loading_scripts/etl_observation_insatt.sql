INSERT INTO cdm5.observation (
        -- observation_id is auto incremented by a sequence
        person_id,
        visit_occurrence_id,
        observation_concept_id,
        value_as_concept_id,
        observation_date,
        observation_type_concept_id,
        observation_source_value,
        value_as_string
    )

SELECT
        lpnr,
        visit_id,
        45884746 AS observation_concept_id,

        CASE insatt
        	WHEN 1 THEN 4318944 -- Hospital
        	WHEN 2 THEN 4148614 -- Retirement home
        	WHEN 3 THEN 4139502 -- Own home
        END as value_as_concept_id,

        to_date(indatuma::varchar, 'yyyymmdd'),

        38000280 AS observation_type_concept_id, -- Observation recorded from EHR

        'insatt' AS observation_source_value,
        insatt AS value_as_string
FROM (
    -- Civil status only in sluten and oppen registries
    SELECT DISTINCT lpnr, indatuma, utdatuma, insatt, visit_id
    FROM bayer.patient_sluten_long

) patient_reg
WHERE insatt IS NOT NULL -- Skip if utsatt is empty. No observation to record.
;
