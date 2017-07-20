/* Saves drugs to the drug_exposure table.
   The drug mapping has to be build before running this script.
*/

INSERT INTO drug_exposure (
    person_id,
    drug_concept_id,
    drug_exposure_start_date,
    days_supply,
    drug_type_concept_id,
    drug_source_value,
    quantity,
    effective_drug_dose,
    dose_unit_concept_id,
    dose_unit_source_value,
    provider_id,
    sig,
    route_source_value
)
SELECT  lpnr as person_id,

        CASE WHEN drug_mapping.target_concept_id IS NULL
             THEN 0 -- Not mappable
             ELSE drug_mapping.target_concept_id
        END as drug_concept_id,

        to_date(edatum, 'mm/dd/yyyy') as drug_exposure_start_date,

        getDrugDaysSupply(forpstl, antal, 1) as days_supply, -- Hard coded prescription of 1 per day.

        43542356 as drug_type_concept_id, -- Physician administered drug (identified from EHR problem list)

        /* Combine varunr with drug name. Just 50 characters allowed */
        TRIM(leading '0' from drug_source.varunr) as drug_source_value,

        getDrugQuantity(forpstl, antal) as quantity,

        styrknum as effective_drug_dose,

        CASE WHEN unit.target_concept_id IS NOT NULL
             THEN unit.target_concept_id
             ELSE 0
        END as dose_unit_concept_id,

        styrka_enh as dose_unit_source_value,

        -- Check whether provider is found. If not, refer to id 99999 (other)
        CASE WHEN provider_id IS NULL
             THEN 99999
             ELSE spkod1  --ignore spkod2,3 and utfkat
        END as provider_id,

        doser as sig, -- The directions (signetur) of prescription as printed on container

        lformgrupp as route_source_value

FROM etl_input.drug as drug_source
LEFT JOIN source_to_concept_map as drug_mapping
  ON drug_mapping.source_vocabulary_id = 'VaruNummer'
  AND TRIM(leading '0' from drug_source.varunr) = drug_mapping.source_code
LEFT JOIN provider
  ON drug_source.spkod1 = provider_id
LEFT JOIN etl_mappings.unit
  ON drug_source.styrka_enh = unit.source_code
WHERE antal > 0 -- Ignore negative antals, administrative issue.
;
