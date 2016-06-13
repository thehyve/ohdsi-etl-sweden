CREATE TABLE bayer.death_addendum (
    person_id integer, -- Links to OMOP death table. (one person, one row in death)
    cause_1_concept_id integer,
    cause_2_concept_id integer,
    cause_3_concept_id integer,
    cause_4_concept_id integer,
    cause_5_concept_id integer,
    cause_6_concept_id integer,
    cause_7_concept_id integer,
    cause_8_concept_id integer,
    cause_9_concept_id integer,
    cause_10_concept_id integer,
    alcohol integer, -- 0 or 1
    narcotic integer,
    work integer,
    abroad integer,
    surgical_procedure integer,
    place_of_service_concept_id integer -- Hospital, Home, rehabilitation clinic, other.
);
-- TODO: index on person_id

INSERT INTO bayer.death_addendum
SELECT
    lpnr,
    m1.target_concept_id,
    m2.target_concept_id,
    m3.target_concept_id,
    m4.target_concept_id,
    m5.target_concept_id,
    m6.target_concept_id,
    m7.target_concept_id,
    m8.target_concept_id,
    m9.target_concept_id,
    m10.target_concept_id,

    CASE WHEN alkohol::integer = 1
         THEN 1
         ELSE 0
    END AS alcohol,

    CASE WHEN narkotik = 1
         THEN 1
         ELSE 0
    END AS narcotic,

    CASE WHEN aolycka = 1
         THEN 1
         ELSE 0
    END AS work,

    CASE WHEN dodutl = 1
         THEN 1
         ELSE 0
    END AS abroad,

    --
    CASE WHEN opererad = 1
         THEN 1
         WHEN opererad = 2
         THEN 0
         ELSE Null -- 3 and blank are unknown.
    END AS surgical_procedure,

    -- Place of death. Refers to a place of service id in concept.
    CASE dodspl
         WHEN 1 THEN 8717
         WHEN 2 THEN 8844
         WHEN 3 THEN 8536
         WHEN 4 THEN 44814649
         ELSE 44814649
    END AS place_of_service_concept_id

FROM bayer.death

-- Join icd10 mapping. On first 4 characters only.
LEFT JOIN mappings.snomed AS m1
  ON morsak1 = m1.source_code
LEFT JOIN mappings.snomed AS m2
  ON morsak2 = m2.source_code
LEFT JOIN mappings.snomed AS m3
  ON morsak3 = m3.source_code
LEFT JOIN mappings.snomed AS m4
  ON morsak4 = m4.source_code
LEFT JOIN mappings.snomed AS m5
  ON morsak5 = m5.source_code
LEFT JOIN mappings.snomed AS m6
  ON morsak6 = m6.source_code
LEFT JOIN mappings.snomed AS m7
  ON morsak7 = m7.source_code
LEFT JOIN mappings.snomed AS m8
  ON morsak8 = m8.source_code
LEFT JOIN mappings.snomed AS m9
  ON morsak9 = m9.source_code
LEFT JOIN mappings.snomed AS m10
  ON morsak10 = m10.source_code
-- where lpnr = 162
-- order by lpnr
;
