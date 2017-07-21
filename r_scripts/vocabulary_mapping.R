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

condition.stats <- vocabularyMapping(connectionDetails, "condition_occurrence", "ICD10-SE")
condition.topUnmapped <- topUnmapped(connectionDetails, "condition_occurrence", "ICD10-SE",10)
condition.topMapped <- topMapped(connectionDetails, "condition_occurrence", "ICD10-SE",10)
View(condition.stats)
View(condition.topUnmapped)
View(condition.topMapped)

drug.stats <- vocabularyMapping(connectionDetails, "drug_exposure", "VaruNummer")
drug.topUnmapped <- topUnmapped(connectionDetails, "drug_exposure", "VaruNummer",10)
drug.topMapped <- topMapped(connectionDetails, "drug_exposure", "VaruNummer",10)
View(drug.stats)
View(drug.topUnmapped)
View(drug.topMapped)

procedure.stats <- procedure_occurrence <- vocabularyMapping(connectionDetails, "procedure_occurrence", "KVA-NOMESCO")
procedure.topUnmapped <- topUnmapped(connectionDetails, "procedure_occurrence", "KVA-NOMESCO",10)
procedure.topMapped <- topMapped(connectionDetails, "procedure_occurrence", "KVA-NOMESCO",10)
View(procedure.stats)
View(procedure.topUnmapped)
View(procedure.topMapped)

#write a table to csv:
write.csv(condition.stats, '~/Documents/condition_mapping_stats.csv')
