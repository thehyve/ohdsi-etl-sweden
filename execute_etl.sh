#!/bin/sh
#Note: no space around assignment '=' signs

# Variables
DATABASE_NAME="$1"
USER="$2"
ENCODING="$3"

# Constants
SCRIPTS_FOLDER="scripts"
SOURCE_FOLDER="source_tables"
MAP_SCRIPT_FOLDER="$SCRIPTS_FOLDER/mapping_scripts"
ETL_SCRIPT_FOLDER="$SCRIPTS_FOLDER/loading_scripts"
DYNAMIC_SCRIPT_FOLDER="$SCRIPTS_FOLDER/rendered_sql"
SQL_FUNCTIONS_FOLDER="$SCRIPTS_FOLDER/functionsSQL"

# Check whether command line arguments are given
if [[ $DATABASE_NAME = "" ]] || [[ $USER = "" ]]; then
    echo "Please input a database name and username: "
    echo "./execute_etl.sh <database_name> <user_name>"
    exit 1
fi

if [[ $ENCODING = "" ]]; then
    ENCODING="UTF8"
fi

echo "===== Starting the ETL procedure to OMOP CDM ====="
echo "Using the database '$DATABASE_NAME' and the cdm5 schema."
echo "Loading source files from the folder '$SOURCE_FOLDER' "
echo "Using $ENCODING encoding of the source files."
# echo "TODO: Specify cdm5 schema in addition to database"

echo
echo "Preprocessing patient registers..."
python $SCRIPTS_FOLDER/process_patient_tables_wide_to_long.py $SOURCE_FOLDER
echo
echo "Reading headers of source tables..."
# python $SCRIPTS_FOLDER/process_drug_registries.py $SOURCE_FOLDER/drug_register
python $SCRIPTS_FOLDER/create_copy_sql.py $SOURCE_FOLDER $ENCODING $DYNAMIC_SCRIPT_FOLDER #TODO: change encoding to LATIN1
# TODO: exit from python with error if source files do not exist

echo
# The following is executed quiet (-q)
echo "Truncating cdm5 tables and empty schemas. Drop sequences"
sudo -u $USER psql -d $DATABASE_NAME -f $SCRIPTS_FOLDER/empty_schemas.sql -q
sudo -u $USER psql -d $DATABASE_NAME -f $SCRIPTS_FOLDER/alter_omop_cdm.sql -q

echo
echo "Creating source tables..."
sudo -u $USER psql -d $DATABASE_NAME -f $SCRIPTS_FOLDER/create_source_tables.sql

echo "Loading source tables..."
# sudo -u $USER psql -d $DATABASE_NAME -f $SCRIPTS_FOLDER/load_source_tables.sql
sudo -u $USER psql -d $DATABASE_NAME -f $DYNAMIC_SCRIPT_FOLDER/load_tables.sql
sudo -u $USER psql -d $DATABASE_NAME -f $SCRIPTS_FOLDER/filter_soruce_tables.sql
echo
echo "Creating mapping tables..."
sudo -u $USER psql -d $DATABASE_NAME -f $SCRIPTS_FOLDER/load_mapping_tables.sql
sudo -u $USER psql -d $DATABASE_NAME -f $MAP_SCRIPT_FOLDER/map_atcToRxNorm.sql
# sudo -u $USER psql -d $DATABASE_NAME -f $MAP_SCRIPT_FOLDER/map_icd10_to_snomed.sql

echo
echo "Preprocessing..."
printf "%-35s" "Unique persons from registers: "
sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/lpnr_aggregated.sql
printf "%-35s" "Single Ingredient Drugs.: "
sudo -u $USER psql -d $DATABASE_NAME -f $MAP_SCRIPT_FOLDER/drug_strength_single_ingredient.sql
echo "Create supporting SQL functions:"
sudo -u $USER psql -d $DATABASE_NAME -f $SQL_FUNCTIONS_FOLDER/getObservationStartDate.sql
sudo -u $USER psql -d $DATABASE_NAME -f $SQL_FUNCTIONS_FOLDER/getObservationEndDate.sql

# Actual ETL. Always first Person and Death tables. Other tables rely on that
echo
echo "Performing ETL..."
printf "%-35s" "Person: "
sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/etl_person.sql
printf "%-35s" "Death with addendum table: "
sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/etl_death.sql
# 26-05-2016: disabled death addendum. It is slow.
# sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/etl_death_addendum.sql -q
printf "%-35s" "Observation Period: "
sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/etl_observation_period.sql
printf "%-35s" "Visit Occurrence: "
sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/etl_visit_occurrence.sql

printf "%-35s" "Condition Occurrence: "
sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/etl_condition_occurrence.sql
printf "%-35s" "Procedure Occurrence: "
sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/etl_procedure_occurrence.sql
printf "%-35s" "Drug Exposure: "
sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/etl_drug_exposure.sql

printf "%-35s" "Observation Civil Status: " #Only where civil is not null
sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/etl_observation_civil.sql
printf "%-35s" "Observation Planned visit: " #all
sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/etl_observation_pvard.sql
printf "%-35s" "Observation Utsatt Status: " #Only sluten care
sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/etl_observation_utsatt.sql
printf "%-35s" "Observation Insatt Status: " #Only sluten care
sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/etl_observation_insatt.sql
printf "%-35s" "Observation Ekod: "          #Only where ekod is not null
sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/etl_observation_ekod.sql
printf "%-35s" "Observation Work Status: "       #Only Lisa
sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/etl_observation_work_status.sql
printf "%-35s" "Observation Education level: "   #Only Lisa
sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/etl_observation_education.sql
printf "%-35s" "Observation Ethnic Background: " #Only Lisa
sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/etl_observation_background.sql


printf "%-35s" "Measurement Income: " #Only Lisa
sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/etl_measurement_income.sql
printf "%-35s" "Measurement Age: " #All registers
sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/etl_measurement_age.sql

echo
echo "Postprocessing..."
printf "%-35s" "Condition Era: "
sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/build_condition_era.sql
printf "%-35s" "Drug Era: "
sudo -u $USER psql -d $DATABASE_NAME -f $ETL_SCRIPT_FOLDER/build_drug_era.sql
