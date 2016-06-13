/* Populate death table */

INSERT INTO cdm5.death (person_id, death_date, cause_concept_id, cause_source_value, death_type_concept_id)
SELECT lpnr,
       to_date(dodsdat::varchar, 'YYYYMMDD'), -- TODO: handle trailing zeroes (uncertain day/month of death). Now set to first day of the month or year.
       ulorsak_map.target_concept_id,
       ulorsak,
       38003569 -- EHR record patient status "Deceased"

FROM bayer.death

LEFT JOIN mappings.snomed AS ulorsak_map
  ON ulorsak =
     ulorsak_map.source_code

-- WHERE dodsdat::varchar LIKE '%00'
;
