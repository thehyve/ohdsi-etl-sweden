/* Saves drugs to the drug_exposure table.
   The drug mapping has to be build before running this script.
*/

INSERT INTO drug_exposure (
    person_id,
    drug_concept_id,
    drug_exposure_start_date,
    drug_exposure_end_date,
    drug_type_concept_id,

    drug_source_value,
    drug_source_concept_id,

    quantity,
    effective_drug_dose,
    dose_unit_concept_id,
    dose_unit_source_value,
    provider_id,
    sig, -- The directions (signetur) of prescription as printed on container

    route_source_value
)
SELECT  lpnr,
        CASE WHEN vnr_mapping.target_concept_id IS NULL
             THEN 0 -- Not mappable
             ELSE vnr_mapping.target_concept_id
        END as drug_concept_id,

        to_date(edatum, 'mm/dd/yyyy') as drug_exposure_start_date,
        getDrugEndDate(edatum, forpstl, antal, 1) as drug_exposure_end_date, -- Hard coded presctiption of 1 per day.

        43542356 as drug_type_concept_id, -- Physician administered drug (identified from EHR problem list)

        /* Combine varunr with drug name. Just 50 characters allowed */
        SUBSTRING( varunr || '|' || drug_source.lnamn FROM 0 FOR 50) as drug_source_value,
        vnr_to_ingredient.atc_concept_id as drug_source_concept_id,

        getDrugQuantity(forpstl, antal) as quantity,
        styrknum,
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

        lformgrupp as route_source_value

FROM etl_input.drug as drug_source

LEFT JOIN etl_mappings.vnr_mapping as vnr_mapping
  ON drug_source.varunr = vnr_mapping.source_concept_id
-- ATC concept_id as source_concept
LEFT JOIN drugmap.vnr_to_ingredient
  ON drug_source.varunr = vnr_to_ingredient.vnr

LEFT JOIN provider
  ON drug_source.spkod1 = provider_id

LEFT JOIN etl_mappings.unit
  ON drug_source.styrka_enh = unit.source_code

WHERE antal > 0 -- Ignore negative antals, administrative issue.
;
