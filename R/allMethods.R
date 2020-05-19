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

#' @rdname estimateIGTProjection-methods
#' @aliases estimateIGTProjection,IGTProjection-method
setMethod(f="estimateIGTProjection",
          signature  = c("DataTemporalMap"),
          definition = function(dataTemporalMap, dimensions, startDate, endDate, embeddingType)
          {
              if(is.null(dataTemporalMap))
                  stop("dataTemporalMap of class DataTemporalMap must be provided")
              
              if(dimensions < 2 || dimensions > length(dataTemporalMap@dates))
                  stop("dimensions must be between 2 and length(dataTemporalMap@dates)")
              
              if (!is.null(startDate) && !is.null(endDate)){
                  
                  dataTemporalMap = trimDataTemporalMap(dataTemporalMap, startDate = startDate, endDate = endDate)
                  
              } else {
                  
                  if (!is.null(startDate))
                      dataTemporalMap = trimDataTemporalMap(dataTemporalMap, startDate = startDate)
                  
                  if (!is.null(endDate))
                      dataTemporalMap = trimDataTemporalMap(dataTemporalMap, endDate = endDate)
              }
              
              if (!embeddingType %in% c("classicalmds", "nonmetricmds"))
                  stop("embeddingType must be one of classicalmds or nonmetricmds")
              
              value <- igtProjectionCore(dataTemporalMap = dataTemporalMap, dimensions = dimensions, embeddingType = embeddingType)
              return(value)
          }
)

#' @rdname plotDataTemporalMap-methods
setMethod(f = "plotDataTemporalMap",
          signature  = "DataTemporalMap",
          definition = function(dataTemporalMap, absolute, startValue, endValue, startDate, endDate, sortingMethod, colorPalette ){
              
              if (!colorPalette %in% c("Spectral", "Viridis", "Magma", "Viridis-reversed", "Magma-reversed"))
                  stop("colorPalette must be one of Spectral, Viridis, Magma, Viridis-reversed or Magma-reversed")
              
              if (!is.logical(absolute))
                  stop("absolute must be a logical value")
              
              if (startValue < 1)
                  stop("startValue must be greater or equal than 1")
              
              if (!sortingMethod %in% c("frequency", "alphabetical"))
                  stop("sortMethod must be one of frequency or alphabetical")
              
              vals = seq(0, 1, length.out = 100)
              cols = switch(colorPalette,
                            "Spectral"         = scales::col_numeric("Spectral", domain = NULL)(vals),
                            "Viridis"          = scales::col_numeric(viridis::viridis(100), domain = NULL)(vals),
                            "Magma"            = scales::col_numeric(viridis::magma(100), domain = NULL)(vals),
                            "Viridis-reversed" = scales::col_numeric(viridis::viridis(100,direction = -1), domain = NULL)(vals),
                            "Magma-reversed"   = scales::col_numeric(viridis::magma(100,direction = -1), domain = NULL)(vals)
              )
              
              colorScale = setNames(data.frame(vals, cols),NULL)
              
              temporalMap = switch(absolute+1,
                                   xts::xts(dataTemporalMap@probabilityMap, order.by = dataTemporalMap@dates),
                                   xts::xts(dataTemporalMap@countsMap, order.by = dataTemporalMap@dates)
              )
              temporalMap = temporalMap[paste(startDate,endDate, sep="/")]
              dates = zoo::index(temporalMap)
              temporalMap = zoo::coredata(temporalMap)
              
              support = dataTemporalMap@support
              variableType = dataTemporalMap@variableType
              
              if (variableType %in% c('factor','character')) {
                  if (sortingMethod  %in% 'frequency'){
                      supportOrder = order(colSums(temporalMap, na.rm = TRUE),decreasing = TRUE)
                  } else {
                      supportOrder = order(support,decreasing = FALSE)
                  }
                  
                  support = support[supportOrder,, drop = FALSE]
                  temporalMap = temporalMap[,supportOrder]
                  
                  anySuppNa = is.na(support)
                  if(any(anySuppNa))
                      support[anySuppNa] = "<NA>"
              }
              
              # if (variableType %in% 'factor') {
              #     support = as.character(support)
              # }
              
              if ( endValue > ncol(temporalMap) ){
                  endValue = ncol(temporalMap)
              }
              
              f <- list(
                  #family = "Courier New, monospace",
                  size = 18,
                  color = "#7f7f7f"
              )
              x <- list(
                  title = "Date",
                  titlefont = f,
                  type = "date"
              )
              y <- list(
                  title = dataTemporalMap@variableName,
                  titlefont = f,
                  tickfont = 14,
                  automargin = TRUE,
                  type = switch(variableType, "character" = "category", "factor" = "category", "numeric" = "-" )
              )
              m <- list(
                  l = min(max(nchar(support[startValue:endValue,1]))*(50),125)
              )
              
              p <- plotly::plot_ly(x=dates, y=support[startValue:endValue,1], z = t(as.data.frame(temporalMap[,startValue:endValue])),
                                   type = "heatmap", colorscale = colorScale, reversescale = TRUE) %>%
                  plotly::config(staticPlot = FALSE, displayModeBar = TRUE, editable = FALSE,
                                 sendData = FALSE, displaylogo = FALSE, 
                                 modeBarButtonsToRemove = list("sendDataToCloud","hoverCompareCartesian"))%>%
                  plotly::layout(xaxis = x, yaxis = y, title = ifelse(absolute, "Absolute frequencies data temporal heatmap", "Probability distribution data temporal heatmap" )) %>%
                  plotly::layout(margin = m)
              
              return(p)
          }
)

#' @rdname plotIGTProjection-methods
setMethod(f="plotIGTProjection",
          signature  = "IGTProjection",
          definition = function(igtProjection, dimensions, startDate, endDate, colorPalette, trajectory){
              
              if (dimensions < 2 || dimensions > 3)
                  stop("currently IGT plot can only be made on 2 or 3 dimensions, please set dimensions parameter accordingly")
              
              if (!colorPalette %in% c("Spectral", "Viridis", "Magma", "Viridis-reversed", "Magma-reversed"))
                  stop("colorPalette must be one of Spectral, Viridis, Magma, Viridis-reversed or Magma-reversed")
              
              
              dateidxs = igtProjection@dataTemporalMap@dates >= startDate & igtProjection@dataTemporalMap@dates <= endDate
              
              dates = igtProjection@dataTemporalMap@dates[dateidxs]
              projection = igtProjection@projection[dateidxs,]
              ndates = length(dates)
              
              if (igtProjection@dataTemporalMap@period == "year"){
                  yearcolor = switch(colorPalette,
                                     "Spectral"         = grDevices::colorRampPalette(RColorBrewer::brewer.pal(11,"Spectral"))(ndates),
                                     "Viridis"          = viridis::viridis(ndates),
                                     "Magma"            = viridis::magma(ndates),
                                     "Viridis-reversed" = viridis::viridis(ndates, direction = -1),
                                     "Magma-reversed"   = viridis::magma(ndates, direction = -1)
                  )
              }
              else { # month and week
                  
                  vals = seq(0, 1, length.out = 100)
                  colorlist = switch(colorPalette,
                                     "Spectral"         = grDevices::colorRampPalette(RColorBrewer::brewer.pal(11,"Spectral"))(128),
                                     "Viridis"          = viridis::viridis(128),
                                     "Magma"            = viridis::magma(128),
                                     "Viridis-reversed" = viridis::viridis(128, direction = -1),
                                     "Magma-reversed"   = viridis::magma(128, direction = -1)
                  )
                  
                  dperiod = switch(igtProjection@dataTemporalMap@period, "month" = 12, "week" = 53)
                  
                  colorlist = rev(colorlist)
                  colorlist = c(colorlist, rev(colorlist))
                  periodcolor = colorlist[round(seq(1,256,length=(dperiod+1)))]
                  periodcolor = periodcolor[1:dperiod]
                  months = c('J', 'F', 'M', 'A', 'm', 'j', 'x', 'a', 'S', 'O', 'N', 'D')
                  monthsLong = c('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec')
              }
              
              if (dimensions == 2) {
                  
                  p <- plotly::plot_ly() %>%
                      plotly::config(staticPlot = FALSE, displayModeBar = TRUE, editable = FALSE,
                                     sendData = FALSE, displaylogo = FALSE,
                                     modeBarButtonsToRemove = list("sendDataToCloud","hoverCompareCartesian")) %>%
                      plotly::layout(showlegend = FALSE,
                                     xaxis = list(title = 'D1', scaleanchor = "x"),
                                     yaxis = list(title = 'D2', scaleanchor = "x"),
                                     title = "Information Geometric Temporal (IGT) plot"
                      )
                  
                  if (igtProjection@dataTemporalMap@period == "year"){
                      for(i in 1:ndates){
                          p <- plotly::add_text(p, x = projection[i,1], y = projection[i,2],
                                                hoverinfo = 'text',
                                                # hovertext = paste('Year: ',format(dates[i],"%Y")),
                                                hovertext = paste(format(dates[i],"%Y")),
                                                text = paste(format(dates[i],"%Y")),
                                                textfont = list(size = 14, color = yearcolor[i]), textposition = "middle center")
                      }
                  }
                  else if (igtProjection@dataTemporalMap@period == "month"){
                      cidx = as.numeric(format(dates,'%m'))
                      for(i in 1:ndates){
                          p <- plotly::add_text(p, x = projection[i,1], y = projection[i,2],
                                                hoverinfo = 'text',
                                                # hovertext = paste('Year: ',format(dates[i],"%Y"),'\nMonth: ',monthsLong[cidx[i]]),
                                                hovertext = paste(format(dates[i],"%Y"),'-',monthsLong[cidx[i]]),
                                                text = paste(format(dates[i],"%y"),months[cidx[i]],sep=''),
                                                textfont = list(size = 14, color = periodcolor[cidx[i]]), textposition = "middle center")
                      }
                  }
                  else if (igtProjection@dataTemporalMap@period == "week"){
                      cidxw = as.numeric(lubridate::isoweek(dates))
                      cidxm = as.numeric(format(dates,'%m'))
                      for(i in 1:ndates){
                          p <- plotly::add_text(p, x = projection[i,1], y = projection[i,2],
                                                hoverinfo = 'text',
                                                # hovertext = paste('Year: ',format(dates[i],"%Y"),'\nMonth: ',monthsLong[cidx[i]],'\nWeek: ',cidxw[i]),
                                                hovertext = paste(format(dates[i],"%Y"),'-',monthsLong[cidxm[i]],'-w',cidxw[i]),
                                                text = paste(format(dates[i],"%y"),months[cidxm[i]],cidxw[i],sep=''),
                                                textfont = list(size = 14, color = periodcolor[cidxw[i]]), textposition = "middle center")
                      }
                  }
                  
                  if( trajectory ){
                      igtTrajectory = estimateIGTTrajectory(igtProjection)
                      p <- plotly::add_trace(p, x = igtTrajectory$points$D1, y = igtTrajectory$points$D2,
                                             type = 'scatter', mode = 'lines', line = list(color = "#21908C", width = 1),
                                             hovertext = sprintf("Approx. date: %s",rownames(igtTrajectory$points))) %>% plotly::hide_colorbar()
                  }
                  
                  return(p)
                  
              } else if (dimensions == 3) {
                  
                  p <- plotly::plot_ly() %>%
                      plotly::config(staticPlot = FALSE, displayModeBar = TRUE, editable = FALSE,
                                     sendData = FALSE, displaylogo = FALSE,
                                     modeBarButtonsToRemove = list("sendDataToCloud","hoverCompareCartesian")) %>%
                      plotly::layout(showlegend = FALSE, scene = list(xaxis = list(title = 'D1', scaleanchor = "x"),
                                                                      yaxis = list(title = 'D2', scaleanchor = "x"),
                                                                      zaxis = list(title = 'D3', scaleanchor = "x")),
                                     title = "Information Geometric Temporal (IGT) plot"
                      )
                  
                  if (igtProjection@dataTemporalMap@period == "year"){
                      for(i in 1:ndates){
                          p <- plotly::add_text(p, x = projection[i,1], y = projection[i,2], z = projection[i,3],
                                                hoverinfo = 'text',
                                                # hovertext = paste('Year: ',format(dates[i],"%Y")),
                                                hovertext = paste(format(dates[i],"%Y")),
                                                text = paste(format(dates[i],"%Y")),
                                                textfont = list(size = 14, color = yearcolor[i]), textposition = "middle center")
                      }
                  }
                  else if (igtProjection@dataTemporalMap@period == "month"){
                      cidx = as.numeric(format(dates,'%m'))
                      for(i in 1:ndates){
                          p <- plotly::add_text(p, x = projection[i,1], y = projection[i,2], z = projection[i,3],
                                                hoverinfo = 'text',
                                                # hovertext = paste('Year: ',format(dates[i],"%Y"),'\nMonth: ',monthsLong[cidx[i]]),
                                                hovertext = paste(format(dates[i],"%Y"),'-',monthsLong[cidx[i]]),
                                                text = paste(format(dates[i],"%y"),months[cidx[i]],sep=''),
                                                textfont = list(size = 14, color = periodcolor[cidx[i]]), textposition = "middle center")
                      }
                      # textfonts = lapply(monthcolor[cidx], function(x) list(size = 14, color = x))
                      # for(i in 1:ndates){
                      #     p <- add_text(p, x = projection[i,1], y = projection[i,2], z = projection[i,3],
                      #                   text = paste(format(dates[i],"%y"),months[cidx[i]],sep=''),
                      #                   textfont = textfonts[[i]], textposition = "middle center")
                      # }
                  }
                  else if (igtProjection@dataTemporalMap@period == "week"){
                      cidxw = as.numeric(lubridate::isoweek(dates))
                      cidxm = as.numeric(format(dates,'%m'))
                      for(i in 1:ndates){
                          p <- plotly::add_text(p, x = projection[i,1], y = projection[i,2], z = projection[i,3],
                                                hoverinfo = 'text',
                                                # hovertext = paste('Year: ',format(dates[i],"%Y"),'\nMonth: ',monthsLong[cidx[i]],'\nWeek: ',cidxw[i]),
                                                hovertext = paste(format(dates[i],"%Y"),'-',monthsLong[cidxm[i]],'-w',cidxw[i]),
                                                text = paste(format(dates[i],"%y"),months[cidxm[i]],cidxw[i],sep=''),
                                                textfont = list(size = 14, color = periodcolor[cidxw[i]]), textposition = "middle center")
                      }
                  }
                  
                  if( trajectory ){
                      igtTrajectory = estimateIGTTrajectory(igtProjection)
                      p <- plotly::add_paths(p, x = igtTrajectory$points$D1, y = igtTrajectory$points$D2, z = igtTrajectory$points$D3,
                                             color = 1:nrow(igtTrajectory$points), hovertext = sprintf("Approx. date: %s",rownames(igtTrajectory$points))) %>% plotly::hide_colorbar()
                  }
                  
                  return(p)
                  
              }
              
          }
)


#' @rdname trimDataTemporalMap-methods
setMethod(f="trimDataTemporalMap",
          signature  = "DataTemporalMap",
          definition = function(dataTemporalMap, startDate = min(dataTemporalMap@dates), endDate = max(dataTemporalMap@dates))
          {
              temporalMap <- xts::xts(dataTemporalMap@probabilityMap, order.by = dataTemporalMap@dates)
              temporalMap <- temporalMap[paste(startDate,endDate, sep="/")]
              dates       <- zoo::index(temporalMap)
              temporalMap <- zoo::coredata(temporalMap)
              
              temporalCountsMap <- xts::xts(dataTemporalMap@countsMap, order.by = dataTemporalMap@dates)
              temporalCountsMap <- temporalCountsMap[paste(startDate,endDate, sep="/")]
              temporalCountsMap <- zoo::coredata(temporalCountsMap)
              
              dataTemporalMap@probabilityMap <- temporalMap
              dataTemporalMap@countsMap      <- temporalCountsMap
              dataTemporalMap@dates          <- dates
              
              return(dataTemporalMap)
          }
)
