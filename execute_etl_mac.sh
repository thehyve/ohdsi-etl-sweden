#!/bin/sh
#Note: no space around assignment '=' signs

# Variables
DATABASE_NAME="$1"
USER="$2"
ENCODING="$3"
DATABASE_SCHEMA="$4" # Schema of the vocabulary tables
VOCAB_SCHEMA="$5"

# Constants
SCRIPTS_FOLDER="scripts"
SOURCE_FOLDER="source_tables"
MAP_SCRIPT_FOLDER="$SCRIPTS_FOLDER/mapping_scripts"
ETL_SCRIPT_FOLDER="$SCRIPTS_FOLDER/loading_scripts"
DYNAMIC_SCRIPT_FOLDER="$SCRIPTS_FOLDER/rendered_sql"
SQL_FUNCTIONS_FOLDER="$SCRIPTS_FOLDER/sql_functions"
PYTHON_FOLDER="$SCRIPTS_FOLDER/python"
DRUG_MAPPING_FOLDER="$SCRIPTS_FOLDER/drug_mapping"
OMOP_CDM_FOLDER="$SCRIPTS_FOLDER/OMOPCDM"
TIME_FORMAT="Elapsed Time: %e sec"

# Check whether command line arguments are given
if [ "$DATABASE_NAME" = "" ] || [ "$USER" = "" ]; then
    echo "Please input a database name and username of the database. Usage: "
    echo "./execute_etl.sh <database_name> <user_name> [<encoding>] [<database_schema>] [<vocabulary_schema>]"
    exit 1
fi
# Defaults
if [ "$ENCODING" = "" ]; then ENCODING="UTF8"; fi
if [ "$DATABASE_SCHEMA" = "" ]; then SCHEMA="cdm5"; fi
if [ "$VOCAB_SCHEMA" = "" ]; then VOCAB_SCHEMA="cdm5"; fi

date
echo "===== Starting the ETL procedure to OMOP CDM ====="
echo "Using the database '$DATABASE_NAME' and the cdm5 schema."
echo "Loading source files from the folder '$SOURCE_FOLDER' "
echo "Using $ENCODING encoding of the source files."

# Search for tables first in database schema, then in vocabulary schema (and alst in public schema)
# (if schema not specified specifically)
sudo -u $USER psql -d $DATABASE_NAME -c "ALTER DATABASE $DATABASE_NAME SET search_path TO $DATABASE_SCHEMA, $VOCAB_SCHEMA, public;"
# Create cdm5 schema. Assume vocab schema exists and is filled.
sudo -u $USER psql -d $DATABASE_NAME -c "CREATE SCHEMA IF NOT EXISTS $DATABASE_SCHEMA;"

echo
echo "Preprocessing patient registers..."
python $PYTHON_FOLDER/process_patient_tables_wide_to_long.py $SOURCE_FOLDER
python $PYTHON_FOLDER/process_death_tables_wide_to_long.py $SOURCE_FOLDER
echo
echo "Reading headers of source tables..."
# python $SCRIPTS_FOLDER/process_drug_registries.py $SOURCE_FOLDER/drug_register
python $SCRIPTS_FOLDER/create_copy_sql.py $SOURCE_FOLDER $ENCODING $DYNAMIC_SCRIPT_FOLDER

echo
# The following is executed quietly (-q)
echo "Dropping cdm5 tables and empty schemas..."
sudo -u $USER psql -d $DATABASE_NAME -f $SCRIPTS_FOLDER/empty_schemas.sql -q
sudo -u $USER psql -d $DATABASE_NAME -f $SCRIPTS_FOLDER/drop_cdm_tables.sql -q
sudo -u $USER psql -d $DATABASE_NAME -f "$OMOP_CDM_FOLDER/OMOP CDM ddl.sql" -q
echo "Creating sequences..."
sudo -u $USER psql -d $DATABASE_NAME -f $SCRIPTS_FOLDER/alter_omop_cdm.sql -q

echo
echo "Creating source tables..."
sudo -u $USER psql -d $DATABASE_NAME -f $SCRIPTS_FOLDER/create_source_tables.sql

echo "Loading source tables..."
# sudo -u $USER psql -d $DATABASE_NAME -f $SCRIPTS_FOLDER/load_source_tables.sql
time sudo -u $USER psql -d $DATABASE_NAME -f $DYNAMIC_SCRIPT_FOLDER/load_tables.sql
echo "Filtering rows without date..."
time sudo -u $USER psql -d $DATABASE_NAME -f $SCRIPTS_FOLDER/filter_source_tables.sql
echo "Creating indices source tables..."
time sudo -u $USER psql -d $DATABASE_NAME -f $SCRIPTS_FOLDER/alter_source_tables.sql

echo
echo "Creating mapping tables..."
sudo -u $USER psql -d $DATABASE_NAME -f $MAP_SCRIPT_FOLDER/load_mapping_tables.sql
sudo -u $USER psql -d $DATABASE_NAME -f $MAP_SCRIPT_FOLDER/process_nomesco_mapping.sql
time sh execute_drug_mapping.sh $DATABASE_NAME $USER $DRUG_MAPPING_FOLDER
# time sudo -u $USER psql -d $DATABASE_NAME -f $MAP_SCRIPT_FOLDER/map_icd10_to_snomed.sql

echo
echo "Preprocessing..."
printf "%-35s" "Unique persons from registers: "
time sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/lpnr_aggregated.sql
echo "Create supporting SQL functions:"
sudo -u $USER psql -d $DATABASE_NAME -f $SQL_FUNCTIONS_FOLDER/getObservationStartDate.sql
sudo -u $USER psql -d $DATABASE_NAME -f $SQL_FUNCTIONS_FOLDER/getObservationEndDate.sql
sudo -u $USER psql -d $DATABASE_NAME -f $SQL_FUNCTIONS_FOLDER/convertDeathDate.sql
sudo -u $USER psql -d $DATABASE_NAME -f $SQL_FUNCTIONS_FOLDER/getDrugQuantity.sql

# Actual ETL. Always first Person and Death tables. Other tables rely on that
echo
echo "Performing ETL..."
printf "%-35s" "Person: "
time sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/etl_person.sql
printf "%-35s" "Death with addendum table: "
time sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/etl_death.sql
time sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/etl_death_addendum.sql -q
printf "%-35s" "Observation Period: "
time sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/etl_observation_period.sql
printf "%-35s" "Visit Occurrence: "
time sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/etl_visit_occurrence.sql

printf "%-35s" "Condition Occurrence: "
time sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/etl_condition_occurrence.sql
printf "%-35s" "Procedure Occurrence: "
time sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/etl_procedure_occurrence.sql
printf "%-35s" "Drug Exposure: "
time sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/etl_drug_exposure.sql

printf "%-35s" "Observation Death Morsak: " #Additional causes of death
time sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/etl_observation_death.sql
printf "%-35s" "Observation Civil Status: " #Only where civil is not null
time sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/etl_observation_civil.sql
printf "%-35s" "Observation Planned visit: " #all
time sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/etl_observation_pvard.sql
printf "%-35s" "Observation Utsatt Status: " #Only sluten care
time sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/etl_observation_utsatt.sql
printf "%-35s" "Observation Insatt Status: " #Only sluten care
time sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/etl_observation_insatt.sql
printf "%-35s" "Observation Ekod: "          #Only where ekod is not null
time sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/etl_observation_ekod.sql
printf "%-35s" "Observation Work Status: "       #Only Lisa
time sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/etl_observation_work_status.sql
printf "%-35s" "Observation Education level: "   #Only Lisa
time sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/etl_observation_education.sql
printf "%-35s" "Observation Ethnic Background: " #Only Lisa
time sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/etl_observation_background.sql


printf "%-35s" "Measurement Income: " #Only Lisa
time sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/etl_measurement_income.sql
printf "%-35s" "Measurement Age: " #All registers
time sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/etl_measurement_age.sql

echo
echo "Building Eras..."
printf "%-35s" "Condition Era: "
time sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/build_condition_era.sql
printf "%-35s" "Drug Era: "
time sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/build_drug_era.sql

echo
echo "Adding constraints..."
time sudo -u $USER psql -d $DATABASE_NAME -f "$OMOP_CDM_FOLDER/OMOP CDM constraints.sql" -q
echo "Adding indices..."
time sudo -u $USER psql -d $DATABASE_NAME -f "$OMOP_CDM_FOLDER/OMOP CDM indexes required.sql" -q

# Restore search path
sudo -u $USER psql -d $DATABASE_NAME -c "ALTER DATABASE $DATABASE_NAME SET search_path TO \"\$user\", public;"
date
