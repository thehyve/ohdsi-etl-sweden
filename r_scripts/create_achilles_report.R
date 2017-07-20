library(devtools)
install_github("thehyve/Achilles", ref="master")
library(Achilles)

## Settings for achilles output ##
# Path to folder where Achilles json files will be stored
ACHILLES_DATA_PATH <- "path/to/etl_vm/achilles_data"
DATA_NAME  <- "sample1" # The name will appear in AchillesWeb. Has to be unique

## Database connection details ##
connectionDetails <- createConnectionDetails(dbms="postgresql",
                                             server="localhost/ohdsi",
                                             user="postgres",
                                             password="",
                                             port=5433,
                                             schema="cdm5")

achillesResults <- achilles(connectionDetails,
                            cdmDatabaseSchema="cdm5",
                            resultsDatabaseSchema = "webapi",
                            cdmVersion = "5",
                            smallcellcount = 5,
                            runHeel = TRUE,
                            validateSchema = FALSE)

# Give the WebApi all access rights to the new tables created by the previous function.
# Needed for Record Counts in Atlas.
DatabaseConnector::executeSql(connect(connectionDetails), "GRANT SELECT ON ALL TABLES IN SCHEMA webapi TO webapi;")

outputPath <- paste(ACHILLES_DATA_PATH, DATA_NAME, sep="/")
exportToJson(connectionDetails,
             cdmDatabaseSchema="cdm5",
             resultsDatabaseSchema = "webapi",
             outputPath = outputPath,
             cdmVersion = "5")

# Update the datasources file #
Achilles::addDatasource(outputPath, DATA_NAME)
