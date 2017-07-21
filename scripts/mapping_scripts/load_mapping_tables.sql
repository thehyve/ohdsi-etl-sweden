-- Load tables directly into cdm
\copy location (location_id, county) FROM './resources/lan_locations.csv' WITH HEADER CSV
\copy care_site ( care_site_id, care_site_source_value, care_site_name, location_id ) FROM './resources/sjukhus_care_site.csv' WITH HEADER CSV;
\copy provider (provider_id, provider_name, specialty_concept_id, specialty_source_value) FROM './mapping_tables/spkod_specialty.csv' WITH HEADER CSV

-- Set location_source_value to be the same as the location_id
UPDATE location
SET location_source_value = location_id
;
