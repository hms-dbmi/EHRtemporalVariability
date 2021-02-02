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

checkDataTemporalMap <- function(object) {
    errors <- character()
    if (!all(dim(object@probabilityMap)==dim(object@countsMap))) {
        msg <- "the dimensions of probabilityMap and countsMap do not match"
        errors <- c(errors, msg)
    }
    if (nrow(object@probabilityMap) != length(object@dates)){
        msg <- paste("the length of dates must match the rows of probabilityMap and countsMap")
        errors <- c(errors, msg)
    }
    if (!is.null(object@support) && ncol(object@probabilityMap) != nrow(object@support)){
        msg <- paste("the length of support must match the columns of probabilityMap and countsMap")
        errors <- c(errors, msg)
    }
    validPeriods <- c('week', 'month', 'year')
    if( !object@period %in% validPeriods ){
        msg <- paste("period must be one of the following:", paste(validPeriods,collapse = ', '))
        errors <- c(errors, msg)
    }
    validTypes <- c('numeric', 'integer', 'character', 'factor', 'Date')
    if( !object@variableType %in% validTypes ){
        msg <- paste("variableType must be one of the following:",paste(validTypes,collapse = ', '))
        errors <- c(errors, msg)
    }
    if (length(errors) == 0) TRUE else errors
}

#' Class DataTemporalMap
#'
#' Class \code{DataTemporalMap} object contains the statistical distributions of data estimated at a 
#' specific time period. Both relative and absolute frequencies are included. 
#'
#' Objects of this class are generated automatically by the \code{estimateDataTemporalMap} function, 
#' but its construction and extension is open towards fostering its use through external methods. 
#' E.g., one may use additional probability distribution estimation methods, or even construct 
#' compatible DataTemporalMaps for other unstructured data such as images or free text.
#'
#' @name DataTemporalMap-class
#' @rdname DataTemporalMap-class
#' @aliases DataTemporalMap,DataTemporalMap-class
#' @slot probabilityMap v-by-d numerical \code{matrix} representing the probability distribution 
#' temporal map (relative frequency).
#' @slot countsMap v-by-d numerical \code{matrix} representing the counts temporal map 
#' (absolute frequency).
#' @slot dates d-dimensional \code{Date} array of the temporal batches.
#' @slot support v-by-1 numerical or character \code{matrix} representing the support 
#' (the value at each bin) of probabilityMap and countsMap.
#' @slot variableName name of the variable (character).
#' @slot variableType type of the variable (character) among "numeric", "character", "Date" and "factor".
#' @slot period batching period among "week", "month" and "year".
#' @return A \code{DataTemporalMap} object.
#' @examples
#' 
#' # Generation through estimateDataTemporalMap function:
#' dataset <- read.csv2(system.file("extdata",
#'                                    "nhdsSubset.csv",
#'                                    package="EHRtemporalVariability"), 
#'                      sep  = ",",
#'                      header = TRUE, 
#'                      na.strings = "", 
#'                      colClasses = c( "character", "numeric", "factor",
#'                                      "numeric" , rep( "factor", 22 ) ) )
#' 
#' datasetFormatted <- EHRtemporalVariability::formatDate(
#'                      input         = dataset,
#'                      dateColumn    = "date",
#'                      dateFormat = "%y/%m")
#' 
#' probMaps <- estimateDataTemporalMap(data = datasetFormatted, 
#'                      dateColumnName = "date", 
#'                      period         = "month")
#' 
#' class( probMaps[[1]] ) 
#' 
#' # Manual generation:
#' countsMatrix <- matrix(sample.int(25, size = 12*10, replace = TRUE), nrow = 12, ncol = 10)
#' probabilityMatrix <- sweep(countsMatrix,1,rowSums(countsMatrix),"/")
#' dates <- seq(Sys.Date(),(Sys.Date()+30*11),30)
#' x <- new('DataTemporalMap', probabilityMap = probabilityMatrix, 
#'                      countsMap = countsMatrix, dates = dates, support = data.frame(1:10), 
#'                      variableName = "example", variableType = "numeric", period = "month")
#' plotDataTemporalMap(x)
#' 
#' @exportClass DataTemporalMap
DataTemporalMap <- setClass( "DataTemporalMap",
         slots =
             c( 
                 probabilityMap = "matrix",     # d-by-v matrix representing the probability distribution temporal map
                 countsMap      = "matrix",     # d-by-v matrix representing the absolute frequencies temporal map
                 dates          = "Date",       # d-dimensional date array of the temporal batches
                 support        = "data.frame", # v-by-1 matrix representing the support bins of probabilityMap and countsMap 
                 variableName   = "character",  # name of the variable
                 variableType   = "character",  # type of the variable (numeric, character, Date, factor)
                 period         = "character"   # batching period (week, month, year)
             ),
         prototype = 
             list(
                 probabilityMap  = NULL,
                 countsMap       = NULL,
                 dates           = NULL,
                 support         = NULL,
                 variableName    = NULL,
                 variableType    = NULL,
                 period          = NULL
             ),
         validity = checkDataTemporalMap
)

#' Class IGTProjection
#'
#' Class \code{IGTProjection} object contains the estimated Information Geometric Temporal plot projection
#' of a \code{DataTemporalMap} object.
#'
#' Objects of this class are generated automatically by the \code{estimateIGTProjection} function, and can
#' be passed to the \code{plotIGTProjection} function for plotting the Information Geometric Temporal plot.
#'
#' @name IGTProjection-class
#' @rdname IGTProjection-class
#' @aliases IGTProjection,IGTProjection-class
#' @slot dataTemporalMap the \code{DataTemporalMap} object from which the projection was estimated
#' @slot projection d-by-c \code{matrix} of the IGT projection for d temporal batches in c dimensions calculated from the \code{estimateIGTProjection} function
#' @slot embeddingType embedding function used for the IGT projection calculation in the \code{estimateIGTProjection} function
#' @slot stress stress achieved in the lower-dimensional embedding, depending on the embedding type (e.g., classicalmds will return 1-GOF as returned by stats::cmdscale function, and nonmetricmds will return final stress in percent, as returned by the MASS::isoMDS function)
#' @return A \code{IGTProjection} object.
#' 
IGTProjection <- setClass( "IGTProjection",
           slots =
               c( 
                   dataTemporalMap = "DataTemporalMap", # v-by-d matrix representing the data temporal map
                   projection      = "matrix",          # d-by-c matrix of the IGT projection for d temporal batches in c dimensions
                   embeddingType   = "character",       # embedding function used for the IGT projection calculation, classical multidimensional scaling by default
                   stress          = "numeric"           # stress achieved in the lower-dimensional embedding, depending on the embedding type (e.g., classicalmds will return 1-GOF as returned by stats::cmdscale function, and nonmetricmds will return final stress in percent, as returned by the MASS::isoMDS function)
               ),
           prototype = 
               list(
                   dataTemporalMap = NULL,
                   projection      = NULL,
                   embeddingType   = NULL,
                   stress          = NULL
               )
)
