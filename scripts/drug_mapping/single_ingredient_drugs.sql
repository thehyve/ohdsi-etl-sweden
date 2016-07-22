SELECT drug.concept_id
INTO drugmap.single_ingredient_drugs
FROM concept AS drug
LEFT JOIN concept_relationship AS relation_ing
    ON relation_ing.concept_id_1 = drug.concept_id
    AND relation_ing.relationship_id = 'RxNorm has ing'
WHERE drug.vocabulary_id = 'RxNorm'
GROUP BY drug.concept_id
HAVING count(*) = 1
;

ALTER TABLE drugmap.single_ingredient_drugs ADD PRIMARY KEY (concept_id);
