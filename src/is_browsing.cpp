#include <Rcpp.h>
#include <R.h>
#include <RInternals.h>

// [[Rcpp::export]]
Rcpp::LogicalVector is_browsing() {
  return Rf_countContexts(16,1) > 0;
}
