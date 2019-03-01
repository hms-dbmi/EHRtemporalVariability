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

jsdiv <- function(p, q){
  # m <- log2(0.5 * (p + q))
  # jsdiv <- 0.5 * (sum(p * (log2(p) - m),na.rm = TRUE) + sum(q * (log2(q) - m), na.rm = TRUE))
    m <- 0.5 * (p + q)
    jsdiv <- 0.5 * (sum(p * (log2(p/m)), na.rm = TRUE) + sum(q * (log2(q/m)), na.rm = TRUE))
    return(jsdiv)
}