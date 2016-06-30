CREATE TABLE bayer.death_addendum (
    person_id integer, -- Links to OMOP death table. (one person, one row in death)
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
;
