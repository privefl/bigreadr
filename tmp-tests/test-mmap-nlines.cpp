// [[Rcpp::depends(rmio)]]
// [[Rcpp::plugins(cpp11)]]
#include <mio/mmap.hpp>
#include <system_error> // for std::error_code
#include <Rcpp.h>

using std::size_t;


// [[Rcpp::export]]
double nlines_mmap(std::string path) {

  // Memory-map the file
  std::error_code error;
  mio::ummap_source ro_ummap;
  ro_ummap.map(path, error);
  if (error) Rcpp::stop("Error when mapping file:\n  %s.\n", error.message());

  int nlines = std::count_if(ro_ummap.begin(), ro_ummap.end(),
                             [](unsigned char x) { return x == '\n'; });

  size_t nbytes = ro_ummap.size();
  // size_t nlines = 0;
  // for (size_t k = 0; k < nbytes; k++) {
  //   if (ro_ummap[k] == '\n') nlines++;
  // }

  if (ro_ummap[nbytes - 1] != '\n') nlines++;

  return nlines;
}

// [[Rcpp::export]]
double nlines_mmap2(std::string path) {

  // Memory-map the file
  std::error_code error;
  mio::ummap_source ro_ummap;
  ro_ummap.map(path, error);
  if (error) Rcpp::stop("Error when mapping file:\n  %s.\n", error.message());

  size_t nbytes = ro_ummap.size();
  size_t nlines = 0;
  for (size_t k = 0; k < (nbytes - 4); k += 4) {
    nlines += ((ro_ummap[k] == '\n') + (ro_ummap[k + 1] == '\n')) +
      ((ro_ummap[k + 2] == '\n') + (ro_ummap[k + 3] == '\n'));
  }

  // TODO: add the test and test that more than 4 bytes

  if (ro_ummap[nbytes - 1] != '\n') nlines++;

  return nlines;
}

/*** R
nlines_mmap("../tmp-data/cars.csv.bk")
nlines_mmap2("../tmp-data/cars.csv.bk")
*/
