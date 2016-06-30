/* Ethnic background, native or not.
*/

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
        4136468 as observation_concept_id, -- Ethnic background

        -- 11 and 12 are foreign, 21,22,23 are native Swedish
        -- TODO: find a observation value for foreign
        CASE utlsvbakgalt
            WHEN 11 THEN  NULL
            WHEN 12 THEN  NULL
            WHEN 21 THEN 43021808  -- Native
            WHEN 22 THEN 43021808  -- Native
            WHEN 23 THEN 43021808  -- Native
            ELSE 0 -- Not mappable
         END AS value_as_concept_id,

        to_date(year,'yyyy'),
        38000280 as observation_type_concept_id, -- Observation recorded from EHR
        'UtlSvBakgAlt' as observation_source_value,
        utlsvbakgalt as value_as_string -- Maybe redundant
FROM bayer.lisa as lisa
-- ONLY persons that are present in the person table! Otherwise foreign key constraint fails.
INNER JOIN cdm5.person as person ON person.person_id = lisa.lpnr
;
