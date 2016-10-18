#!/bin/sh
# Created by Maxim Moinat.
# Copyright (c) 2016 The Hyve B.V.
# This code is licensed under the Apache License version 2.0

# Variables
DATABASE_NAME="$1"
USER="$2"
DRUG_MAPPING_FOLDER="$3"

# Check whether command line arguments are given
if [ "$DATABASE_NAME" = "" ] || [ "$USER" = "" ]; then
    echo "Please input a database name and username: "
    echo "./execute_drug_mapping.sh <database_name> <user_name>"
    exit 1
fi

if [ "$DRUG_MAPPING_FOLDER" = "" ]; then
    DRUG_MAPPING_FOLDER="scripts/drug_mapping"
fi

echo
echo "===== Starting the drug mapping procedure ====="
echo "Create temporary drug mapping schema"
sudo -u $USER psql -d $DATABASE_NAME -c "DROP SCHEMA drugmap CASCADE;"
sudo -u $USER psql -d $DATABASE_NAME -c "CREATE SCHEMA drugmap;"

echo
echo "Create unique drugs, atc mapping and single ingredient strengths"
sudo -u $USER psql -d $DATABASE_NAME -f $DRUG_MAPPING_FOLDER/unique_varunr.sql
sudo -u $USER psql -d $DATABASE_NAME -f $DRUG_MAPPING_FOLDER/atcToRxNorm.sql
sudo -u $USER psql -d $DATABASE_NAME -f $DRUG_MAPPING_FOLDER/single_ingredient_drugs.sql
sudo -u $USER psql -d $DATABASE_NAME -f $DRUG_MAPPING_FOLDER/drug_strength_single_ingredient.sql

echo
echo "Performing mapping..."
printf "%-35s" "Ingredient level: "
sudo -u $USER psql -d $DATABASE_NAME -f $DRUG_MAPPING_FOLDER/to_ingredient.sql
printf "%-35s" "Drug Form level: "
sudo -u $USER psql -d $DATABASE_NAME -f $DRUG_MAPPING_FOLDER/to_drug_form.sql
printf "%-35s" "Drug Component level: "
sudo -u $USER psql -d $DATABASE_NAME -f $DRUG_MAPPING_FOLDER/to_component.sql
printf "%-35s" "Clinical Drug level: "
sudo -u $USER psql -d $DATABASE_NAME -f $DRUG_MAPPING_FOLDER/to_clinical_drug.sql
printf "%-35s" "Combine the four mappings: "
sudo -u $USER psql -d $DATABASE_NAME -f $DRUG_MAPPING_FOLDER/unify_mappings.sql

echo
echo "Drug Mapping Statistics:"
sudo -u $USER psql -d $DATABASE_NAME -f $DRUG_MAPPING_FOLDER/stats_drug_mapping.sql
