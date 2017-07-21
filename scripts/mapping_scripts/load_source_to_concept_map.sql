/* KVA and Nomesco */
INSERT INTO vocabulary VALUES ('KVA-NOMESCO','Klassifikation av vårdåtgärder (KVÅ) including Nordic Medico-Statistical Committee (NOMESCO) Classification of Surgical Procedures','http://www.socialstyrelsen.se/klassificeringochkoder/atgardskoderkva','',0);
\copy source_to_concept_map FROM './mapping_tables/kva-nomesco_source_to_concept_map.csv' WITH HEADER CSV ENCODING 'UTF8'

/* ICD10SE */
INSERT INTO vocabulary VALUES ('ICD10-SE','International Classification of Diseases Swedish Dialect','http://www.socialstyrelsen.se/klassificeringochkoder/diagnoskodericd-10','',0);
\copy source_to_concept_map FROM './mapping_tables/icd10-se_source_to_concept_map.csv' WITH HEADER CSV ENCODING 'UTF8'

/* VaruNummer */
INSERT INTO vocabulary VALUES ('VaruNummer','Swedish Drug Article Numbers','https://npl.mpa.se/','',0);
\copy source_to_concept_map FROM './mapping_tables/varunummer_source_to_concept_map.csv' WITH HEADER CSV ENCODING 'UTF8'

/* Dose Form */
INSERT INTO vocabulary VALUES ('VnrDoseForm','Swedish Dose Form codes','https://npl.mpa.se/','',0);
\copy source_to_concept_map FROM './mapping_tables/vnr-dose-form_source_to_concept_map.csv' WITH HEADER CSV ENCODING 'UTF8'

/* Unit */
INSERT INTO vocabulary VALUES ('unit-se','Swedish Drug Units','https://npl.mpa.se/','',0);
\copy source_to_concept_map FROM './mapping_tables/unit-se_source_to_concept_map.csv' WITH HEADER CSV ENCODING 'UTF8'
