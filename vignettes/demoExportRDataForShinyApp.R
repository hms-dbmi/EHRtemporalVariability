library(EHRtemporalVariability)

dataset <- read.csv2( "http://github.com/hms-dbmi/EHRtemporalVariability-DataExamples/raw/master/nhdsSubset.csv", 
                      sep  = ",",
                      header = TRUE, 
                      na.strings = "", 
                      colClasses = c( "character", "numeric", "factor",
                                      "numeric" , rep( "factor", 22 ) ) )

datasetFormatted <- EHRtemporalVariability::formatDate(
    input         = dataset,
    dateColumn    = "date",
    dateFormat = "%y/%m"
)

datasetPheWAS <- icd9toPheWAS(data           = datasetFormatted,
                              icd9ColumnName = "diagcode1",
                              phecodeDescription = TRUE,
                              missingValues  = "N/A", 
                              statistics     = TRUE, 
                              replaceColumn  = FALSE)

probMaps <- estimateDataTemporalMap(data           = datasetPheWAS, 
                                    dateColumnName = "date", 
                                    period         = "month")

igtProjs <- sapply ( probMaps, estimateIGTProjection )
names( igtProjs ) <- names( probMaps )

save(probMaps, igtProjs, file = "myExport.RData")
