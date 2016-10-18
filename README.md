# ETL for Swedish Electronic Health Records

## Prerequisites
 - PostgreSQL and psql
 - Python 3
 - OMOP tables configured (see below)

Setup OMOP CDM database like this:
```CREATE DATABASE ohdsi;```
```CREATE SCHEMA cdm5;```

Get this OMOP CDM V5 release: https://github.com/OHDSI/CommonDataModel/tree/d4a4d175fdf90c7d5effeafd5eae0e4b035b6137/PostgreSQL

Download the latest OMOP vocabulary from http://athena.ohdsi.org/.

Then open psql in the commandline and execute the following:
- ``` SET search_path TO cdm5,public; ```
- ``` \i './CommonDataModel/PostgreSQL/OMOP CDM ddl - PostgreSQL.sql’ ```
- ``` \i './CommonDataModel/PostgreSQL/VocabImport/OMOP CDM vocabulary load - PostgreSQL.sql' ```

## Add source data
 - Open the ``` source_tables ``` folder
 - Put the patient, drug, death and lisa registers (csv files) in the corresponding subfolders
 - Make sure the filenames correspond with files in the ```overview_source_files.csv``` file (except for the drug registers)

## Execute scripts
 - Navigate to the folder
 - Open bash and execute
 ``` sh ./execute_etl.sh <database_name> <user_name> <encoding>```

## Licence
Published under Apache 2.0 licence.

