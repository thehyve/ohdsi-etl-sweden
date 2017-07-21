/*** DEPRECATED since July 2017 *****/

/* Process the nomesco and kva codes separately and put back together.

   Nomesco codes consist of 3 letters and 2 digits. They are mapped on all five
   characters or only the first one or two letters.
   The 'highest' mapping for each concept is taken. (e.g. if both a corresponding
   two and five letter mapping, then the five letter mapping is taken)

   KVA codes start with 2 letters (3 digits). They are only mapped on five
   character level.*/
WITH unique_procedures as (
    SELECT code
    FROM (
        SELECT code, code_type
        FROM etl_input.patient_sluten_long

        UNION ALL

        SELECT code, code_type
        FROM etl_input.patient_oppen_long

        UNION ALL

        SELECT code, code_type
        FROM etl_input.patient_dag_kiru_long
    ) patient_reg
    WHERE code_type like 'op%'
    GROUP BY code
),
nomesco AS (
	SELECT *
	FROM unique_procedures
	WHERE code ~ '[a-zA-Z][a-zA-Z][a-zA-Z]'
),
kva AS (
	SELECT *
	FROM unique_procedures
	WHERE code !~ '[a-zA-Z][a-zA-Z][a-zA-Z]'
),
five_char_mapping as (
    SELECT code, mapping.source_name, mapping.target_concept_id
    FROM nomesco
    JOIN etl_mappings.nomesco AS mapping
        ON code = mapping.source_code
),
two_char_mapping as (
    SELECT code, mapping.source_name, mapping.target_concept_id
    FROM nomesco
    JOIN etl_mappings.nomesco AS mapping
        ON SUBSTRING(code FROM 1 FOR 2) = mapping.source_code
    WHERE code NOT IN (SELECT code FROM five_char_mapping)
),
one_char_mapping as (
    SELECT code, mapping.source_name, mapping.target_concept_id
    FROM nomesco
    JOIN etl_mappings.nomesco AS mapping
        ON SUBSTRING(code FROM 1 FOR 1) = mapping.source_code
    WHERE code NOT IN (SELECT code FROM five_char_mapping UNION ALL SELECT code FROM two_char_mapping)
),
nomesco_mapping AS (
	SELECT code, target_concept_id
	FROM (
	    SELECT * FROM one_char_mapping
	    UNION ALL
	    SELECT * FROM two_char_mapping
	    UNION ALL
	    SELECT * FROM five_char_mapping
	) a
),
kva_mapping AS (
	SELECT code, target_concept_id
    FROM kva
    JOIN etl_mappings.kva AS mapping
        ON code = source_code
),
procedure_mapping AS (
	SELECT * FROM nomesco_mapping
	UNION ALL
	SELECT * FROM kva_mapping
)

SELECT code as source_code, descr.source_description, target_concept_id
INTO etl_mappings.procedures_processed
FROM procedure_mapping
LEFT JOIN etl_mappings.nomesco_kva_description AS descr
    ON procedure_mapping.code = descr.source_code
;
