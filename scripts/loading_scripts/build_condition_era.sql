/* Source: https://gist.github.com/taylordelehanty/01fe9e92a322331a8b35
*/
-- TRUNCATE condition_era;

WITH
cteConditionTarget (condition_occurrence_id, person_id, condition_concept_id, condition_start_date, condition_end_date) AS
(
	SELECT co.condition_occurrence_id, co.person_id, co.condition_concept_id, co.condition_start_date,
	       COALESCE(NULLIF(co.condition_end_date,NULL), condition_start_date + INTERVAL '1 day') AS condition_end_date
	---Format for FROM statement below is like this: "FROM <schema>.<table> co"
	FROM condition_occurrence co
),
--------------------------------------------------------------------------------------------------------------
cteEndDates (person_id, condition_concept_id, end_date) AS -- the magic
(
	SELECT person_id, condition_concept_id, event_date - INTERVAL '30 days' AS end_date -- unpad the end date
	FROM
	(
		SELECT person_id, condition_concept_id, event_date, event_type,
		MAX(start_ordinal) OVER (PARTITION BY person_id, condition_concept_id ORDER BY event_date, event_type ROWS UNBOUNDED PRECEDING) AS start_ordinal, -- this pulls the current START down from the prior rows so that the NULLs from the END DATES will contain a value we can compare with
		ROW_NUMBER() OVER (PARTITION BY person_id, condition_concept_id ORDER BY event_date, event_type) AS overall_ord -- this re-numbers the inner UNION so all rows are numbered ordered by the event date
		FROM
		(
			-- select the start dates, assigning a row number to each
			SELECT person_id, condition_concept_id, condition_start_date AS event_date, -1 AS event_type, ROW_NUMBER() OVER (PARTITION BY person_id, condition_concept_id ORDER BY condition_start_date) AS start_ordinal
			FROM cteConditionTarget

			UNION ALL

			-- pad the end dates by 30 to allow a grace period for overlapping ranges.
			SELECT person_id, condition_concept_id, condition_end_date + INTERVAL '30 days', 1 AS event_type, NULL
			FROM cteConditionTarget
		) RAWDATA
	) e
	WHERE (2 * e.start_ordinal) - e.overall_ord = 0
),
--------------------------------------------------------------------------------------------------------------
cteConditionEnds (person_id, condition_concept_id, condition_start_date, era_end_date) AS
(
SELECT
        c.person_id,
	c.condition_concept_id,
	c.condition_start_date,
	MIN(e.end_date) AS era_end_date
FROM cteConditionTarget c
JOIN cteEndDates e ON c.person_id = e.person_id AND c.condition_concept_id = e.condition_concept_id AND e.end_date >= c.condition_start_date
GROUP BY
---In Chris's original condition_era code, condition_occurrence_id is not in this table, but when at SAFTINet we ran through our data, we found that our condition_occurrence_count was not matching the count of all of the condition_occurrences in the condition_occurrence table. So to solve that and keep the records of the same person_id, condition_concept_id, and start_date from getting overlooked and put into one row, we grouped them by condition_occurrence_id as well to keep them from getting lumped together and overlooked.
---Chris DOES have this type of GROUP BY in his drug_era code
        c.condition_occurrence_id,
	c.person_id,
	c.condition_concept_id,
	c.condition_start_date
)
--------------------------------------------------------------------------------------------------------------
---This INSERT INTO statement is similar to the FROM statement at the beginning. This is the format: "INSERT INTO <schema>.<table>(<fields>)"
INSERT INTO condition_era(
	condition_era_id,
	person_id,
	condition_concept_id,
	condition_era_start_date,
	condition_era_end_date,
	condition_occurrence_count)
SELECT  ROW_NUMBER() OVER (ORDER BY person_id),
		person_id,
		condition_concept_id,
		MIN(condition_start_date) AS condition_era_start_date,
		era_end_date AS condition_era_end_date,
		COUNT(*) AS condition_occurrence_count

FROM cteConditionEnds
GROUP BY person_id, condition_concept_id, era_end_date
ORDER BY person_id, condition_concept_id
;
