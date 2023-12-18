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

#' Estimates \code{DataTemporalMap} objects from raw data
#'
#' Estimates a \code{DataTemporalMap} from a \code{data.frame} containing individuals in rows and the 
#' variables in columns, being one of these columns the analysis date (typically the acquisition date). 
#' Will return a \code{DataTemporalMap} object or a \code{list} of \code{DataTemporalMap} objects 
#' depending on the number of analysis variables.
#'
#' @name estimateDataTemporalMap
#' @rdname estimateDataTemporalMap-methods
#' @param data a \code{data.frame} containing as many rows as individuals, and as many columns as the 
#' analysis variables plus the individual acquisition date.
#' @param dateColumnName a string indicating the name of the column in \code{data} containing the 
#' analysis date variable.
#' @param period the period at which to batch data for the analysis from "week", "month" and "year", 
#' with "month" as default.
#' @param startDate a Date object indicating the date at which to start the analysis, in case of being 
#' different from the first chronological date in the date column (the default).
#' @param endDate a Date object indicating the date at which to end the analysis, in case of being 
#' different from the last chronological date in the date column (the default).
#' @param supports a List of objects containing the support of the data distributions for each variable, 
#' in classes \code{numeric}, \code{integer}, \code{character}, or \code{factor} (accordingly to the 
#' variable type), and where the name of the list element must correspond to the column name of its 
#' variable. If not provided it is automatically estimated from data.
#' @param numericVariablesBins the number of bins at which to define the frequency/density histogram 
#' for numerical variables when their support is not provided, 100 as default.
#' @param numericSmoothing a logical value indicating whether a Kernel Density Estimation smoothing 
#' (Gaussian kernel, default bandwidth) is to be applied on numerical variables (the default) or a 
#' traditional histogram instead. See ?density for further details.
#' @param dateGapsSmoothing a logical value indicating whether a linear smoothing is applied to those 
#' time batches without data, by default gaps are filled with NAs.
#' @param verbose By default \code{FALSE}. Change it to \code{TRUE} to get an on-time log from the 
#' function.
#' @return A \code{DataTemporalMap} object.
#' @examples
#' #Load the file 
#' dataset <- read.csv2(system.file("extdata",
#'                                    "nhdsSubset.csv",
#'                                    package="EHRtemporalVariability"), 
#'                      sep  = ",",
#'                      header = TRUE, 
#'                      na.strings = "", 
#'                      colClasses = c( "character", "numeric", "factor",
#'                                      "numeric" , rep( "factor", 22 ) ) )
#' #Format the date
#' datasetFormatted <- EHRtemporalVariability::formatDate( input         = dataset,
#'                                             dateColumn    = "date",
#'                                             dateFormat    = "%y/%m")
#' 
#' #Apply the estimateDataTemporalMap
#' probMaps <- estimateDataTemporalMap( data           = datasetFormatted, 
#'                                      dateColumnName = "date", 
#'                                      period         = "month")
#' \dontrun{
#' 
#' For a larger example download the following .csv dataset and continue the steps as above:
#' 
#' gitHubUrl  <- 'http://github.com/'
#' gitHubPath <- 'hms-dbmi/EHRtemporalVariability-DataExamples/'
#' gitHubFile <- 'raw/master/nhdsSubset.csv'
#' inputFile  <-  paste0(gitHubUrl, gitHubPath, gitHubFile)
#' 
#' dataset <- read.csv2( inputFile, 
#'                      sep  = ",",
#'                      header = TRUE, 
#'                      na.strings = "", 
#'                      colClasses = c( "character", "numeric", "factor",
#'                                      "numeric" , rep( "factor", 22 ) ) ) 
#' }
#' @export
estimateDataTemporalMap <- function(data = NULL, dateColumnName = NULL, period = 'month', startDate = NULL, endDate = NULL, supports = NULL, numericVariablesBins = 100, numericSmoothing = TRUE, dateGapsSmoothing = FALSE, verbose = FALSE) {
    
    # Validation of parameters
    if( is.null(data) )
        stop("An input data frame is required.")
    if( ncol(data)<2 )
        stop("An input data frame is required with at least 2 columns, one for dates.")
    if( is.null(dateColumnName) )
        stop("The name of the column including dates is required.")
    if( !dateColumnName %in% colnames(data) )
        stop(paste0('There is not a column named \"',dateColumnName,'\" in the input data.'))
    if( !class(data[[dateColumnName]]) %in% c("Date") )
        stop("The specified date column must be of class Date.")
    validPeriods <- c('week', 'month', 'year')
    if( !period %in% validPeriods )
        stop(paste("Period must be one of the following:", paste(validPeriods,collapse = ', ')))
    validClasses <- c('numeric', 'integer', 'character', 'factor', 'Date')
    if( any(!sapply(data, class) %in% validClasses) )
        stop(paste("The classes of input columns must be one of the following:",paste(validClasses,collapse = ', ')))
    if( !is.null(startDate) && inherits(startDate, "Date"))
        stop("The specified startDate must be of class Date")
    if( !is.null(endDate) && inherits(endDate, "Date"))
        stop("The specified endDate must be of class Date")
    if ( any(!sapply(supports,class) %in% c('numeric', 'integer', 'character', 'factor')))
        stop("All the elements provided in the supports parameter must be of class data.frame")
    
    # Separate analysis data from analysis dates
    dates    <- data[[dateColumnName]]
    data     <- data[, setdiff(colnames(data),dateColumnName), drop = FALSE]
    nColumns <- ncol(data)
    
    if( verbose ){
        message(sprintf("Total number of columns to analyze: %d",nColumns)) 
        message(sprintf("Analysis period: %s",period)) 
    }
    
    dates = lubridate::floor_date(dates, unit = period, week_start = getOption("lubridate.week.start", 7))
    
    # Get variable types, others will not be allowed
    dataClasses  <- sapply(data, class)
    idxNumeric   <- dataClasses == "numeric"
    idxInteger   <- dataClasses == "integer"
    idxCharacter <- dataClasses == "character"
    idxDate      <- dataClasses == "Date"
    idxFactor    <- dataClasses == "factor"
    
    if( verbose ){
        if(any(idxNumeric))message(sprintf("Number of numeric columns: %d",sum(idxNumeric))) 
        if(any(idxInteger))message(sprintf("Number of integer columns: %d",sum(idxInteger))) 
        if(any(idxCharacter))message(sprintf("Number of character columns: %d",sum(idxCharacter))) 
        if(any(idxDate))message(sprintf("Number of Date columns: %d",sum(idxDate)))
        if(any(idxFactor))message(sprintf("Number of factor columns: %d",sum(idxFactor))) 
    }
    
    # Convert Date variables to numbers
    if ( any(idxDate) ){
        data[,idxDate] = lapply(data[,idxDate, drop = FALSE],as.numeric) 
        if( verbose )
            message("Converting Date columns to numeric for distribution analysis")
    }
    
    # Create supports
    supportsNew <- vector("list", nColumns)
    names(supportsNew) <- colnames(data)
    supportsToEstimate <- rep(TRUE,nColumns)
    
    if( !is.null(supports) ) {
        
        suppNamesMatch <- match(names(supports),names(supportsNew))
        
        if ( any(is.na(suppNamesMatch)) )
            warning("The name of one or more elements provided in support do not match with the variable names of the data, these will be ignored.")
        
        if ( any(!is.na(suppNamesMatch)) ){
            
            supportsProvidedIdx = suppNamesMatch[!is.na(suppNamesMatch)]
            supportsToEstimate[supportsProvidedIdx] = FALSE
            
            for (i in 1:length(supportsProvidedIdx)){
                varName <- names(supportsNew)[supportsProvidedIdx[i]]
                supportsNew[[varName]] <- supports[[varName]]
                errorInSupport = switch(dataClasses[varName],
                                        "factor" = {!class(supportsNew[[varName]]) %in% c("factor","character")},
                                        "numeric" = {!is.numeric(supportsNew[[varName]])},
                                        "integer" = {!is.integer(supportsNew[[varName]])},
                                        "character" = {!class(supportsNew[[varName]]) %in% c("factor","character")},
                                        "date" = {!is.integer(supportsNew[[varName]])}
                )
                if ( errorInSupport )
                    stop(sprintf("The provided support for variable %s does not match with its variable type",names(supportsNew)[i]))
            }
            
        }
    }
    
    supports <- supportsNew
    
    if( any(supportsToEstimate) && verbose ){
        message("Estimating supports from data")
        
        allNA = sapply(data[,supportsToEstimate, drop = FALSE], FUN = function(x) all(is.na(x)))
        
        # Exclude from the analysis those variables with no finite values, if any
        if(any(allNA)){
            if( verbose )
                message(sprintf("Removing variables with no finite values: %s", paste(names(data[,supportsToEstimate, drop = FALSE])[allNA], collapse = ", ")))
            warning(sprintf("Removing variables with no finite values: %s", paste(names(data[,supportsToEstimate, drop = FALSE])[allNA], collapse = ", ")))            
            
            data = data[,!allNA]
            nColumns <- ncol(data)
            supports = supports[!allNA]
            supportsToEstimate = supportsToEstimate[!allNA]
            dataClasses = dataClasses[!allNA]
            idxNumeric   <- dataClasses == "numeric"
            idxInteger   <- dataClasses == "integer"
            idxCharacter <- dataClasses == "character"
            idxDate      <- dataClasses == "Date"
            idxFactor    <- dataClasses == "factor"
        }
    }
    
    if ( any(idxFactor & supportsToEstimate) ){
        data[,idxFactor & supportsToEstimate] = lapply(data[,idxFactor & supportsToEstimate], addNA, ifany = TRUE)
        supports[idxFactor & supportsToEstimate] = lapply(data[,idxFactor & supportsToEstimate, drop = FALSE], levels)
    }
    if ( any(idxNumeric & supportsToEstimate) ){
        mins = sapply(data[,idxNumeric & supportsToEstimate, drop = FALSE], min, na.rm = TRUE)
        maxs = sapply(data[,idxNumeric & supportsToEstimate, drop = FALSE], max, na.rm = TRUE)
        supports[idxNumeric & supportsToEstimate] = data.frame(mapply(seq, mins, maxs, length=rep(numericVariablesBins,length(mins))))
        if ( any(mins == maxs) )
            supports[idxNumeric & supportsToEstimate][mins == maxs] = lapply(supports[idxNumeric & supportsToEstimate][mins == maxs], FUN = function(x) x[1])
    }
    if ( any(idxInteger & supportsToEstimate) ){
        mins = sapply(data[,idxInteger & supportsToEstimate, drop = FALSE], min, na.rm = TRUE)
        maxs = sapply(data[,idxInteger & supportsToEstimate, drop = FALSE], max, na.rm = TRUE)
        if(sum(idxInteger & supportsToEstimate)==1){
            supports[idxInteger & supportsToEstimate] = data.frame(mapply(seq, mins, maxs))
        }
        else{
            supports[idxInteger & supportsToEstimate] = mapply(seq, mins, maxs)
        }
    }
    if ( any(idxCharacter & supportsToEstimate) ){
        supports[idxCharacter & supportsToEstimate] = lapply(data[,idxCharacter & supportsToEstimate, drop = FALSE], unique)
    } 
    if ( any(idxDate & supportsToEstimate) ){ # NOTE: treating dates as numerics
        mins = sapply(data[,idxDate & supportsToEstimate, drop = FALSE], min, na.rm = TRUE)
        maxs = sapply(data[,idxDate & supportsToEstimate, drop = FALSE], max, na.rm = TRUE)
        supports[idxDate & supportsToEstimate] = data.frame(mapply(seq, mins, maxs, length=rep(numericVariablesBins,length(mins))))
    }
    
    # Convert factor variables to characters, as used by the xts Objects
    if ( any(idxFactor) )
        data[,idxFactor] = lapply(data[,idxFactor, drop = FALSE],as.character)
    
    # Exclude from the analysis those variables with a single value, if any
    suppLengths = sapply(supports, length)
    idxSuppSingles = suppLengths<2
    if(any(idxSuppSingles)){
        
        if( verbose )
            message(sprintf("Removing variables with less than two distinct values in their supports: %s",paste(colnames(data)[idxSuppSingles],collapse = ", ")))
        warning(paste("The following variable/s have less than two distinct values in their supports and were excluded from the analysis:",paste(colnames(data)[idxSuppSingles],collapse = ", ")))
        
        data = data[,!idxSuppSingles]
        supports = supports[!idxSuppSingles]
        dataClasses = dataClasses[!idxSuppSingles]
        nColumns <- ncol(data)
    }
    
    if(nColumns == 0)
        stop("Zero remaining variables to be analyzed.")
    
    # Estimate the Data Temporal Map
    dataClassesPost = sapply(data, class)
    results <- vector("list", nColumns)
    
    if( verbose )
        message("Estimating the data temporal maps")
    
    for(i in 1:nColumns){
        
        if( verbose )
            message(sprintf("Estimating the DataTemporalMap of variable '%s'",colnames(data)[i]))
        
        dataxts = xts::xts(data[,i],order.by = dates)
        
        if (!is.null(startDate) || !is.null(endDate)){
            
            if (is.null(startDate))
                startDate = min(dates)
            if (is.null(endDate))
                endDate = max(dates)
            
            dataxts = dataxts[paste(startDate,endDate, sep="/")]
        }
        
        map = switch(period,
                     "week" = xts::apply.weekly(dataxts, FUN = estimateAbsoluteFrequencies, varclass = dataClassesPost[i], support = supports[[i]], numericSmoothing = numericSmoothing),
                     "month" = xts::apply.monthly(dataxts, FUN = estimateAbsoluteFrequencies, varclass = dataClassesPost[i], support = supports[[i]], numericSmoothing = numericSmoothing),
                     "year" = xts::apply.yearly(dataxts, FUN = estimateAbsoluteFrequencies, varclass = dataClassesPost[i], support = supports[[i]], numericSmoothing = numericSmoothing)
        )
        
        datesMap <- as.Date(zoo::index(map))
        seqDateFull <- seq.Date(min(datesMap),max(datesMap), by = period)
        dateGapsSmoothingDone = FALSE
        
        if (length(datesMap) != length(seqDateFull)){
            
            nGaps = length(seqDateFull)-length(datesMap)
            
            seqDateZoo = zoo::zoo(NULL,seqDateFull)
            map = xts::merge.xts(map,seqDateZoo,fill = NA)
            
            if(dateGapsSmoothing){
                map = zoo::na.approx(map)
                if( verbose )
                    message(sprintf("-'%s': %d %s date gaps filed by linear smoothing",colnames(data)[i],nGaps,period))
                dateGapsSmoothingDone = TRUE
            } else{
                if( verbose )
                    message(sprintf("-'%s': %d %s date gaps filed by NAs",colnames(data)[i],nGaps,period))
            }
            
            datesMap <- as.Date(zoo::index(map))
        } else {
            if(verbose && dateGapsSmoothing)
                message(sprintf("-'%s': no date gaps, date gap smoothing was not applied",colnames(data)[i]))
        }
        
        countsMap = zoo::coredata(map)
        probabilityMap = sweep(countsMap,1,rowSums(countsMap),"/")
        
        if(dataClasses[i] == "Date"){
            support = data.frame(as.Date(supports[[i]],origin = lubridate::origin))
        } else if(dataClasses[i] %in% c("character","factor")){
            support = data.frame(as.character(supports[[i]]), stringsAsFactors=FALSE)
        } else {
            support = data.frame(supports[[i]])
        }
        
        if(dateGapsSmoothingDone && any(is.na(probabilityMap)))
            warning(sprintf("Date gaps smoothing was performed in '%s' variable but some gaps will still be reflected in the resultant probabilityMap (this is generally due to temporal heatmap sparsity)",colnames(data)[i]))
        
        probMap = new( "DataTemporalMap",
                       probabilityMap = probabilityMap,
                       countsMap      = countsMap, 
                       dates          = datesMap, 
                       support        = support, 
                       variableName   = colnames(data)[i], 
                       variableType   = dataClasses[i], 
                       period         = period)
        results[[i]] = probMap
    }
    
    if (nColumns > 1){
        names(results) <- colnames(data)
        if( verbose )
            message("Returning results as a named list of DataTemporalMap objects")
        return(results)
    }
    else {
        if( verbose )
            message("Returning results as an individual DataTemporalMap object")
        return(results[[1]])
    }
    
    
}

estimateAbsoluteFrequencies <- function(data = NULL, varclass = NULL, support = NULL, numericSmoothing = FALSE){
    data = zoo::coredata(data);
    switch(varclass,
           "character" = {
               dataTable = as.data.frame(table(factor(data,levels = support, exclude = NULL)))
               map = dataTable$Freq
           },
           "numeric" = {
               if (all(is.na(data))){
                   map = as.numeric(rep(NA,length(support)))
               } else {
                   if(!numericSmoothing){
                       histSupport = c(support,support[length(support)]+(support[length(support)]-support[length(support)-1]))
                       data = data[data>=min(histSupport) & data<max(histSupport)]
                       map = graphics::hist(data,histSupport,plot=FALSE,right=FALSE,include.lowest=TRUE)$counts
                   }
                   else{
                       if (sum(!is.na(data))<4){
                           warning(paste0("Estimating a 1-dimensional kernel density smoothing with less than 4 data points can result in an inaccurate estimation.",
                                          " For more information see 'Density Estimation for Statistics and Data Analysis, Bernard. W. Silverman, CRC ,1986', chapter 4.5.2 'Required sample size for given accuracy'."))
                       }
                       if (sum(!is.na(data))<2){
                           data = rep(data[!is.na(data)],2)
                           ndata = 1
                       } else
                       {
                           ndata = sum(!is.na(data))
                       }
                       dataDensity = stats::density(data, na.rm = T, from = support[1], to = support[length(support)], n = length(support))
                       map = (dataDensity$y/sum(dataDensity$y))*ndata
                   }
               }
           },
           "integer" = {
               if (all(is.na(data))){
                   map = as.integer(rep(NA,length(support)))
               } else {
                   histSupport = c(support,support[length(support)]+(support[length(support)]-support[length(support)-1]))
                   data = data[data>=min(histSupport) & data<max(histSupport)]
                   map = graphics::hist(data,histSupport,plot=FALSE,right=FALSE,include.lowest=TRUE)$counts
               }
           },
           stop(sprintf('data class %s not valid for distribution estimation.',varclass))
    )
    map
}
