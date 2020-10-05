---
title: "EHRtemporalVariability: Delineating temporal dataset shifts in Electronic Health Records"
date: "May 25, 2020"
package: "EHRtemporalVariability 1.1.2"
author:
- name: Carlos Sáez
  affiliation: 
  - &id1 Biomedical Data Science Lab, Instituto Universitario de Tecnologías de la Información y Comunicaciones, Universitat Politècnica de València, Spain
  - &id2 Department of Biomedical Informatics, Harvard Medical School, US
  email: carsaesi@upv.es
- name: Alba Gutiérrez-Sacristán
  affiliation: *id2
  email: Alba_Gutierrez@hms.harvard.edu
- name: Isaac Kohane
  affiliation: *id2
  email: Isaac_Kohane@hms.harvard.edu
- name: Juan M García-Gómez
  affiliation: *id1
  email: juanmig@upv.es
- name: Paul Avillach
  affiliation: *id2
  email: Paul_Avillach@hms.harvard.edu
bibliography: general-overview.bib
csl: biomed-central.csl
vignette: >
    %\VignetteIndexEntry{EHRtemporalVariability}
    %\VignetteEngine{knitr::rmarkdown}
    %\VignetteEncoding{UTF-8}
output: 
    BiocStyle::html_document:
    toc_float: true
---



# Introduction
The `EHRtemporalVariability` package contains functions to delineate temporal dataset shifts in Electronic Health Records through the projection and visualization of dissimilarities among data temporal batches. This is done through the estimation of data statistical distributions over time and their projection in non-parametric statistical manifolds, uncovering the patterns of the data latent temporal variability. Dataset shifts can be explored and identified through visual analytics formats such as Data Temporal heatmaps and Information Geometric Temporal (IGT) plots [@saez_probabilistic_2015; @saez2016applying; @saez2018kinematics]. An additional [EHRtemporalVariability Shiny app](https://github.com/hms-dbmi/EHRtemporalVariability-shiny) can be used to load and explore the package results towards an improved investigation experience and even to allow the use of these functions to those users non-experienced in R coding.

If you use `EHRtemporalVariability` please cite:

<span style="background-color:LemonChiffon">Carlos Sáez, Alba Gutiérrez-Sacristán, Isaac Kohane, Juan M García-Gómez, Paul Avillach. EHRtemporalVariability: delineating temporal data-set shifts in Electronic Health Records. GigaScience, Volume 9, Issue 8, August 2020, giaa079. [doi:10.1093/gigascience/giaa079](https://doi.org/10.1093/gigascience/giaa079)</span> [@saez2020]


## Background
Biomedical Data research repositories and property biomedical research databases are becoming bigger both in terms of sample size and collected variables [@Gewin2016; @Andreu-Perez2015]. Two significant reasons behind of this are the widespread adoption of data-sharing initiatives and technological infrastructures, and the continuous and systematic population of those repositories over longer periods of time. However, these two situations can also introduce potential confounding factors in data which may hinder their reuse for research, such as in population research or in statistical and machine learning modeling. Concretely, differences in protocols, populations, or even unexpected biases, either caused by systems or humans, can lead to temporal dataset shifts [@quionero2009dataset; @moreno2012unifying], changes of reference which are reflected in the statistical distributions of data. This temporal variability of data represent a Data Quality (DQ) issue which must be addressed for a reliable data reuse [@saez2016applying; @schlegel2017secondary].

The `EHRtemporalVariability` package has been developed to help preventing this problem.

The tasks that can be performed with `EHRtemporalVariability` package are the following:

  1. Estimate the probability distributions of numerical and coded variables on temporal batches at a yearly, monthly or weekly period.
  2. Plot and explore `data temporal heatmaps` of absolute and relative frequencies of variable values over temporal batches.
  3. Estimate a projection of the variability among data temporal batches, as a non-parametric information geometry embedding of the probabilistic distances among the probability distributions of temporal batches at a number of dimensions specified by the user, allowing for plotting (see next point) or further data analysis methods (such as unsupervised learning of temporal batches).
  4. Plot and explore the projection above through an `Information Geometric Temporal plot`, which helps delineating reference changes in data over time, including abrupt and recurrent changes, conceptually-related time periods (periods with similar data distributions), but also smooth temporal trends.
  5. Additional data pre- and processing options, such as mapping International Classification of Diseases 9th revision (ICD-9) codes to phenotype codes used in Phenome-Wide Association studies (PheWAS), or trimming data temporal maps.

In the following sections the specific functions that can be used to address each of these tasks are presented.

![General workflow for using the EHRtemporalVariability R package](./rpackageworkflow.png)

For more information about the methods please check reference [@saez_probabilistic_2015] and the Suplemental Material in [@saez2016applying].

## Installation 
`EHRtemporalVariability` is provided through CRAN and GitHub. To install the CRAN version the user must type the following commands in an R session:


```r
install.packages("EHRtemporalVariability")
library(EHRtemporalVariability)
```



The GitHub version of the package will, in general, provide the latest updates before these are commited to the CRAN version. In order to install it, `devtools` package - available in CRAN (https://cran.r-project.org/) - is required. To install `devtools` the user must type the following commands in an R session:


```r
install.packages("devtools")
library(devtools)
```

Once `devtools` package has been installed the user can install `EHRtemporalVariability` typing the following commands in an R session:


```r
install_github("hms-dbmi/EHRtemporalVariability")
library( EHRtemporalVariability )
```

## S4 objects 

### `DataTemporalMap`

The `DataTemporalMap` object contains the statistical distributions of data estimated at a specific time period. 




```r
class( probMaps$`diagcode1-phewascode` )
```

```
## [1] "DataTemporalMap"
## attr(,"package")
## [1] "EHRtemporalVariability"
```
<br>
`DataTemporalMap` object is the output of `estimateDataTemporalMap` function. It is used as input for `plotDataTemporalMap` functions.

<br>
<span style="background-color:LemonChiffon">Note that objects of this class can be generated automatically by the `estimateDataTemporalMap` function, but its construction and extension is open towards fostering its use through external methods. E.g., one may use additional probability distribution estimation methods, or even contruct compatible `DataTemporalMap` object for other unstructured data shuch as images or free text.</span>

### `IGTProjection`

The `IGTProjection` object contains the projected non-parametric statistical manifold of a `DataTemporalMap` object (also included in the object) estimated in a specific number of dimensions.


```r
class( igtProjs$`diagcode1-phewascode` )
```

```
## [1] "IGTProjection"
## attr(,"package")
## [1] "EHRtemporalVariability"
```
<br>
`IGTProjection` object is the output of `estimateIGTProjection` function. It is used as input for `plotIGTProjection` functions.

<br>
<span style="background-color:LemonChiffon">Note that objects of this class are generated automatically by the `estimateIGTProjection` function.</span>

# Data pre-processing 

## Load the CSV input file 
The first step consists on read the CSV file that contains the data for the analysis. To do it, the user can apply the `read.csv` function.

The `read.csv` function reads a file in table format and creates a data frame from it, with cases corresponding to lines and variables to fields in the file. It is important to define the class of each column when reading the CSV file. 

An example of how to read the CSV file is shown next:


```r
dataset <- read.csv2( "http://github.com/hms-dbmi/EHRtemporalVariability-DataExamples/raw/master/nhdsSubset.csv", 
                      sep  = ",",
                      header = TRUE, 
                      na.strings = "", 
                      colClasses = c( "character", "numeric", "factor",
                                      "numeric" , rep( "factor", 22 ) ) )
head( dataset)
```

```
##    date age sex newborn race marital disstatus dayscare lengthflag region
## 1 00/01   0   2       1    2       9         1        8          1      1
## 2 00/01  53   1       2    6       9         1        8          1      1
## 3 00/01  49   1       2    2       9         1        6          1      1
## 4 00/01  76   2       2    1       9         3       53          1      1
## 5 00/01  53   2       2    2       9         1        3          1      1
## 6 00/01  38   2       2    2       9         1        6          1      1
##   hospbeds hospownership diagcode1 diagcode2 diagcode3 diagcode4 diagcode5
## 1        4             2     V3101     76518     V298-     V053-       N/A
## 2        4             2     2252-     78039     25000       N/A       N/A
## 3        4             2     29181     30391     4019-       N/A       N/A
## 4        4             2     29532     49390     700--       N/A       N/A
## 5        4             2     2967-     V08--       N/A       N/A       N/A
## 6        4             2     30421     30391       N/A       N/A       N/A
##   diagcode6 diagcode7 proccode1 proccode2 proccode3 proccode4 princpayment
## 1       N/A       N/A      9955      9921       N/A       N/A            8
## 2       N/A       N/A      0159      9921       N/A       N/A            8
## 3       N/A       N/A      9462       N/A       N/A       N/A            3
## 4       N/A       N/A      8622      9423      9439      9394            2
## 5       N/A       N/A      9411      9423      9438       N/A            8
## 6       N/A       N/A      9468       N/A       N/A       N/A            3
##   secondpayment drg
## 1            NA 388
## 2            NA   1
## 3            NA 435
## 4             6 424
## 5            NA 430
## 6            NA 435
```

## Transform the date column in 'Date' R format
The second step will be transform the date column in 'Date' R format. The `EHRtemporalVariability` R package allows the user to do this transformation applying the `formatDate` function.

The `formatDate` function transform the column containing the dates from the given data.frame input, using the following arguments:

  - _input_: a data.frame object with at least one column of dates.
  - _dateColumn_: the name of the column containing the date.
  - _dateFormat_: the date format as standard in R Dates, by default '%y/%m/%d'.

The `formatDate` function output is the same data.frame with the date column transformed.


```r
class( dataset$date )
```

```
## [1] "character"
```

```r
datasetFormatted <- EHRtemporalVariability::formatDate(
              input         = dataset,
              dateColumn    = "date",
              dateFormat = "%y/%m"
             )
head( datasetFormatted )[1:5, 1:5]
```

```
##         date age sex newborn race
## 1 2000-01-01   0   2       1    2
## 2 2000-01-01  53   1       2    6
## 3 2000-01-01  49   1       2    2
## 4 2000-01-01  76   2       2    1
## 5 2000-01-01  53   2       2    2
```

```r
class( datasetFormatted$date )
```

```
## [1] "Date"
```

## Transform the ICD9-CM into PheWAS codes
Once the CSV file has been readed and the date column transformed, the third step is to transform the ICD9-CM to PheWAS codes if needed (https://phewascatalog.org/) [@denny2013systematic]. 

<span style="background-color:LemonChiffon">This step is not mandatory, is an option for those analysis in which ICD9-CM are analyzed and want to be reduced and transformed into PheWAS codes.</span>  

The `EHRtemporalVariability` R package allows the user to do the mapping in an automatic way applying the `icd9toPheWAS` function.

The `icd9toPheWAS` map to PheWAS codes using as input a column containing ICD9-CM codes. This function has as input the following arguments:

  - _data_: a data.frame object with at least one column of ICD9-CM codes that one to be transformed into a PheWAS code.
  - _icd9ColumnName_: the name of the column containing the ICD9-CM.
  - _missingValues_: the value used to determine missing values in the data.frame.
  - _phecodeDescription_: an optional argument to determine if instead to mapping to the PheWAS code, the user is interested in mapping to the PheWAS code description. 
  - _replaceColumn_: an optional argument to determine if you want to replace the ICD9-CM codes column or if you want to generate a new one for the PheWAS codes. 
  - _statistics_: if TRUE, shows the summary of the mapping like the percentage of initial ICD9-CM codes mapped to PheWAS code.
  - _replaceColumn_: whether to replace the original ICD9-CM column with the PheWAS codes or, if FALSE, create a new column with the PheWAS code.


The `icd9toPheWAS` function output is the ICD9-CM column transformed into PheWAS codes. In this specific "NHDS" example we will create a new column with the PheWAS codes that map to the diagcode2 column in the original data.frame. 


```r
datasetPheWAS <- icd9toPheWAS(data           = datasetFormatted,
                              icd9ColumnName = "diagcode1",
                              phecodeDescription = TRUE,
                              missingValues  = "N/A", 
                              statistics     = TRUE, 
                              replaceColumn  = FALSE)

head( datasetPheWAS[, c( "diagcode1", "diagcode1-phewascode")] )
```

```
##   diagcode1              diagcode1-phewascode
## 1     V3101                Multiple gestation
## 2     2252-                 ICD9codeNotMapped
## 3     29181                        Alcoholism
## 4     29532                     Schizophrenia
## 5     2967-                 ICD9codeNotMapped
## 6     30421 Substance addiction and disorders
```

# Data analysis

## Estimate data temporal map
The `estimateDataTemporalMap` function estimates a `DataTemporalMap` object from a data.frame containing individuals in rows and the variables in columns, being one of these columns the analysis date. This function has as input the following arguments:

  - _data_: a data.frame containing as many rows as individuals, and as many columns as the analysis variables plus the individual acqusition date.
  - _dateColumnName_: a string indicating the name of the column in data containing the analysis date variable.
  - _period_ : the period at which to batch data for the analysis from "week", "month" and "year", with "month" as default.

Additionally this function has the following optional arguments:

  - _startDate_: a Date object indicating the date at which to start the analysis. By default the first chronological date in the date column will be selected.
  - _endDate_: a Date object indicating the date at which to end the analysis. By default the last chronological date in the date column will be selected. 
  - _supports_: a List of objects containing the support of the data distributions for each variable, in classes `numeric`, `integer`, `character`, or `factor` (accordingly to the variable type), and where the name of the list element must correspond to the column name of its variable. If not provided it is automatically estimated from data.
  - _numericVariablesBins_: the number of bins at which to define the frequency histogram for numerical variables. By default is set to 100.
  - _numericSmoothing_: a logical value indicating whether a Kernel Density Estimation smoothing (Gaussian kernel, default bandwith) is to be applied on numerical variables (the default) or a traditional histogram instead.
  - _dateGapsSmoothing_: a logical value indicating whether a linear smoothing is applied to those time batches without data, by default gaps are filled with NAs.

The `estimateDataTemporalMap` function output is a `DataTemporalMap` object or a list of `DataTemporalMap` objects depending on the number of analysis variables.


```r
probMaps <- estimateDataTemporalMap(data           = datasetPheWAS, 
                                    dateColumnName = "date", 
                                    period         = "month")
```

In the previous specific example, nhds data frame is used as input, with the `date` column previously formated to `Date` format. The `estimateDataTemporalMap` function has been applied to the X variables present in the initial data set. As a result, a list of X `DataTemporalMap` objects is obtained.


```r
class( probMaps )
```

```
## [1] "list"
```

```r
class( probMaps[[ 1 ]] )
```

```
## [1] "DataTemporalMap"
## attr(,"package")
## [1] "EHRtemporalVariability"
```

Variable supports can be set manually for all or some of the variables using the `support` parameter. The support of those variables not present in the `support` parameter will be estimated automatically as when the parameter is not passed.


```r
supports <- vector("list",2)
names(supports) <- c("age","diagcode1")
supports[[1]] <- 1:18
supports[[2]] <- c("V3000","042--","07999","1550-","2252-")
probMapsWithSupports <- estimateDataTemporalMap(data           = datasetPheWAS, 
                                    dateColumnName = "date", 
                                    period         = "month",
                                    supports       = supports)
```

## Trim a DataTemporalMap object
Additionally, the `EHRtemporalVariability` R package contains a function that allows the user to trim any `DataTemporalMap` object according to a start and end date. 

The `trimDataTemporalMap` function needs as input the following arguments:

  - _dataTemporalMap_: a `DataTemporalMap` object.
  - _startDate_: a date indicating the start date to trim from.
  - _endDate_: a date indicating the end date to trim from.


The `trimDataTemporalMap` function output is a new `DataTemporalMap` object.


```r
class( probMaps[[1]] )
```

```
## [1] "DataTemporalMap"
## attr(,"package")
## [1] "EHRtemporalVariability"
```

```r
probMapTrimmed <- trimDataTemporalMap( 
                        dataTemporalMap = probMaps[[1]],
                        startDate       = "2005-01-01",
                        endDate         = "2008-12-01"
                                      )
class( probMapTrimmed )
```

```
## [1] "DataTemporalMap"
## attr(,"package")
## [1] "EHRtemporalVariability"
```


## Estimate IGT projections
The `estimateIGTProjection` function estimates a `IGTProjection` object from a `DataTemporalMap` object. This function has as input the following arguments:

  - _dataTemporalMap_: a `DataTemporalMap` object.
  - _dimensions_: integer value indicating the number of dimensions for the projection.
  - _startDate_: a Date object indicating the date at which to start the analysis, in case of being different from the first chronological date in the date column (the default).
  - _endDate_: a Date object indicating the date at which to end the analysis, in case of being different from the last chronological date in the date column (the default).
  - _embeddingType_: the type of embedding in order to obtain the non-parametric Statistical Manifold, from `classicalmds` and `nonmetricmds`, with `classicalmds` as default. 


The `estimateIGTProjection` function output is a `IGTProjection` object.


```r
igtProj <- estimateIGTProjection( dataTemporalMap = probMaps[[1]], 
                                  dimensions      = 2, 
                                  startDate       = "2000-01-01", 
                                  endDate         = "2010-12-31")
```

The `estimateIGTProjection` function can be applied to one `DataTemporalMap` object. As a result, an `IGTProjection` object is obtained.


```r
class( igtProj )
```

```
## [1] "IGTProjection"
## attr(,"package")
## [1] "EHRtemporalVariability"
```

The `sapply` function can be used to apply the `estimateIGTProjection` function to the output from `estimateDataTemporalMap` function including more than one variable, which result is a list of `DataTemporalMap` objects, as follows:


```r
igtProjs <- sapply ( probMaps, estimateIGTProjection )
names( igtProjs ) <- names( probMaps )
```

# Data visualization
`EHRtemporalVariability` offers two different options to visualize the results, heatmaps and Information Geometric Temporal (IGT) plots. An special focus is made on visualization colors. 

<span style="background-color:LemonChiffon">The default "Spectral" palette shows a color temperature scheme from blue, through yellow, to red. The four remaining options are better suited for those with colorblindness, including "Viridis", "Magma", and their reversed versions "Viridis-reversed" and "Magma-reversed".</span>

## Plot data temporal maps
The `plotDataTemporalMap` function returns a heatmap plot.  This function has as input the following arguments:

  - _dataTemporalMap_: the `DataTemporalMap` object.
  - _absolute_: inidicates if the heatmap frequency values are absolute or relative. By default FALSE.  
  - _startValue_: indicates the first value to display in the heatmap. By default 1. 
  - _endValue_: indicates the last value to display in the heatmap. By default the last value of the DataTemporalMap object.  
  - _startDate_: a Date object indicating the first date to be displayed in the heatmap. By default the first date of the DataTemporalMap object. 
  - _endDate_: a Date object indicating the last date to be displayed in the heatmap. By default the last date of the DataTemporalMap object.
  - _sortingMethod_: the method to sort data in the Y axis of the heatmap from "frequency" and "alphabetical", with "frequency" as default.
  - _colorPalette_: the color palette to be used. 

To illustrate the next examples we load the example .Rdata file, which contains the results from analyzing the complete "NHDS" dataset.


```r
githubURL <- "https://github.com/hms-dbmi/EHRtemporalVariability-DataExamples/raw/master/variabilityDemoNHDS.RData"
load(url(githubURL))
```















