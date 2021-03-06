# pure R
require(Rccp)
require(RccpArmadillo)

# EXAMPLE FROM Dirk Eddelbuettel

 ## parameter and error terms used throughout
 a <- matrix(c(0.5,0.1,0.1,0.5),nrow=2)
 e <- matrix(rnorm(10000),ncol=2)
 ## Let's start with the R version
 rSim <- function(coeff, errors) {
   simdata <- matrix(0, nrow(errors), ncol(errors))
   for (row in 2:nrow(errors)) {
     simdata[row,] = coeff %*% simdata[(row-1),] + errors[row,]
   }
   return(simdata)
 }
rData <- rSim(a, e)       

 ## Now let's load the R compiler (requires R 2.13 or later)
 suppressMessages(require(compiler))
 compRsim <- cmpfun(rSim)
 compRData <- compRsim(a,e)              # generated by R 'compiled'
 stopifnot(all.equal(rData, compRData))  # checking results


 ## Now load 'inline' to compile C++ code on the fly
 suppressMessages(require(inline))
 code <- '
  arma::mat coeff = Rcpp::as<arma::mat>(a);
  arma::mat errors = Rcpp::as<arma::mat>(e);
  int m = errors.n_rows; int n = errors.n_cols;
  arma::mat simdata(m,n);
  simdata.row(0) = arma::zeros<arma::mat>(1,n);
  for (int row=1; row<m; row++) {
    simdata.row(row) = simdata.row(row-1)*trans(coeff)+errors.row(row);
  }
  return Rcpp::wrap(simdata);
'
 ## create the compiled function
 rcppSim <- cxxfunction(signature(a="numeric",e="numeric"),
                       code,plugin="RcppArmadillo")
 rcppData <- rcppSim(a,e)                # generated by C++ code
 stopifnot(all.equal(rData, rcppData))   # checking results

 ## now load the rbenchmark package and compare all three
 suppressMessages(library(rbenchmark))
 res <- benchmark(rcppSim(a,e),
                 rSim(a,e),
                 compRsim(a,e),
                 columns=c("test", "replications", "elapsed",
                           "relative", "user.self", "sys.self"),
                 order="relative")
 print(res)


# More specific adaptation

 ## parameter and error terms used throughout
 a <- matrix(c(0.5,0.1,2.76,0.5),nrow=2)
 e <- matrix(c(1,1),ncol=2)

## Let's start with the R version
 rSim <- function(e, a,n) {
   
   for (i in 1:n) {
     e = e %*% a 
   }
   return(e)
 }
rData <- rSim(e, a,n=1000)

 ## Now let's load the R compiler (requires R 2.13 or later)
 suppressMessages(require(compiler))
 compRsim <- cmpfun(rSim)
 compRData <- compRsim(e,a,n=1000)              # generated by R 'compiled'
 stopifnot(all.equal(rData, compRData))  # checking results


 ## Now load 'inline' to compile C++ code on the fly
 suppressMessages(require(inline))
 code <- '
  arma::mat A = Rcpp::as<arma::mat>(a);
  arma::mat E = Rcpp::as<arma::mat>(e);
  int n = 1001;
  for (int i=1; i<n; i++) {
    E = E*A;
  }
  return Rcpp::wrap(E);
'
 ## create the compiled function
 rcppSim <- cxxfunction(signature(a="numeric",e="numeric"),
                       code,plugin="RcppArmadillo")
 rcppData <- rcppSim(a,e)                # generated by C++ code
 stopifnot(all.equal(rData, rcppData))   # checking results

 ## now load the rbenchmark package and compare all three
 suppressMessages(library(rbenchmark))
 res <- benchmark(rcppSim(a,e),
                 rSim(e,a,n=1000),
                 compRsim(e,a,n=1000),
                 columns=c("test", "replications", "elapsed",
                           "relative", "user.self", "sys.self"),
                 order="relative")
 print(res)
