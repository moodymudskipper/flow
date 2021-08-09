## Test environments
* local R installation, R 4.0.2
* ubuntu 16.04 (on travis-ci), R 4.0.2
* win-builder (devel)

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

## Answering Julia Haider's comments 2021-04-26

* Details about package functionality implemented methods wered added to description text.
* All exported functions' documentation feature a \value field
* Examples have been added for all exported functions, excepted for `flow_doc` and 
  `flow_test` which respectively take considerable time to run (usually more than a 
  minute), and is designed to be used during package development. they are however 
  reviewed, including examples, in a vignette mentioned their respective help files.
* installed.packages() is not used anymore

A request was made not to modify the global environment (e.g. by using <<-,
.GlobalEnv) in functions, but neither of these objects are used and I don't
believe the package modifies the global environment.

