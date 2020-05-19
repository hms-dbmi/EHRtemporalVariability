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

igtProjectionCore <- function(dataTemporalMap = NULL, dimensions = 3, embeddingType = "classicalmds") {
    
    dates = dataTemporalMap@dates
    temporalMap = dataTemporalMap@probabilityMap
    ndates <- length(dates)
    
    
    ## Loop version
    
    dissimMatrix = matrix(data=0,nrow=ndates,ndates)
    for(i in 1:(ndates-1)){
        for(j in (i+1):ndates){
            dissimMatrix[i,j] = sqrt(jsdiv(temporalMap[i,],temporalMap[j,]))
            dissimMatrix[j,i] = dissimMatrix[i,j]
        }
    }
    
    ## Vectorized version
    ## NOTE: The following vectorized code is ~20% faster than the above but vec1,vec2 allocation can fail if not enough memory
    #
    # idx = which(lower.tri(matrix(, nrow = ndates, ncol = ndates), diag = FALSE), arr.ind=T)
    # 
    # vec1 = temporalMap[idx[,2],]
    # vec2 = temporalMap[idx[,1],]
    # 
    # mvec = 0.5 * (vec1 + vec2)
    # jsdists = sqrt(0.5 * (rowSums(vec1 * log2(vec1/mvec), na.rm = TRUE) + rowSums(vec2 * log2(vec2/mvec), na.rm = TRUE)))
    # 
    # dissimMatrix = matrix(data=0, nrow = ndates, ncol = ndates)
    # dissimMatrix[lower.tri(dissimMatrix, diag = FALSE)] = jsdists
    # dissimMatrix = as.dist(dissimMatrix)
    
    embeddingResults = switch(embeddingType,
                            "classicalmds" = {stats::cmdscale(dissimMatrix, eig = FALSE, k = dimensions, list. = TRUE)},
                            "nonmetricmds" = {MASS::isoMDS(dissimMatrix, trace = FALSE, k = dimensions)}
    )
    
    igtProj = switch(embeddingType,
                     "classicalmds" = {IGTProjection(dataTemporalMap = dataTemporalMap, projection = embeddingResults$points, embeddingType = embeddingType, stress = 1-embeddingResults$GOF)},
                     "nonmetricmds" = {IGTProjection(dataTemporalMap = dataTemporalMap, projection = embeddingResults$points, embeddingType = embeddingType, stress = embeddingResults$stress)}
    )

    return(igtProj)
}