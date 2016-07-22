/* 9-04-2016
   Mapping to clinical form */
SELECT
    v_t_i.vnr,
    drug.concept_id AS drug_concept_id,
    drug.concept_class_id

INTO drugmap.vnr_to_drug_form

FROM drugmap.unique_varunr

/* Hook mapping of ingredient and dose form  to drugs */
JOIN drugmap.vnr_to_ingredient AS v_t_i
    ON unique_varunr.varunr = v_t_i.vnr

JOIN mappings.dose_form as map_dose_form
    ON unique_varunr.styrka_tf = map_dose_form.source_code

-- /* Search all drugs which have this ingredient */
JOIN concept_relationship AS relation_ing
    ON relation_ing.concept_id_1 = v_t_i.ingredient_concept_id
    AND relation_ing.relationship_id = 'RxNorm ing of'
    AND relation_ing.invalid_reason IS NULL

JOIN concept drug
    ON drug.concept_id = relation_ing.concept_id_2

-- Filter out any with multiple ingredient
JOIN drugmap.single_ingredient_drugs as single_ing
    ON single_ing.concept_id = drug.concept_id

-- Add dose form concept_id to drug_concept_id
JOIN concept_relationship AS relation_dose_form
    ON drug.concept_id = relation_dose_form.concept_id_1
    AND relation_dose_form.relationship_id = 'RxNorm has dose form' -- Only dose form relations
    AND relation_dose_form.invalid_reason IS NULL
-- LEFT JOIN concept dose_form_concept
--     ON relation_form.concept_id_2 = dose_form_concept.concept_id
--
WHERE (drug.concept_class_id LIKE 'Clinical Drug Form') -- Filter out o.a. branded and Drug Component
--      -- Select correct dose form.
     AND map_dose_form.target_concept_id = relation_dose_form.concept_id_2
     AND drug.vocabulary_id = 'RxNorm'  -- 20-04-2016

-- ORDER BY v_t_i.vnr, drug.concept_class_id, drug.concept_name
-- LIMIT 50
;
