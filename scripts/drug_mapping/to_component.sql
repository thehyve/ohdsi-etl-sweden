/* 9-04-2016
   Map to component, using only ingredient and strength.*/
SELECT
    v_t_i.vnr,
    drug.concept_id AS drug_concept_id,
    drug.concept_class_id

INTO drugmap.vnr_to_component

FROM drugmap.unique_varunr

/* Hook mapping of unit and strength to drugs */
JOIN drugmap.vnr_to_ingredient AS v_t_i
    ON unique_varunr.varunr = v_t_i.vnr

JOIN etl_mappings.unit as unit_map
    ON unique_varunr.styrka_enh = unit_map.source_code

JOIN drugmap.drug_strength_single_ingredient AS drug_strength
    ON drug_strength.ingredient_concept_id = v_t_i.ingredient_concept_id

    AND (
        ( round(drug_strength.amount_value,2) = round(unique_varunr.styrknum,2)
          AND drug_strength.amount_unit_concept_id = unit_map.target_concept_id
        )
    )

/* Add all info of the drug concepts */
JOIN concept drug
    ON drug.concept_id = drug_strength.drug_concept_id

WHERE (drug.concept_class_id LIKE 'Clinical Drug Comp'
       AND drug.vocabulary_id = 'RxNorm' ) -- 20-04-2016: vocabulary DPD also has Clinical drug comp.

;
