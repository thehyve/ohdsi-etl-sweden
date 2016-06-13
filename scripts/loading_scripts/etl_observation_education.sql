INSERT INTO cdm5.observation (
        person_id,
        observation_concept_id,
        value_as_concept_id,
        observation_date,
        observation_type_concept_id,
        observation_source_value,
        value_as_string
    )
SELECT  lpnr,
        4022643 as observation_concept_id, -- Educational achievement

        -- Categorization based on the first digit
        CASE SUBSTRING(sun2000niva::varchar FROM 1 FOR 1)::integer -- floor(sun2000niva/100),
            WHEN 1 THEN 43022063 -- Received elementary school education
            WHEN 2 THEN 44800023 -- Educated to primary school level
            WHEN 3 THEN 43021808 -- Educated to high school level
            WHEN 4 THEN 4072735  -- Received university education
            WHEN 5 THEN 4072735  -- Received university education
            WHEN 6 THEN 44792317 -- Received doctorate education
            WHEN 9 THEN 4185231  -- Unknown
            ELSE 0 -- Not mappable
         END AS value_as_concept_id,

        to_date(year,'yyyy'),
        38000280 as observation_type_concept_id, -- Observation recorded from EHR
        'sun2000niva' as observation_source_value,
        sun2000niva as value_as_string -- Maybe redundant
FROM bayer.lisa as lisa
-- ONLY persons that are present in the person table! Otherwise foreign key constraint fails.
INNER JOIN cdm5.person as person ON person.person_id = lisa.lpnr
;
