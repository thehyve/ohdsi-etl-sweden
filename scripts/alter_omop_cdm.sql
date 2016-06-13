/*
Assigns auto increment to measurement and observation tables.
Needed to quarentee an unique primary key.
*/

DROP SEQUENCE IF EXISTS measurement_seq CASCADE;
CREATE SEQUENCE measurement_seq;
ALTER TABLE cdm5.measurement ALTER COLUMN measurement_id SET DEFAULT nextval('measurement_seq');

DROP SEQUENCE IF EXISTS observation_seq CASCADE;
CREATE SEQUENCE observation_seq;
ALTER TABLE cdm5.observation ALTER COLUMN observation_id SET DEFAULT nextval('observation_seq');
