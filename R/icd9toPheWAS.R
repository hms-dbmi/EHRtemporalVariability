# Copyright 2019 Biomedical Data Science Lab, Universitat Politècnica de València (Spain) - Department of Biomedical Informatics, Harvard Medical School (US)
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#' Function to transform ICD9-CM codification into PheWAS code
#'
#' Given a  \code{data.frame} object with a column of ICD9-CM codes, it generates a 
#' new \code{data.frame} object with the ICD9-CM codes transformed into PheWAS codes. 
#'
#' @param data A \code{data.frame} object with at least one column of ICD9-CM codes that
#' one to be transformed into a PheWAS code. 
#' @param icd9ColumnName The name of the column containing the ICD9-CM.
#' @param missingValues The value used to determine missing values in the data.frame. 
#' @param phecodeDescription By default \code{FALSE}. Change it to \code{TRUE} to map
#' to the PheWAS code description instead to the PheWAS numeric code. 
#' @param statistics By default \code{FALSE}. Change it to \code{TRUE} to show the 
#' summary of the mapping like the percentage of initial ICD9-CM codes mapped to PheWAS code. 
#' @param replaceColumn By default \code{TRUE}. Change it to \code{FALSE} in order to create a
#' new column with the PheWAS code maintaining the ICD9-CM code.  
#' @param verbose By default \code{FALSE}. Change it to \code{TRUE} to get an
#' on-time log from the function.
#' @return An object of class \code{data.frame} with the ICD9-CM column transform into
#' PheWAS codes. 
#' @examples
#' dataset <- read.csv2(system.file("extdata",
#'                                    "nhdsSubset.csv",
#'                                    package="EHRtemporalVariability"), 
#'                      sep  = ",",
#'                      header = TRUE, 
#'                      na.strings = "", 
#'                      colClasses = c( "character", "numeric", "factor",
#'                                      "numeric" , rep( "factor", 22 ) ) )
#' 
#' datasetPheWAS <- icd9toPheWAS( data           = dataset,
#'                               icd9ColumnName  = "diagcode1", 
#'                               missingValues   = "N/A", 
#'                               replaceColumn   = TRUE, 
#'                               statistics      = TRUE 
#'                               )
#' @export icd9toPheWAS
#' @import dplyr 
#' @importFrom utils read.delim
#' @importFrom utils read.csv
icd9toPheWAS <- function( data, icd9ColumnName, missingValues = "NA", phecodeDescription = FALSE, statistics = FALSE, replaceColumn = TRUE, verbose = FALSE ){
    
    if( verbose == TRUE){
        message("Loading the ICD9-CM mapping file") 
    }
    
    #load the icd9 mapping file
    icd9File <- read.delim( file   = system.file("extdata",
                                                 "icd9mappingFile.csv",
                                                 package="EHRtemporalVariability"),
                            header     = TRUE,
                            sep        = "\t",
                            colClasses = "character" )

    #check if the column name of the icd9 column exists and save it
    input <- data
    if( icd9ColumnName %in% colnames( input ) ){
        colNum <- which( colnames( input ) == icd9ColumnName )
    }else{
        message( paste0( "There is no column in your data.frame named as: ", icd9ColumnName ))
        stop()
    }
    
    #check if the selected column is factor and if so coerce to character
    if (inherits( input[[icd9ColumnName]] , 'factor')){
        input[[icd9ColumnName]] <- as.character( input[[icd9ColumnName]] )
    }

    if( verbose == TRUE){
        message( paste0( "Checking that the ", icd9ColumnName, " follows the ICD9 structure" ) )
        message( "Missing values will be substituted by 'MissingValues'")
    }
    
    #check if the icd9 column will be replace or another one will be created
    if( replaceColumn == FALSE){
        input$newPhewasColumn <- input[, colNum]
        colNum <- which( colnames( input ) == "newPhewasColumn" )
        colnames( input )[ colNum ] <- paste0( icd9ColumnName, "-phewascode")
    }
    
    #substitute the missing values
    input[, colNum] <- gsub( missingValues, "MissingValues", input[, colNum])

    if( verbose == TRUE){
        message( "Those characters that are non alpha numeric will be removed")
    }
    
    #we remove the non-alphanumeric symbols like "." from the icd9 codes 
    input[, colNum] <- gsub("[^[:alnum:] ]", "", input[, colNum] )

    if( verbose == TRUE){
        message( "Mapping the ICD9-CM to PheWAS code." )
        message( "Please note that Phecode Map 1.2 will be used for this process" )
    }
    
    #create a new data set with the correspondence between icd9 and phewas code   
    colnames( icd9File )[5] <- icd9ColumnName
    completeSet <- dplyr::left_join( input, 
                                     icd9File )

    #determine how many cases are missing values
    naCases      <- which( is.na( completeSet$PheCode ) )
    missingCases <-  naCases[ completeSet[naCases, colNum] %in% "MissingValues"]
    completeSet$PheCode[ missingCases ] <- "MissingValues"
    completeSet$Phenotype[ missingCases ] <- "MissingValues"
    
    #determine how many codes are external causes (not mapped to phewas codes)
    nwNaCases <- setdiff( naCases, missingCases )
    externalCases <- nwNaCases[ substr( as.character(completeSet[nwNaCases, colNum]),1,1 ) == "E" ]
    completeSet$PheCode[ externalCases ] <- "ExternalCauses"
    completeSet$Phenotype[ externalCases ] <- "ExternalCauses"
    
    #determine how many codes are V codes that does not have an assigned icd9 code
    nw2NaCases <- setdiff( nwNaCases, externalCases)
    vCodeNoMap <- nw2NaCases[ substr( as.character(completeSet[nw2NaCases, colNum]),1,1 ) == "V" ]
    completeSet$PheCode[ vCodeNoMap ] <- "VcodeNotMapped"
    completeSet$Phenotype[ vCodeNoMap ] <- "VcodeNotMapped"
    
    #determine how many codes follow an icd9 structure but are not mapped
    nw3NaCases <- setdiff( nw2NaCases, vCodeNoMap )
    icd9Char <- c("V", "E", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0")   
    numbers <- as.character(sprintf('%0.3d', 1:99999)) 
    icd9CodeNoMap <- nw3NaCases[ nchar( completeSet[ nw3NaCases, colNum ] ) <= 5 & 
                                  substr( as.character(completeSet[ nw3NaCases , colNum ]), 1, 1) %in% icd9Char &
                                     substr( as.character(completeSet[ nw3NaCases , colNum ]), 2, nchar(completeSet[ nw3NaCases , colNum ])) %in% numbers ]
    completeSet$PheCode[ icd9CodeNoMap ] <- "ICD9codeNotMapped"
    completeSet$Phenotype[ icd9CodeNoMap ] <- "ICD9codeNotMapped"
    
    #determine how many does not follow the icd9 standard
    nw4NaCases <- setdiff( nw3NaCases, icd9CodeNoMap)
    completeSet$PheCode[ nw4NaCases ] <- "NonICD9code"
    completeSet$Phenotype[ nw4NaCases ] <- "NonICD9code"
    
    #summary of the mapping           
    if( statistics == TRUE){
        
        missingData <- completeSet[ completeSet$PheCode == "MissingValues", ]
        message( paste0( "# Missing values: ", nrow( missingData), " cases ( ", round(nrow( missingData) / nrow( completeSet ) * 100 , 2), "%)"))
        
        externalCausesCodes <- completeSet[ completeSet$PheCode == "ExternalCauses", ]
        message( paste0( "# External causes codes: ", nrow( externalCausesCodes), " cases ( ", round(nrow( externalCausesCodes) / nrow( completeSet ) * 100 , 2), "%)"))
        
        vcodeNotMapped <- completeSet[ completeSet$PheCode == "VcodeNotMapped", ]
        message( paste0( "# V codes not mapped: ", nrow( vcodeNotMapped), " cases ( ", round(nrow( vcodeNotMapped) / nrow( completeSet ) * 100 , 2), "%)"))
        
        icd9InitialCodes <- completeSet[ completeSet$PheCode != "MissingValues"  &
                                         completeSet$PheCode != "ExternalCauses" &
                                         completeSet$PheCode != "VcodeNotMapped" & 
                                         completeSet$PheCode != "ICD9codeNotMapped", ]
        
        message( paste0( "# Total ICD9-CM codes mapped: ", nrow( icd9InitialCodes), " cases ( ", round(nrow( icd9InitialCodes) / nrow( completeSet ) * 100 , 2), "%)"))
        message( paste0( "# Unique ICD9-CM codes mapped: ", length(unique(icd9InitialCodes[, colNum] ) )))
        message( paste0( "# Total PheWAS codes: ", length(unique(icd9InitialCodes$PheCode ) ) ))
        
        
        icd9codeNotMapped <- completeSet[ completeSet$PheCode == "ICD9codeNotMapped", ]
        message( paste0( "# ICD9 codes not mapped: ", nrow( icd9codeNotMapped), " cases ( ", round(nrow( icd9codeNotMapped) / nrow( completeSet ) * 100 , 2), "%)"))
        
        }
    
    #format the final output
    if( phecodeDescription == TRUE ){
        completeSet[, colNum ] <- completeSet$Phenotype
    }else{
        completeSet[, colNum ] <- completeSet$PheCode
    }
    
    finalColumn <- ncol(completeSet)-4 
    completeSet <- as.data.frame( completeSet[ , 1:finalColumn] )
    colnames( completeSet)[ colNum ] <- paste0( icd9ColumnName, "-phewascode")
    
    #if the selected icd9 column was factor, since it was converted to character then change it back to factor
    if (replaceColumn == FALSE & inherits( data[[icd9ColumnName]] , 'factor')){
        completeSet[[icd9ColumnName]] <- factor( completeSet[[icd9ColumnName]] )
    }
    
    return(completeSet)
}
