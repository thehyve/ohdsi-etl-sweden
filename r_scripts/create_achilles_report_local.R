library(devtools)
install_github("ohdsi/Achilles")
library(Achilles)

## Settings for achilles output ##
# Path to folder where Achilles json files will be stored
achillesPath <- "/Users/Maxim/Desktop/" # Existing folder with trailing slash
dataName  <- "sampleTest" # The name will appear in AchillesWeb. Has to be unique

## Database connection details ##
connectionDetails <- createConnectionDetails(dbms="postgresql",
                                             server="localhost/new_cdm",
                                             user="postgres",
                                             password="",
                                             port=5432,
                                             schema="synpuf5")

achillesResults <- achilles(connectionDetails,
                            cdmDatabaseSchema="synpuf5",
                            resultsDatabaseSchema = "synpuf5",
                            cdmVersion = "5",
                            smallcellcount = 1,
                            runHeel = TRUE,
                            validateSchema = FALSE)

# Give the WebApi all access rights to the new tables created by the previous function.
# Needed for Record Counts in Atlas.
DatabaseConnector::executeSql(connect(connectionDetails), "GRANT SELECT ON ALL TABLES IN SCHEMA webapi TO webapi;")

outputPath <- paste(achillesPath, dataName, sep="")
exportToJson(connectionDetails,
             cdmDatabaseSchema="synpuf5",
             resultsDatabaseSchema = "synpuf5",
             outputPath = outputPath,
             cdmVersion = "5")

## Update the datasources file ##
addDatasource(outputPath, dataName)
