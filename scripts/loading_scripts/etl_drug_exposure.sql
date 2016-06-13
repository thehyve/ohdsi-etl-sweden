/* TODO: advanced drug mapping, with beredningsform, styrknum, styrka_enh, styrka_tf.
*/

INSERT INTO cdm5.drug_exposure (
    drug_exposure_id,
    person_id,
    drug_concept_id,
    drug_exposure_start_date,
    drug_type_concept_id,

    drug_source_value,
    quantity,
    dose_unit_concept_id,
    dose_unit_source_value,
    provider_id,
    sig, -- The directions (signetur) of prescription as printed on container
    -- route_concept_id,
    route_source_value
)
SELECT  row_number() OVER (ORDER BY lpnr),
        lpnr,
        CASE WHEN ingredient_concept_id IS NULL
             THEN 0 -- Not mappable
             ELSE ingredient_concept_id
        END as drug_concept_id,
        to_date(edatum, 'mm/dd/yyyy') as drug_exposure_start_date,
        43542356 as drug_type_concept_id, -- Physician administered drug (identified from EHR problem list)

        SUBSTRING( atc || ' ' || lnamn FROM 0 FOR 50) as drug_source_value, -- Just 50 characters allowed
        quantity, -- TODO: combine with forpstl for actual number of dispensed.

        CASE WHEN unit.target_concept_id IS NOT NULL
             THEN unit.target_concept_id
             ELSE 0
        END as dose_unit_concept_id,
        styrka_enh,

        -- Check whether provider is found. If not, refer to id 99999 (other)
        CASE WHEN provider_id IS NULL
             THEN 99999
             ELSE spkod1  --ignore spkod2,3 and utfkat
        END as provider_id,
        doser as sig, -- The directions (signetur) of prescription as printed on container

        -- lformgrupp as route_concept_id, --TODO: route mapping
        lformgrupp as route_source_value

FROM bayer.drug

LEFT JOIN mappings.atc_to_ingredient
  ON atc_concept_code = atc

LEFT JOIN cdm5.provider
  ON provider_id = spkod1

LEFT JOIN mappings.unit
  ON styrka_enh = unit.source_code

WHERE antal > 0 -- Ignore negative antals, administrative issue.
;
