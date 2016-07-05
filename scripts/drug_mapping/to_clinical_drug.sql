/* 05-04-2016
   Mapping to clinical drug. Excluding anything that is not mapped.*/
SELECT
    v_t_i.vnr,
    drug.concept_id AS drug_concept_id,
    drug.concept_class_id

INTO drugmap.vnr_to_clinical_drug

FROM drugmap.unique_varunr

/* Hook mapping of unit and strength to drugs */
LEFT JOIN drugmap.vnr_to_ingredient AS v_t_i
    ON unique_varunr.varunr = v_t_i.vnr

LEFT JOIN mappings.dose_form as map_dose_form
    ON unique_varunr.styrka_tf = map_dose_form.source_code

LEFT JOIN mappings.unit as unit_map
    ON unique_varunr.styrka_enh = unit_map.source_code

LEFT JOIN drugmap.drug_strength_single_ingredient AS drug_strength
    ON drug_strength.ingredient_concept_id = v_t_i.ingredient_concept_id

    AND (
        ( round(drug_strength.amount_value,2) = round(unique_varunr.styrknum,2)
          AND drug_strength.amount_unit_concept_id = unit_map.target_concept_id
        )
        -- 05-07-2016: ignore denominator for the Bayer drugs
        -- OR
        -- ( round(drug_strength.numerator_value,2) =
        --   round(unique_varunr.styrknum,2)
        --     AND drug_strength.numerator_unit_concept_id  = auh.map_unit.num_unit_concept_id
        --     AND drug_strength.denominator_unit_concept_id = auh.map_unit.denom_unit_concept_id
        -- )
    )

/* Add all info of the drug concepts */
LEFT JOIN cdm5.concept drug
    ON drug.concept_id = drug_strength.drug_concept_id

/* Add dose form concept_id to drug_concept_id*/
LEFT JOIN cdm5.concept_relationship AS relation_form
    ON drug.concept_id = relation_form.concept_id_1
    AND relation_form.relationship_id = 'RxNorm has dose form' -- Only dose form relations

LEFT JOIN cdm5.concept dose_form_concept
    ON relation_form.concept_id_2 = dose_form_concept.concept_id

WHERE (drug.concept_class_id LIKE 'Clinical%' OR drug.concept_class_id IS Null) -- Filter out o.a. branded
     -- Select correct dose form.
     AND map_dose_form.target_concept_id = dose_form_concept.concept_id
     AND drug.vocabulary_id = 'RxNorm'  -- 20-04-2016

ORDER BY v_t_i.vnr, drug.concept_class_id, drug.concept_name
;
