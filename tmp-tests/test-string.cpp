#include <Rcpp.h>
using namespace Rcpp;

#define BUFLEN (64 * 1024)

// [[Rcpp::export]]
void test_string(std::string filename) {

  const char *fn = filename.c_str();
  char name_out[strlen(fn) + 20];

  for (int k = 1; k < 10; k++) {
    sprintf(name_out, "%s%d.txt", fn, k);
    Rcout << filename << std::endl;
    Rcout << name_out << std::endl;
  }
}

/*** R
test_string(tempfile())
*/
