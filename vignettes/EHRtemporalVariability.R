## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = TRUE, warning=FALSE)

## ----cran, message=FALSE, eval=FALSE, warning=FALSE---------------------------
#  install.packages("EHRtemporalVariability")
#  library(EHRtemporalVariability)

## ----crantrue, echo=FALSE, message=FALSE, eval=TRUE, warning=FALSE------------
library(EHRtemporalVariability)

## ----devtls, message=FALSE, eval=FALSE, warning=FALSE-------------------------
#  install.packages("devtools")
#  library(devtools)

## ----bioC, message=FALSE, eval=FALSE, warning=FALSE---------------------------
#  install_github("hms-dbmi/EHRtemporalVariability")
#  library( EHRtemporalVariability )

## ----EHRtemporalVariabilityObj1, echo = FALSE, eval = TRUE--------------------
githubURL <- "http://github.com/hms-dbmi/EHRtemporalVariability-DataExamples/raw/master/variabilityDemoNHDS.RData"
load(url(githubURL))

## ----variabilityObj2, eval=TRUE-----------------------------------------------
class( probMaps$`diagcode1-phewascode` )

## ----igtProjObj, eval=TRUE----------------------------------------------------
class( igtProjs$`diagcode1-phewascode` )

## ----readCSV, eval=TRUE-------------------------------------------------------
dataset <- read.csv2( "http://github.com/hms-dbmi/EHRtemporalVariability-DataExamples/raw/master/nhdsSubset.csv", 
                      sep  = ",",
                      header = TRUE, 
                      na.strings = "", 
                      colClasses = c( "character", "numeric", "factor",
                                      "numeric" , rep( "factor", 22 ) ) )
head( dataset)

## ----formatDate2, eval=TRUE---------------------------------------------------
class( dataset$date )
datasetFormatted <- EHRtemporalVariability::formatDate(
              input         = dataset,
              dateColumn    = "date",
              dateFormat = "%y/%m"
             )
head( datasetFormatted )[1:5, 1:5]
class( datasetFormatted$date )

## ----icd9toPheWAS, eval=TRUE, message=FALSE, warning=FALSE--------------------
datasetPheWAS <- icd9toPheWAS(data           = datasetFormatted,
                              icd9ColumnName = "diagcode1",
                              phecodeDescription = TRUE,
                              missingValues  = "N/A", 
                              statistics     = TRUE, 
                              replaceColumn  = FALSE)

head( datasetPheWAS[, c( "diagcode1", "diagcode1-phewascode")] )

## ----estimateDataTemporalMap, eval=FALSE--------------------------------------
#  probMaps <- estimateDataTemporalMap(data           = datasetPheWAS,
#                                      dateColumnName = "date",
#                                      period         = "month")

## ----estimateDataTemporalMapOutput, eval=TRUE---------------------------------
class( probMaps )
class( probMaps[[ 1 ]] )

## ----estimateDataTemporalMapSupport, eval=FALSE-------------------------------
#  supports <- vector("list",2)
#  names(supports) <- c("age","diagcode1")
#  supports[[1]] <- 1:18
#  supports[[2]] <- c("V3000","042--","07999","1550-","2252-")
#  probMapsWithSupports <- estimateDataTemporalMap(data           = datasetPheWAS,
#                                      dateColumnName = "date",
#                                      period         = "month",
#                                      supports       = supports)

## ----trimDataTemporalMap, eval=TRUE-------------------------------------------
class( probMaps[[1]] )
probMapTrimmed <- trimDataTemporalMap( 
                        dataTemporalMap = probMaps[[1]],
                        startDate       = "2005-01-01",
                        endDate         = "2008-12-01"
                                      )
class( probMapTrimmed )

## ----estimateIGTProjection, eval=TRUE-----------------------------------------
igtProj <- estimateIGTProjection( dataTemporalMap = probMaps[[1]], 
                                  dimensions      = 2, 
                                  startDate       = "2000-01-01", 
                                  endDate         = "2010-12-31")

## ----estimateIGTProjectionOutput, eval=TRUE-----------------------------------
class( igtProj )

## ----sapplyestimateIGTProjection, eval=FALSE----------------------------------
#  igtProjs <- sapply ( probMaps, estimateIGTProjection )
#  names( igtProjs ) <- names( probMaps )

## ----loadExampleFile, eval=TRUE-----------------------------------------------
githubURL <- "https://github.com/hms-dbmi/EHRtemporalVariability-DataExamples/raw/master/variabilityDemoNHDS.RData"
load(url(githubURL))

## ----plotHeatmap, eval=TRUE---------------------------------------------------
plotDataTemporalMap(
    dataTemporalMap =  probMaps[["diagcode1-phewascode"]],
    startValue = 2,
    endValue = 20,
    colorPalette    = "Spectral")

## ----plotIGTprojection, eval=TRUE---------------------------------------------
plotIGTProjection( 
    igtProjection   =  igtProjs[["diagcode1-phewascode"]],
    colorPalette    = "Spectral", 
    dimensions      = 2)

## ----plotIGTprojectionTrajectory, eval=TRUE-----------------------------------
plotIGTProjection( 
    igtProjection   =  igtProjs[["diagcode1-phewascode"]],
    colorPalette    = "Spectral", 
    dimensions      = 2,
    trajectory      = TRUE)

## ----saveRData, eval=FALSE----------------------------------------------------
#  names( probMaps )
#  names( igtProjs )
#  save(probMaps, igtProjs, file = "myExport.RData")

## ----dbscan, message=FALSE, eval=FALSE, warning=FALSE-------------------------
#  install.packages("dbscan")
#  library(dbscan)

## ----dbscantrue, echo=FALSE, message=FALSE, eval=TRUE, warning=FALSE----------
library(dbscan)

## ----temporalSubgroupsClustering, eval=TRUE-----------------------------------
# We set the minimum number of batches in a subgroup as 2 
# We set eps based on the knee of the following KNNdistplot, at around 0.023
# kNNdistplot(igtProj@projection, k = 2, all = FALSE)
igtProj = igtProjs[["diagcode1-phewascode"]]
# We select the 2 first dimensions for consistency with the IGT plot examples above
dbscanResults <- dbscan(igtProj@projection[,c(1,2)], eps = 0.023, minPts = 2)
clusterNames  <- vector(mode = "character", length = 10)
clusterNames[dbscanResults$cluster == 0] <- "Outlier batches"
clusterNames[! dbscanResults$cluster == 0] <- paste("Temporal subgroup",dbscanResults$cluster[! dbscanResults$cluster == 0])
plotly::plot_ly(x = igtProj@projection[,1], y = igtProj@projection[,2],
              color = as.factor(clusterNames),
              type = "scatter", mode = "markers",
              text = paste0("Date: ",igtProj@dataTemporalMap@dates)) %>%
              plotly::config(displaylogo = FALSE)

