/******************************************************************************/

#include <Rcpp.h>

/******************************************************************************/

//' Number of lines
//'
//' Get the number of lines of a file.
//'
//' @param file Path of the file.
//'
//' @return The number of lines as one integer.
//' @export
//'
//' @examples
//' tmp <- fwrite2(iris)
//' nlines(tmp)
// [[Rcpp::export]]
double nlines(std::string file) {

  FILE *fp_in = fopen(file.c_str(), "r");
  if (fp_in == NULL) Rcpp::stop("Error while reading file '%s'.", file);

  size_t size = 100;
  size_t last = size - 2;

  char *line = new char[size];
  size_t c = 0;
  bool not_eol;

  while (fgets(line, size, fp_in) != NULL) {

    if (strlen(line) > last) {

      not_eol = (line[last] != '\n');

      // increase size of line
      size *= 2;
      last = size - 2;

      delete [] line;
      line = new char[size];

      if (not_eol) continue;
    }

    c++;  // one more line
  }

  fclose(fp_in);
  delete [] line;

  return c;
}

/******************************************************************************/
