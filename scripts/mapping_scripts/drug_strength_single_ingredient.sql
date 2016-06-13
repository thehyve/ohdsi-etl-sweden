/* Preprocesses the drug_strength table to get all drugs with one ingredient */

SELECT drug_strength.*
INTO mappings.drug_strength_single_ingredient
FROM (
    SELECT drug_concept_id
    FROM cdm5.drug_strength
    GROUP BY drug_concept_id
    HAVING COUNT(*) = 1
) temp
LEFT JOIN cdm5.drug_strength
    ON drug_strength.drug_concept_id = temp.drug_concept_id
;
