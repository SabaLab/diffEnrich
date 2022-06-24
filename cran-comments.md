## Test environments
* local OS X High Sierra, R 3.5.2
* ubuntu 14.04 (on travis-ci), R 3.5.2; 3.6.1
* OS X (on travis-ci), R 3.5.2; 3.6.1
* win-builder (devel and release)
* Windows Server 2012 R2 x64, R 3.6.1

## R CMD check results

0 errors | 0 warnings | 1 note

* ❯ checking CRAN incoming feasibility ... NOTE
  New maintainer:
    Harry Smith <harry.smith@cuanschutz.edu>
  Old maintainer(s):
    Harry Smith <harry.smith@ucdenver.edu>
  
 * THIS IS A VERSION UPDATE WITH BUG FIXES *
 -previous version: 0.1.0
 -current version 0.1.1
 Reason for new version: bug due to 'transparent' no longer a valid color option for
 ggplot2::scale_fill_gradient. This introduced an error in plotFoldEnrichment():
 
 Quitting from lines 379-381 (diffenrich_vignette.Rmd)
    Error: processing vignette 'diffenrich_vignette.Rmd' failed with diagnostics:
    need at least two non-NA values to interpolate
    --- failed re-building 'diffenrich_vignette.Rmd'
    
  SUMMARY: processing the following file failed:
  'diffenrich_vignette.Rmd'
    
  Error: Vignette re-building failed.
  Execution halted
  
  I fixed this by changing the 'transparent' color to 'white'. This seems to have
  resolved the issue. diffEnrich is now passing all checks. The 'new maintainer'
  NOTE is because I updated my email address.
  
   * THIS IS A VERSION UPDATE WITH BUG FIXES *
   -previous version: 0.1.0
 -current version 0.1.2
 
 Reason for version change:
 
Check: re-building of vignette outputs
Result: ERROR
    Error(s) in re-building vignettes:
     ...
    --- re-building 'diffenrich_vignette.Rmd' using rmarkdown
    Quitting from lines 161-163 (diffenrich_vignette.Rmd)
    Error: processing vignette 'diffenrich_vignette.Rmd' failed with diagnostics:
    cannot read from connection
    --- failed re-building 'diffenrich_vignette.Rmd'
    
    SUMMARY: processing the following file failed:
     'diffenrich_vignette.Rmd'
     
      Error: Vignette re-building failed.
    Execution halted
     
This led to discovering that the issue was the api path used in the function
.api_pull was failing using http.I fixed this bug by updating the api path to 
use https.

❯ checking CRAN incoming feasibility ... NOTE
  Maintainer: 'Harry Smith <harry.smith@ucdenver.edu>'
  - My email changed, so I updated it in the DESCRIPTION
  
 * THIS IS NOT A VERSION UPDATE. JUST FIXES FOR RESUBMISSION *
   
 I updated all URLs that moved
