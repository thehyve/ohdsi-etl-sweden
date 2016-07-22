/* Put additional death information in this addendum table.
Records whether death is:
    - Related to Alcohol, Narcotics, Work or Surgical Procedure.
    - Happened abroad
    - Where death occurred
Note that this table allows multiple rows with the same person_id.
*/

CREATE TABLE death_addendum (
    person_id integer, -- Links to OMOP death table.
    alcohol integer,
    narcotic integer,
    work integer,
    abroad integer,
    surgical_procedure integer,
    place_of_service_concept_id integer -- Hospital, Home, rehabilitation clinic, other.
);

INSERT INTO death_addendum
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

    -- Source value 1 = yes, 2 = no, 3/blank are unknown.
    CASE WHEN opererad = 1
         THEN 1
         WHEN opererad = 2
         THEN 0
         ELSE Null
    END AS surgical_procedure,

    -- Place of death. Refers to a place of service id in concept table.
    CASE dodspl
         WHEN 1 THEN 8717
         WHEN 2 THEN 8844
         WHEN 3 THEN 8536
         WHEN 4 THEN 44814649
         ELSE 44814649
    END AS place_of_service_concept_id

FROM etl_input.death
;

CREATE INDEX person_index ON death_addendum (person_id);
