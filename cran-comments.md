## Test environments
* local OS X High Sierra, R 3.5.2
* ubuntu 14.04 (on travis-ci), R 3.5.2; 3.6.1
* OS X (on travis-ci), R 3.5.2; 3.6.1
* win-builder (devel and release)
* Windows Server 2012 R2 x64, R 3.6.1

## R CMD check results

0 errors | 0 warnings | 1 note

* ❯ checking CRAN incoming feasibility ... NOTE
  Maintainer: 'Harry Smith <harry.smith@ucdenver.edu>'
  
  New submission
  
  Found the following (possibly) invalid URLs:
  URL: http://www.jstor.org/stable/2346101
    From: inst/doc/diffenrich_vignette.html
    Status: 403
    Message: Forbidden
    --REASON: This artical requires a subscription.
  URL: https://github.com/SabaLab/diffEnrich
    From: DESCRIPTION
    Status: Error
    Message: libcurl error code 35:
      	error:1407742E:SSL routines:SSL23_GET_SERVER_HELLO:tlsv1 alert protocol version
    --REASON: Currently, this repo is private. We will make it public as soon as the package is accepted.
  URL: https://github.com/SabaLab/diffEnrich/issues
    From: DESCRIPTION
    Status: Error
    Message: libcurl error code 35:
      	error:1407742E:SSL routines:SSL23_GET_SERVER_HELLO:tlsv1 alert protocol version
    --REASON: Currently, this repo is private. We will make it public as soon as the package is accepted.
    
   Examples for get_kegg have been set to dont_run because they may take more than 5 seconds due to the connection to the KEGG REST API. They do however run successfully when the vingette builds.
