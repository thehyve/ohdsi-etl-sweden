INSERT INTO person
( person_id, person_source_value, location_id, gender_concept_id, gender_source_value,
    year_of_birth, race_concept_id, ethnicity_concept_id )
SELECT  -- If record not in LISA, then use the lpnr from the registries.
        -- Should not happen as LISA contains all patients.
        CASE WHEN lisa.lpnr IS NULL
             THEN age_gender.lpnr
             ELSE lisa.lpnr
        END as person_id,
        CASE WHEN lisa.lpnr IS NULL
             THEN age_gender.lpnr
             ELSE lisa.lpnr
        END as lpnr2, -- lpnr as person_id and person_source_value. Alternative: create own ids?
        -- Location (lan == location_id)
        lisa.lan as location_id,
        -- Gender
        CASE age_gender.kon
            WHEN 1 THEN 8507 -- MALE
            WHEN 2 THEN 8532 -- FEMALE
            ELSE 8551 -- UNKNOWN
        END as kon,
        age_gender.kon, -- Source value
        -- Age
        age_gender.year_of_birth, -- CASE WHEN age_gender.year_of_birth IS NULL
        8552 as race_concept_id,      -- unknown race
        0 as ethnicity_concept_id     -- not mappable
FROM
    -- 13-06-2016. No duplicate persons allowed. Could be duplicates
    -- from different lisa years. If duplicate, the first row is chosen
( SELECT DISTINCT ON (lpnr) * FROM bayer.lisa ) AS lisa
-- LEFT JOIN bayer.lisa AS lisa
  -- ON temp.lpnr = lisa.lpnr AND temp.year = lisa.year
-- Full outer to also keep missing data on both tables.
FULL OUTER JOIN bayer.lpnr_aggregated AS age_gender
  ON lisa.lpnr = age_gender.lpnr
-- Remove persons which have no year of birth.
WHERE age_gender.year_of_birth IS NOT NULL
;
