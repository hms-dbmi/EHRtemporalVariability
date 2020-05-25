# Copyright 2020 Biomedical Data Science Lab, Universitat Politècnica de València (Spain) - Department of Biomedical Informatics, Harvard Medical School (US)
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

#' Estimates a trajectory of the information temporal evolution in a IGT projection by fitting a cubic smoothing spline
#'
#' Estimates a \code{DataTemporalMap} from a \code{data.frame} containing individuals in rows and the 
#' variables in columns, being one of these columns the analysis date (typically the acquisition date). 
#' Will return a \code{DataTemporalMap} object or a \code{list} of \code{DataTemporalMap} objects 
#' depending on the number of analysis variables.
#'
#' @name estimateIGTTrajectory
#' @rdname estimateIGTTrajectory-methods
#' @param igtProjection of class \code{IGTProjection}.
#' @param nPoints the number of points to fit within the IGT projection range. By default 10x the number of time batches, what shows a high resolution trajectory.
#' @return A list containing a \code{data.frame} of the estimated trajectory points, the estimated date for each point, and the fitted trajectory function as \code{smooth.spline} objects.
#' @examples
#' load(system.file("extdata",
#'                  "variabilityDemoNHDSdiagcode1-phewascode.RData",
#'                   package="EHRtemporalVariability"))
#' 
#' igtTrajectory <- estimateIGTTrajectory( igtProjection   =  igtProjs[[1]] )
#' igtTrajectory$points
#' 
#' @export
estimateIGTTrajectory <- function(igtProjection, nPoints = NULL) {

    if( is.null(igtProjection) )
        stop("An input IGT projection object is required.")
    if( is.null(nPoints) )
        nPoints = nrow(igtProjection@projection)*10
    
    nDims    = ncol(igtProjection@projection)
    nBatches = nrow(igtProjection@projection)
    
    t=1:nBatches
    
    tt = seq(1,nBatches,len = nPoints)
    
    trajectoryFunction <- vector(mode = "list")
    points = data.frame(matrix(nrow = nPoints, ncol = nDims))
    names(points) <- sprintf("D%d",1:nDims)
    dates <- seq(min(igtProjection@dataTemporalMap@dates), max(igtProjection@dataTemporalMap@dates), length.out = nPoints)
    
    for (i in 1:nDims) {
        trajectoryFunction[[names(points)[i]]] = stats::smooth.spline(igtProjection@projection[,i])
        points[,i] = stats::predict(trajectoryFunction[[names(points)[i]]], tt)$y
    }
    
    results <- list("points" = points, "dates" = dates, "trajectoryFunction" = trajectoryFunction)
    return(results)
}

