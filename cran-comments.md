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
  
 * THIS IS A RESUBMISSION *
 Revier comments:
 Tanks, please omit the redundant "The goal of diffEnrich is to". Rather,
is there some reference about the method you can add in the Description
field in the form Authors (year) <doi:.....>?

OLD:"The goal of diffEnrich is to compare functional enrichment between two experimentally-derived groups of genes or proteins."

UPDATED: "Compare functional enrichment between two experimentally-derived groups of genes or proteins (Peterson, DR., et al.(2018)) <doi: 10.1371/journal.pone.0198139>."
