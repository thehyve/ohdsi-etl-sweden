WITH unique_procedures as (
    SELECT code
    FROM (
        SELECT code, code_type
        FROM bayer.patient_sluten_long

        UNION ALL

        SELECT code, code_type
        FROM bayer.patient_oppen_long

        UNION ALL

        SELECT code, code_type
        FROM bayer.patient_dag_kiru_long
    ) patient_reg
    WHERE code_type like 'op%' AND code ~ '[a-zA-Z][a-zA-Z][a-zA-Z]'
    GROUP BY code
),
five_char_mapping as (
    SELECT code, nomesco.target_concept_id
    FROM unique_procedures
    JOIN mappings.nomesco
        ON code = nomesco.source_code
),
two_char_mapping as (
    SELECT code, nomesco.target_concept_id
    FROM unique_procedures
    JOIN mappings.nomesco
        ON SUBSTRING(code FROM 1 FOR 2) = nomesco.source_code
    WHERE code NOT IN (SELECT code FROM five_char_mapping)
),
one_char_mapping as (
    SELECT code, nomesco.target_concept_id
    FROM unique_procedures
    JOIN mappings.nomesco
        ON SUBSTRING(code FROM 1 FOR 1) = nomesco.source_code
    WHERE code NOT IN (SELECT code FROM five_char_mapping UNION ALL SELECT code FROM two_char_mapping)
)

SELECT code as source_code, target_concept_id
INTO mappings.nomesco_processed
FROM (
    SELECT * FROM one_char_mapping
    UNION ALL
    SELECT * FROM two_char_mapping
    UNION ALL
    SELECT * FROM five_char_mapping
) a
;
