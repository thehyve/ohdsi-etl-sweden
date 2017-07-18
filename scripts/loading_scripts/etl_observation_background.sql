/* Ethnic background, native or not.
*/

INSERT INTO observation (
        person_id,
        observation_concept_id,
        value_as_concept_id,
        observation_date,
        observation_type_concept_id,
        observation_source_value,
        qualifier_source_value
    )
SELECT  lpnr,

        -- 11 and 12 are foreign (no OMOP concept found), 21,22,23 are native Swedish
        CASE utlsvbakgalt
            WHEN 11 THEN  4058588 -- Immigrant
            WHEN 12 THEN  4058588 -- Immigrant
            WHEN 21 THEN 43021808 -- Native
            WHEN 22 THEN 43021808 -- Native
            WHEN 23 THEN 43021808 -- Native
            ELSE 0 -- Not mappable
         END AS observation_concept_id,
         4188539 as value_as_concept_id, -- Yes to suggestive statement

        to_date(year,'yyyy'),
        38000280 as observation_type_concept_id, -- Observation recorded from EHR
        utlsvbakgalt as observation_source_value,
        'utlsvbakgalt' as qualifier_source_value
FROM etl_input.lisa as lisa
-- ONLY persons that are present in the person table! Otherwise foreign key constraint fails.
INNER JOIN person as person ON person.person_id = lisa.lpnr
;
