# EHRtemporalVariability

`EHRtemporalVariability` is an R package for delineating reference changes in Eletronic Health Records over time

## What is this repository for?

The `EHRtemporalVariability` package contains functions to delineate reference changes over time in Electronic Health Records through the projection and visualization of dissimilarities among data temporal batches. This is done through the estimation of data statistical distributions over time and their projection in non-parametric statistical manifolds uncovering the patterns of the data latent temporal variability. Results can be explored through visual analytics formats such as Data Temporal heatmaps and Information Geometric Temporal (IGT) plots [1,2]. An additional [EHRtemporalVariability Shiny app](https://github.com/hms-dbmi/variability-shiny) can be used to load and explore the package results and even to allow the use of these functions to those users non-experienced in R coding.

## Package' Status

 * __Version__: 1.0
 * __Authors__: Carlos Sáez (UPV-HMS), Alba Gutiérrez-Sacristán (HMS), Paul Avillach (HMS), Juan M García-Gómez (UPV)
 * __Maintainer__: Carlos Saez (UPV-HMS)
 
 Copyright: 2019 - Biomedical Data Science Lab, Universitat Politècnica de València, Spain (UPV) - Department of Biomedical Informatics, Harvard Medical School (HMS)
 
## Documentation

 * [Vignette](http://htmlpreview.github.com/?https://github.com/hms-dbmi/EHRtemporalVariability/master/vignettes/EHRtemporalVariability.html)


[1]: Sáez C, Rodrigues PP, Gama J, Robles M, García-Gómez JM. Probabilistic change detection and visualization methods for the assessment of temporal stability in biomedical data quality. Data Mining and Knowledge Discovery. 2015;29:950–75.

[2]: Sáez C, Zurriaga O, Pérez-Panadés J, Melchor I, Robles M, García-Gómez JM. Applying probabilistic temporal and multisite data quality control methods to a public health mortality registry in spain: A systematic approach to quality control of repositories. Journal of the American Medical Informatics Association. 2016;23:1085–95.

[3]: Sáez C, García-Gómez JM. Kinematics of Big Biomedical Data to characterize temporal variability and seasonality of data repositories: Functional Data Analysis of data temporal evolution over non-parametric statistical manifolds. International Journal of Medical Informatics. 2018;119:109–24.
