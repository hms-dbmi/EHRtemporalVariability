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

#' Estimates an Information Geometric Temporal plot projection
#'
#' Estimates an \code{IGTProjection} object from a \code{DataTemporalMap} object.
#'
#' @name estimateIGTProjection
# @docType methods
#' @rdname estimateIGTProjection-methods
#' @aliases estimateIGTProjection,IGTProjection-method
#' @param dataTemporalMap of class \code{DataTemporalMap} object.
#' @param dimensions \code{numeric} integer value indicating the number of dimensions 
#' for the projection.
#' @param startDate a Date object indicating the date at which to start the analysis, 
#' in case of being different from the first chronological date in the date column 
#' (the default).
#' @param endDate a Date object indicating the date at which to end the analysis, 
#' in case of being different from the last chronological date in the date column 
#' (the default).
#' @param embeddingType the type of embedding to apply to the dissimilarity matrix of time batches
#' in order to obtain the non-parametric Statistical Manifold, from "classicalmds" and "nonmetricmds", 
#' with "classicalmds" as default. "classicalmds" uses the base R stats::cmdscale function, while "nonmetricmds"
#' uses the MASS:isoMDS function. The returned stress format will depend on the selected embedding type:
#' "classicalmds" returns 1-GOF as returned by stats::cmdscale function, "nonmetricmds" returns the final stress
#' in percent, as returned by the MASS::isoMDS function
#' @return An \code{IGTProjection} object containing the projected coordinates of each
#' temporal batch in the embedded non-parametric Statistical Manifold, as well as the
#' embedding stress according to the embeddingType.
#' @examples
#' load(system.file("extdata",
#'                  "variabilityDemoNHDSdiagcode1-phewascode.RData",
#'                   package="EHRtemporalVariability"))
#' igtProj <- estimateIGTProjection( dataTemporalMap = probMaps$`diagcode1-phewascode`, 
#' dimensions      = 3, 
#' startDate       = "2000-01-01", 
#' endDate         = "2010-12-31")
#' 
#' \dontrun{
#' 
#' # For additional and larger examples download the following .Rdata file:
#' 
#' gitHubUrl  <- 'http://github.com/'
#' gitHubPath <- 'hms-dbmi/EHRtemporalVariability-DataExamples/'
#' gitHubFile <- 'raw/master/variabilityDemoNHDS.RData'
#' inputFile  <-  paste0(gitHubUrl, gitHubPath, gitHubFile)
#' 
#' load(url(inputFile))
#' igtProj <- estimateIGTProjection( dataTemporalMap = probMaps[[1]], 
#' dimensions      = 3, 
#' startDate       = "2000-01-01", 
#' endDate         = "2010-12-31")
#' }
#' @exportMethod estimateIGTProjection
setGeneric (name       = "estimateIGTProjection",
            valueClass = "IGTProjection",
            def        = function(dataTemporalMap, dimensions = 3, startDate = NULL, endDate = NULL, embeddingType = "classicalmds")
            {
                standardGeneric("estimateIGTProjection")
            }
)


#' Data Temporal heatmap
#'
#' Plots a Data Temporal heatmap from an \code{DataTemporalMap} object.
#'
#' @name plotDataTemporalMap
#' @rdname plotDataTemporalMap-methods
#' @param dataTemporalMap of class \code{DataTemporalMap}
#' @param absolute indicates if the heatmap frequency values are absolute or relative. 
#' By default \code{FALSE}.
#' @param startValue indicates the first value to display in the heatmap.
#' By default 1.
#' @param endValue indicates the last value to display in the heatmap.
#' By default the last value of the \code{DataTemporalMap} object.
#' @param startDate a Date object indicating the first date to be displayed in the heatmap. 
#' By default the first date of the \code{DataTemporalMap} object.
#' @param endDate a Date object indicating the last date to be displayed in the heatmap. 
#' By default the last date of the \code{DataTemporalMap} object.
#' @param sortingMethod the method to sort data in the Y axis of the heatmap from "frequency" and 
#' "alphabetical", with "frequency" as default.
#' @param colorPalette color palette to be used. The default "Spectral" palette shows a 
#' color temperature scheme from blue, through yellow, to red (see "Spectral" palette in
#'  RColorBrewer package). The four remaining options are better suited for those with 
#'  colorblindness, including "Viridis", "Magma", and their reversed versions 
#'  "Viridis-reversed" and "Magma-reversed" (see "Viridis" and "Magma" palettes in the
#'  Viridis package).
#' @param mode indicates the plot mode as a 'heatmap' (default) or 'series'.
#'  The other config parameters for the heatmap plot also apply for the series plot.
#' @return A plot object based on the \code{plotly} package.
#' @examples
#' load(system.file("extdata",
#'                  "variabilityDemoNHDSdiagcode1-phewascode.RData",
#'                   package="EHRtemporalVariability"))
#' 
#' p <- plotDataTemporalMap(dataTemporalMap =  probMaps[[1]],
#'                     colorPalette    = "Spectral",
#'                     startValue = 2,
#'                     endValue = 40)
#' p
#' 
#' p <- plotDataTemporalMap(dataTemporalMap =  probMaps[[1]],
#'                     colorPalette    = "Spectral",
#'                     startValue = 2,
#'                     endValue = 40,
#'                     mode = "series")
#' p
#' 
#' \dontrun{
#' 
#' # For additional and larger examples download the following .Rdata file:
#' 
#' gitHubUrl  <- 'http://github.com/'
#' gitHubPath <- 'hms-dbmi/EHRtemporalVariability-DataExamples/'
#' gitHubFile <- 'raw/master/variabilityDemoNHDS.RData'
#' inputFile  <-  paste0(gitHubUrl, gitHubPath, gitHubFile)
#' 
#' load(url(inputFile))
#' plotDataTemporalMap(probMaps$`diagcode1-phewascode`, startValue = 2, endValue = 40)
#' }
#' @exportMethod plotDataTemporalMap
#' @importFrom stats complete.cases setNames
setGeneric (name       = "plotDataTemporalMap",
            valueClass = c("plotly","htmlwidget"),
            def        = function(dataTemporalMap, absolute = FALSE, startValue = 1, endValue = ncol(dataTemporalMap@probabilityMap), startDate = min(dataTemporalMap@dates), endDate = max(dataTemporalMap@dates), sortingMethod = 'frequency', colorPalette = 'Spectral', mode = 'heatmap')
            {
                standardGeneric("plotDataTemporalMap")
            }
)

#' Information Geometric Temporal plot
#'
#' Plots an interactive Information Geometric Temporal (IGT) plot from an \code{IGTProjection} object.
#' An IGT plot visualizes the variability among time batches in a data repository in a 2D or 3D plot.
#' Time batches are positioned as points where the distance between them represents the probabilistic 
#' distance between their distributions (currently Jensen-Shannon distance, more distances will be 
#' supported in the future).
#' To track the temporal evolution, temporal batches are labeled to show their date and 
#' colored according to their season or period, according to the analysis period, as follows.
#' If period=="year" the label is "yy" (2 digit year) and the color is according to year.
#' If period=="month" the label is "yym" (yy + abbreviated month*) and the color is according 
#' to the season (yearly).
#' If period=="week" the label is "yymmw" (yym + ISO week number in 1-2 digit) and the color is 
#' according to the season (yearly). An estimated smoothed trajectory of the information evolution
#' over time can be shown using the optional "trajectory" parameter.
#' *Month abbreviations: \{'J', 'F', 'M', 'A', 'm', 'j', 'x', 'a', 'S', 'O', 'N', 'D'\}.
#'
#' Note that since the projection is based on multidimensional scaling, a 2 dimensional 
#' projection entails a loss of information compared to a 3 dimensional projection. E.g., periodic 
#' variability components such as seasonal effect can be hindered by an abrupt change or a general trend.
#'
#' @name plotIGTProjection
#' @rdname plotIGTProjection-methods
#' @param igtProjection of class \code{IGTProjection}
#' @param dimensions number of dimensions of the plot, 2 or 3 (3 by default)
#' @param startDate a Date object indicating the first date to be displayed in the IGT plot. 
#' By default the first date of the \code{IGTProjection} object.
#' @param endDate a Date object indicating the last date to be displayed in the IGT plot 
#' By default the last date of the \code{IGTProjection} object.
#' @param colorPalette color palette to be used. The default "Spectral" palette shows a color temperature 
#' scheme from blue, through yellow, to red (see "Spectral" palette in RColorBrewer package). 
#' The four remaining options are better suited for those with colorblindness, including "Viridis", 
#' "Magma", and their reversed versions "Viridis-reversed" and "Magma-reversed" (see "Viridis" and 
#' "Magma" palettes in the Viridis package).
#' @param trajectory whether to show an estimated trajectory of the information evolution over time. 
#' By default \code{FALSE}.
#' @return A plot object based on the \code{plotly} package.
#' @examples
#' load(system.file("extdata",
#'                  "variabilityDemoNHDSdiagcode1-phewascode.RData",
#'                   package="EHRtemporalVariability"))
#' 
#' p <- plotIGTProjection( igtProjection   =  igtProjs[[1]],
#'                         colorPalette    = "Spectral",
#'                         dimensions      = 2)
#' p
#' 
#' \dontrun{
#' 
#' # For additional and larger examples download the following .Rdata file:
#' 
#' gitHubUrl  <- 'http://github.com/'
#' gitHubPath <- 'hms-dbmi/EHRtemporalVariability-DataExamples/'
#' gitHubFile <- 'raw/master/variabilityDemoNHDS.RData'
#' inputFile  <-  paste0(gitHubUrl, gitHubPath, gitHubFile)
#' 
#' load(url(inputFile)) 
#' plotIGTProjection(igtProjs$`diagcode1-phewascode`, dimensions = 3)
#' } 
#' @exportMethod plotIGTProjection
#' @importFrom methods .valueClassTest new
setGeneric (name       = "plotIGTProjection",
            valueClass = c("plotly","htmlwidget"),
            def        = function(igtProjection, dimensions = 3, startDate = min(igtProjection@dataTemporalMap@dates), endDate = max(igtProjection@dataTemporalMap@dates), colorPalette = "Spectral", trajectory = FALSE)
            {
                standardGeneric("plotIGTProjection")
            }
)

#' Trims a \code{DataTemporalMap}
#'
#' Trims a \code{DataTemporalMap} object between an start and end date. If one is not specified it takes 
#' as default the first/last chronological date in the input \code{DataTemporalMap}.
#'
#' @name trimDataTemporalMap
#' @rdname trimDataTemporalMap-methods
#' @param dataTemporalMap of class \code{DataTemporalMap}.
#' @param startDate \code{Date} indicating the start date to trim from.
#' @param endDate \code{Date} indicating the end date to trim to.
#' @return A \code{DataTemporalMap} object between the specified dates.
#' @examples
#' load(system.file("extdata",
#'                  "variabilityDemoNHDSdiagcode1-phewascode.RData",
#'                   package="EHRtemporalVariability"))
#' 
#' probMapTrimmed <- trimDataTemporalMap( 
#'                          dataTemporalMap = probMaps[[1]],
#'                          startDate       = "2005-01-01",
#'                          endDate         = "2008-12-01"
#' )
#' @exportMethod trimDataTemporalMap
setGeneric (name = "trimDataTemporalMap",
            valueClass = "DataTemporalMap",
            def        = function(dataTemporalMap, startDate = min(dataTemporalMap@dates), endDate = max(dataTemporalMap@dates))
            {
                standardGeneric("trimDataTemporalMap")
            }
)