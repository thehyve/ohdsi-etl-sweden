library(devtools)
install_github("ohdsi/Achilles", ref="v1.2")
library(Achilles)

## Settings for achilles output ##
# Path to folder where Achilles json files will be stored
achillesPath <- "/pathTo/targetFolder/" # Existing folder with trailing slash
dataName  <- "sampleTest" # The name will appear in AchillesWeb. Has to be unique

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

outputPath <- paste(achillesPath, dataName, sep="")
exportToJson(connectionDetails,
             cdmDatabaseSchema="cdm5",
             resultsDatabaseSchema = "webapi",
             outputPath = outputPath,
             cdmVersion = "5")

## Update the datasources file ##
#library(rjson) #included in Achilles
datasourcePath <- paste(achillesPath, "datasources.json", sep="")
# Read the json file or create new if not exists
if ( file.exists(datasourcePath) ){
  j <- fromJSON( file = datasourcePath )
} else {
  j <- fromJSON(json_str='{"datasources":[{"name":"DEFAULT","folder":"DEFAULT","cdmVersion":""}]}')
}
# Add new item to the existing datasources
new_datasource <- list("name"=dataName,"folder"=dataName,"cdmVersion"=5)
j$datasources[[2]] <- new_datasource
# Overwrite existing json file
write(toJSON(j), datasourcePath)
