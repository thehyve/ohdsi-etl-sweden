SELECT
    varunr as vnr,
    ingredient_concept_id
INTO drugmap.vnr_to_ingredient
FROM drugmap.unique_varunr
LEFT JOIN drugmap.atc_to_ingredient  a_t_i_d
    ON unique_varunr.atc = a_t_i_d.atc_concept_code
;
