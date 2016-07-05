/* 9-04-2016
   Mapping to clinical form */
SELECT
    v_t_i.vnr,
    drug.concept_id AS drug_concept_id,
    drug.concept_class_id

INTO drugmap.vnr_to_drug_form

FROM drugmap.unique_varunr

/* Hook mapping of ingredient, dose form,  to drugs */
LEFT JOIN drugmap.vnr_to_ingredient AS v_t_i
    ON unique_varunr.varunr = v_t_i.vnr

LEFT JOIN mappings.dose_form as map_dose_form
    ON unique_varunr.styrka_tf = map_dose_form.source_code

/* Search all drugs which have this ingredient */
LEFT JOIN cdm5.concept_relationship AS relation_ing
    ON relation_ing.concept_id_1 = v_t_i.ingredient_concept_id
    AND relation_ing.relationship_id = 'RxNorm ing of' -- Only dose form relations

LEFT JOIN cdm5.concept drug
    ON drug.concept_id = relation_ing.concept_id_2

/* Add dose form concept_id to drug_concept_id*/
LEFT JOIN cdm5.concept_relationship AS relation_form
    ON drug.concept_id = relation_form.concept_id_1
    AND relation_form.relationship_id = 'RxNorm has dose form' -- Only dose form relations

LEFT JOIN cdm5.concept dose_form_concept
    ON relation_form.concept_id_2 = dose_form_concept.concept_id

WHERE (drug.concept_class_id LIKE 'Clinical Drug Form') -- Filter out o.a. branded
     -- Select correct dose form.
     AND map_dose_form.target_concept_id = dose_form_concept.concept_id
     AND drug.vocabulary_id = 'RxNorm'  -- 20-04-2016

ORDER BY v_t_i.vnr, drug.concept_class_id, drug.concept_name
-- LIMIT 50
;
