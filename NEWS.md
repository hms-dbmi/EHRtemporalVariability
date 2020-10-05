# EHRtemporalVariability 1.1.2

* Added `webshot` package to suggest list in DESCRIPTION to avoid Vignette compilation issues.

# EHRtemporalVariability 1.1.1

* Fixed issues when plotting IGT projections trajectories by filtering by date or at weekly period.

# EHRtemporalVariability 1.1.0

* Added function `estimateIGTTrajectory` to estimate a trajectory of the information temporal evolution in a IGT projection by fitting a cubic smoothing spline.
* The `plotIGTProjection` function now allows plotting the information trajectory using the optional `trajectory` parameter.
* Updated the `estimateIGTProjection` function to allow non-metric multidimensional scaling in addition to classical. To do so use the new `embeddingType` function parameter.
* The dimensionality reduction loss for both non-metric (stress) and metric (1-GOF) multidimensional scaling is now returned by the `estimateIGTProjection` function.
* The vignette has been extended to describe how to interpret temporal changes in IGT projections. This included how to use clustering methods in IGT projections to help delinate temporal subgroups. Other updates related to this version were included too.
* Fixed warning in icd9toPheWAS when the input ICD-9 variable was a factor.
* Fixed a typo and a warning in the vignette.

# EHRtemporalVariability 1.0.4

* Fixed bug in the estimateDataTemporalMap function where an expected Date was POSIXt instead when using newer versions of zoo and R package.

# EHRtemporalVariability 1.0.3

* Fixed bug when plotting IGT projections at a weekly period.
* Removed no longer used plotly buttons to supress warnings.

# EHRtemporalVariability 1.0.2

* Description texts, references and vignette have been fixed and updated.

# EHRtemporalVariability 1.0.1

## Bug fixes

* Fixed help for the manual generation of a `DataTemporalMap` class using S4 `new()` constructor.
* Removed unnecessary imports to reduce installation load.

# EHRtemporalVariability 1.0.0

* Initial release.