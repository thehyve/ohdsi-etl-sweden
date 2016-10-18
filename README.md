# ETL for Swedish EHR

Setup OMOP CDM database like this:
```CREATE DATABASE ohdsi;```
```CREATE SCHEMA cdm5;```

Get this OMOP CDM release: https://github.com/OHDSI/CommonDataModel/tree/fa61c2ba7e7eac4c063f1741ec9b7ef554d0ad4f/PostgreSQL

```
SET search_path TO cdm5,public; -- Note: by default this is set to "$user",public
-- Create table (with the old \_cost tables)
\i './CommonDataModel/PostgreSQL/OMOP CDM ddl - PostgreSQL.sql'
-- Load vocabulary (modify to path)
\i './CommonDataModel/PostgreSQL/VocabImport/OMOP CDM vocabulary load - PostgreSQL.sql'
-- Apply constraints and indices
\i './CommonDataModel/PostgreSQL/OMOP CDM constraints - PostgreSQL.sql'
\i './CommonDataModel/PostgreSQL/OMOP CDM indexes required - PostgreSQL.sql'
```

## Add source data
 - Open the ``` source_tables ``` folder
 - Put the patient, drug, death and lisa registers (csv files) in the corresponding subfolders
 - Make sure the filenames correspond with files in the ```overview_source_files.csv``` file (except for drug registers)

## Execute scripts
 - Navigate to the folder (cd ohdsi-etl-sweden)
 - Open bash and execute
 ``` sh ./execute_etl.sh <database_name> <user_name> <encoding>```
 - Prepared execute script with database = 'ohdsi', user = 'postgres' and encoding = 'LATIN1'. Also logs the output to log.txt
 ``` sh ./execute_log_etl.sh ```

 ## Licence
 Published under Apache 2.0 licence.

<!-- ## Order of scripts executed
 - Execute the python script
 ```python process_patient_tables_wide_to_long.py```
 ```python process_drug_registries.py ./source_tables/drug_register```
 - Execute the following queries with
 ```psql -d ohdsi -f load_source_tables.sql```

Create and load source tables (present in folder source_tables)
 - create_source_tables.sql
 - load_mapping_tables.sql
 - load_source_tables.sql
 - mapping_tables/map_atcToRxNorm.sql
 - mapping_tables/map_icd10_to_snomed.sql

Execute the ETL scripts in this order (in the ```etl_script``` folder):
- unique_persons_from_registries.sql
- etl_person.sql
- etl_death.sql
- etl_death_addendum.sql
- etl_observation_period.sql
- etl_visit_occurrence.sql
- etl_condition_occurrence.sql
- etl_drug_exposure.sql
- etl_procedure_occurrence.sql -->
