## Release summary

Initial release of the package.

## R CMD check results

0 errors | 0 warnings | 2 notes

* This is a new release.

---

checking installed package size ... NOTE
  installed size is 10.2Mb
  sub-directories of 1Mb or more:
    doc       4.9Mb
    extdata   5.1Mb


The examples of a large dataset were reduced to a minimum size to be used within-package. Examples on larger datasets were moved to GitHub links and illustrated as examples not to be run.
Documentation includes an html Vignette with two dynamic plotly plots.

---

 checking Rd line widths ... NOTE
Rd file 'estimateDataTemporalMap-methods.Rd':
  examples lines wider than 100 characters:
     inputFile <- "http://github.com/hms-dbmi/EHRtemporalVariability-DataExamples/raw/master/nhdsSubset.csv"

Rd file 'estimateIGTProjection-methods.Rd':
  examples lines wider than 100 characters:
     githubURL <- "https://github.com/hms-dbmi/EHRtemporalVariability-DataExamples/raw/master/variabilityDemoNHDS.RData"

Rd file 'plotDataTemporalMap-methods.Rd':
  examples lines wider than 100 characters:
     githubURL <- "https://github.com/hms-dbmi/EHRtemporalVariability-DataExamples/raw/master/variabilityDemoNHDS.RData"

Rd file 'plotIGTProjection-methods.Rd':
  examples lines wider than 100 characters:
     githubURL <- "https://github.com/hms-dbmi/EHRtemporalVariability-DataExamples/raw/master/variabilityDemoNHDS.RData"   

These are the links to the larger datasets in GitHub. They appear correctly in the in-program help.

## Reverse dependencies

This is a new release, so there are no reverse dependencies.


* All revdep maintainers were notified of the release on 2019/03/04.
