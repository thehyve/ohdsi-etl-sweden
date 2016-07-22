/* Source: https://gist.github.com/chrisknoll/a18c8e15ff66f26fac84
   Added INSERT INTO drug_era (last statement)
   Removed drug_type_concept_id from insert.
   Translated from Oracle to PostgreSQL
    - DATEADD => date + INTERVAL '1 day'
*/

WITH
cteDrugTarget (drug_exposure_id, person_id, drug_concept_id, drug_type_concept_id, drug_exposure_start_date, drug_exposure_end_date) as
(
-- Normalize DRUG_EXPOSURE_END_DATE to either the existing drug exposure end date, or add days supply, or add 1 day to the start date
	SELECT  d.drug_exposure_id, d.person_id, c.concept_id, d.drug_type_concept_id, drug_exposure_start_date,
			COALESCE(drug_exposure_end_date,
					 drug_exposure_start_date + days_supply * INTERVAL '1 day',
					 drug_exposure_start_date + INTERVAL '1 day') as drug_exposure_end_date
	FROM drug_exposure d
		JOIN concept_ancestor ca ON ca.DESCENDANT_CONCEPT_ID = d.DRUG_CONCEPT_ID
		JOIN concept c ON ca.ANCESTOR_CONCEPT_ID = c.CONCEPT_ID
		WHERE c.VOCABULARY_ID = 'RxNorm'
		AND c.CONCEPT_CLASS_ID = 'Ingredient'
),
cteEndDates (person_id, drug_concept_id, end_date) AS -- the magic
(
	SELECT  person_id,
			drug_concept_id,
			event_date + -30 * INTERVAL '1 day' as end_date -- unpad the end date
	FROM
	(
		SELECT person_id, drug_concept_id, event_date, event_type,
		MAX(start_ordinal) OVER (PARTITION BY person_id, drug_concept_id ORDER BY EVENT_DATE, EVENT_TYPE ROWS UNBOUNDED PRECEDING) as START_ORDINAL, -- this pulls the current START down from the prior rows so that the NULLs from the END DATES will contain a value we can compare with
		ROW_NUMBER() OVER (PARTITION BY PERSON_ID, DRUG_CONCEPT_ID ORDER BY EVENT_DATE, EVENT_TYPE) AS OVERALL_ORD -- this re-numbers the inner UNION so all rows are numbered ordered by the event date
		FROM
		(
			-- select the start dates, assigning a row number to each
			SELECT PERSON_ID, DRUG_CONCEPT_ID, DRUG_EXPOSURE_START_DATE AS EVENT_DATE, -1 as EVENT_TYPE, ROW_NUMBER() OVER (PARTITION BY PERSON_ID, DRUG_CONCEPT_ID ORDER BY DRUG_EXPOSURE_START_DATE) as START_ORDINAL
			FROM cteDrugTarget

			UNION ALL

			-- pad the end dates by 30 to allow a grace period for overlapping ranges.
			SELECT person_id, drug_concept_id, drug_exposure_end_date + 30 * INTERVAL '1 day', 1 as event_type, NULL
			FROM cteDrugTarget
		) RAWDATA
	) E
	WHERE (2 * E.START_ORDINAL) - E.OVERALL_ORD = 0
),
cteDrugExposureEnds (PERSON_ID, DRUG_CONCEPT_ID, DRUG_TYPE_CONCEPT_ID, DRUG_EXPOSURE_START_DATE, DRUG_ERA_END_DATE) as
(
SELECT
	d.PERSON_ID,
	d.DRUG_CONCEPT_ID,
	d.DRUG_TYPE_CONCEPT_ID,
	d.DRUG_EXPOSURE_START_DATE,
	MIN(e.END_DATE) as ERA_END_DATE
FROM cteDrugTarget d
JOIN cteEndDates e on d.PERSON_ID = e.PERSON_ID and d.DRUG_CONCEPT_ID = e.DRUG_CONCEPT_ID and e.END_DATE >= d.DRUG_EXPOSURE_START_DATE
GROUP BY d.DRUG_EXPOSURE_ID,
	d.PERSON_ID,
	d.DRUG_CONCEPT_ID,
	d.DRUG_TYPE_CONCEPT_ID,
	d.DRUG_EXPOSURE_START_DATE
)

-- Add INSERT statement here
INSERT INTO drug_era (
	drug_era_id,
	person_id,
	drug_concept_id,
	-- drug_type_concept_id,
	drug_era_start_date,
	drug_era_end_date,
	drug_exposure_count
)
SELECT  ROW_NUMBER() OVER (ORDER BY person_id),
		person_id,
		drug_concept_id,
		-- drug_type_concept_id,
		MIN(drug_exposure_start_date) as drug_era_start_date,
		drug_era_end_date,
		COUNT(*) as drug_exposure_count
FROM cteDrugExposureEnds
GROUP BY person_id, drug_concept_id, drug_type_concept_id, DRUG_ERA_END_DATE
ORDER BY person_id, drug_concept_id
;
