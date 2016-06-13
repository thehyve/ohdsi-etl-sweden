/* Observation period for each person.
    Hard coded parameters: data cut start = 19970101, data cut end = 20150801.
    TODO: add death as end of observation
    TODO: unit test the rules.
    Fails if emigration before start of datacut and no immigration (unlikely event)
*/
INSERT INTO cdm5.observation_period (
        observation_period_id,
        person_id,
        observation_period_start_date,
        observation_period_end_date,
        period_type_concept_id
)
SELECT  row_number() OVER(ORDER BY person_id) AS observation_period_id,
        person_id,

        getObservationStartDate( to_date('19970101','yyyymmdd'), year_of_birth, immi_date, emi_date ) as observation_period_start_date,
        getObservationEndDate( to_date('20150801','yyyymmdd'), death_date, immi_date, emi_date ) as observation_period_end_date,

        44814724 AS period_type_concept_id -- 'Period inferred by algorithm'

    FROM (
        SELECT person.person_id,
               to_date(person.year_of_birth::varchar, 'yyyymmdd') as year_of_birth,
               death.death_date,
               -- '   .' already filtered in lpnr_aggregated
               -- 1997 is converted by to_date to 01-01-1997
               to_date(seninv, 'yyyymmdd') as immi_date,
               to_date(senutv, 'yyyymmdd') as emi_date
        FROM cdm5.person as person
        LEFT JOIN bayer.lpnr_aggregated as emmigration
          ON person.person_id = emmigration.lpnr
        LEFT JOIN cdm5.death as death
          ON person.person_id = death.person_id
        -- WHERE senutv IS NOT NULL OR seninv IS NOT NULL
    ) A
;
