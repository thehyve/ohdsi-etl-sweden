library(devtools)
install_github("thehyve/Achilles", ref="vocab_mapping")
library(Achilles)

## Database connection details ##
connectionDetails <- createConnectionDetails(dbms="postgresql",
                                             server="localhost/ohdsi",
                                             user="postgres",
                                             password="",
                                             port=5433,
                                             schema="cdm5")

study_id <- 1
drug_path <- txpath_get_drug_paths(connectionDetails, study_id)
View(drug_path)
write.csv(drug_path, "~/Documents/drug_path.csv")

#drug_groups <- txpath_get_drugs(connectionDetails, study_id)
#View(drug_groups)
