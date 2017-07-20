library(devtools)
install_github("thehyve/Achilles", ref="vocab_mapping")
library(Achilles)

## Database connection details ##
connectionDetails <- createConnectionDetails(dbms="postgresql",
                                             server="localhost/ohdsi2",
                                             user="postgres",
                                             password="",
                                             port=5432,
                                             schema="cdm5")

condition.stats <- vocabularyMapping(connectionDetails, "condition_occurrence", "ICD10-SE")
condition.unmapped <- topUnmapped(connectionDetails, "condition_occurrence", "ICD10-SE",10)
condition.mapped <- topMapped(connectionDetails, "condition_occurrence", "ICD10-SE",10)
View(condition.stats)
View(condition.unmapped)
View(condition.mapped)

drug.stats <- vocabularyMapping(connectionDetails, "drug_exposure", "VaruNummer")
drug.unmapped <- topUnmapped(connectionDetails, "drug_exposure", "VaruNummer",10)
drug.mapped <- topMapped(connectionDetails, "drug_exposure", "VaruNummer",10)
View(drug.stats)
View(drug.unmapped)
View(drug.mapped)

procedure.stats <- procedure_occurrence <- vocabularyMapping(connectionDetails, "procedure_occurrence", "NOMESCO")
procedure.unmapped <- topUnmapped(connectionDetails, "procedure_occurrence", "NOMESCO",10)
procedure.mapped <- topMapped(connectionDetails, "procedure_occurrence", "NOMESCO",10)
View(procedure.stats)
View(procedure.unmapped)
View(procedure.mapped)