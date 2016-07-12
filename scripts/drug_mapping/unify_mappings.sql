/* Combine four mappings (in this order):
    - Clinical drug
    - Clinical Drug Component
    - Clinical Drug Form
    - Ingredient
    - Everything that is not mapped
*/
SELECT  vnr as source_concept_id,
        lnamn,
        frequency,
        concept_id as target_concept_id,
        concept_name,
        U.concept_class_id
INTO mappings.vnr_mapping -- Note: final mapping stored in mappings schema
FROM (
    SELECT *
    FROM drugmap.vnr_to_clinical_drug

    UNION ALL

        SELECT *
        FROM drugmap.vnr_to_component
        WHERE vnr NOT IN (SELECT vnr FROM drugmap.vnr_to_clinical_drug )

    UNION ALL

        SELECT *
        FROM drugmap.vnr_to_drug_form
        WHERE vnr NOT IN (SELECT vnr FROM drugmap.vnr_to_clinical_drug
                    UNION SELECT vnr FROM drugmap.vnr_to_component)

    UNION ALL

        SELECT vnr_to_ingredient.vnr,
               ingredient_concept_id,
               CASE WHEN ingredient_concept_id IS NULL
                    THEN 'Not Mapped*'
                    ELSE 'Ingredient'
               END as concept_class_id
        FROM drugmap.vnr_to_ingredient
        WHERE vnr NOT IN (
                          SELECT vnr FROM drugmap.vnr_to_clinical_drug
                    UNION SELECT vnr FROM drugmap.vnr_to_component
                    UNION SELECT vnr FROM drugmap.vnr_to_drug_form)

) U
RIGHT JOIN drugmap.unique_varunr
  ON unique_varunr.varunr = U.vnr
LEFT JOIN cdm5.concept
  ON U.drug_concept_id = concept_id
ORDER BY vnr
-- GROUP BY concept_class_id
;

CREATE INDEX source_concept_index ON mappings.vnr_mapping (source_concept_id);
