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

#' Function to transform dates into "Date" R format
#'
#' Given a \code{data.frame} object with a column of dates in 'character' format, 
#' it generates a new \code{data.frame} object with the dates transformed into 
#' "Date" R format. 
#'
#' @param input A \code{data.frame} object with at least one column of dates.
#' @param dateColumn The name of the column containing the date.
#' @param dateFormat By default \code{'\%y/\%m/\%d'}. Change it to the specific structure of your date format.  
#' @param verbose By default \code{FALSE}. Change it to \code{TRUE} to get an on-time log from the function.
#' @return An object of class \code{data.frame} with the date column transform into 'Date' R class. 
#' @examples
#' 
#' dataset <- read.csv2(system.file("extdata",
#'                                    "nhdsSubset.csv",
#'                                    package="EHRtemporalVariability"), 
#'                      sep  = ",",
#'                      header = TRUE, 
#'                      na.strings = "", 
#'                      colClasses = c( "character", "numeric", "factor",
#'                                      "numeric" , rep( "factor", 22 ) ) )
#'                      
#' datasetFormatted <- formatDate( 
#'               input         = dataset, 
#'               dateColumn    = "date", 
#'               dateFormat    = "%y/%m",
#'              )
#' @export formatDate
#' @importFrom stats complete.cases setNames
formatDate <- function( input, dateColumn, dateFormat = "%y/%m/%d", verbose = FALSE ){
   
    
    if( dateColumn %in% colnames( input ) ){
        colNum <- which( colnames( input ) == dateColumn )
    }else{
        message( paste0( "There is no column in your data.frame named as: ", dateColumn ))
        stop()
    }
    
    if( class( input[, colNum] ) ==  "Date" ){
        output <- input
    }else{
        
        if( verbose == TRUE){
        message( paste0( "Formatting the ", dateColumn, " column" ) )
        }
        
    is_letter <- function(x, pattern=c(letters, LETTERS)){
            sapply(x, function(y){
                any(sapply(pattern, function(z) grepl(z, y, fixed=T)))
            })}
    
    if( is_letter( dateFormat, c("Y", "y") ) == TRUE &
            is_letter( dateFormat, c("m", "M", "b", "B","h") ) == TRUE &
            is_letter( dateFormat, c("d", "D" ) ) == TRUE ){
        
        if(verbose == TRUE){
            message("The data format contains year, month and day")
        }
            input$dateFormat <- as.Date( input[ , colNum ], dateFormat )
        }else if( is_letter( dateFormat, c("Y", "y") ) == TRUE &
                  is_letter( dateFormat, c("m", "M", "b", "B","h") ) == TRUE)
                  {
            if(verbose == TRUE){
            message("The data format contains year and month but not day")
            message("Take into account that if you perform an analysis by 
                    week, the day will be automatically assigned as the 
                    first day of the month.")
            }
            input$dateFormat <- zoo::as.Date( zoo::as.yearmon( input[, colNum ], dateFormat ) )
        }else if( is_letter( dateFormat, c("Y", "y") ) == TRUE )
        {
            if(verbose == TRUE){
            message("The data format contains only the year")
            message("Take into account that if you perform an analysis by 
                    week or by month, they will be automatically assigned as the 
                    first day of the month and first month of the year.")
            }
            input$dateFormat <-as.Date( input[, colNum ], dateFormat  )
        }else{
            message("Please, check the format of the date. At least it should
                    contain the year. ")
            stop()
        }
    
    #check if the date transformation is ok 
    checkingComplete <- input[complete.cases(input[ , "dateFormat" ] ) , ]
    if( nrow( checkingComplete ) == nrow( input ) ){
        input[, colNum ] <- input$dateFormat
    }else{
        checkingComplete$date <- checkingComplete$dateFormat
        output <- checkingComplete[, -which( names( checkingComplete ) == "dateFormat" ) ]
        message( paste0( "There are ", nrow( input ) - nrow( checkingComplete ), " rows 
                         that do not contain date information. They have been removed.") )
    }
    
    
    output <- input[, ! names( input) == "dateFormat" ]
    }
    return(output)
}
