INSERT INTO measurement (
        -- measurement_id is auto incremented by a sequence,
        person_id,
        measurement_concept_id,
        measurement_date,
        measurement_type_concept_id,
        value_as_number,
        measurement_source_value,
        value_source_value,
        unit_concept_id
    )

SELECT  lpnr,
        4073460 as measurement_concept_id, -- Individual income
        to_date(year,'yyyy'),
        38000280 as measurement_type_concept_id, -- Observation recorded from EHR
        dispinkpersf04 as value_as_number,
        'dispinkpersf04' as measurement_source_value,
        dispinkpersf04 as value_source_value,
        44818647 as unit_concept_id -- Currency: Swedish krona/kronor
FROM etl_input.lisa as lisa
-- ONLY persons that are present in the person table!
INNER JOIN person as person ON person.person_id = lisa.lpnr
;
