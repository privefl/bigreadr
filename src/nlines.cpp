#include <Rcpp.h>

#define BUFLEN (64 * 1024)


//' Count number of lines
//'
//' @param filename Path to the file.
//'
//' @export
//'
// [[Rcpp::export]]
double nlines(std::string filename) {

  FILE *fp_in = fopen(filename.c_str(), "rb");
  setvbuf(fp_in, NULL, _IOLBF, BUFLEN);

  size_t size = 100;
  size_t last = size - 2;

  char *line = new char[size];
  char *temp;
  size_t c = 0;
  bool not_eol;

  while (fgets(line, size, fp_in) != NULL) {

    if (strlen(line) > last) {

      not_eol = (line[last] != '\n');

      size *= 2;
      temp = new char[size];
      delete [] line;
      line = temp;
      last = size - 2;

      if (not_eol) continue;
    }

    // End of line
    c++;
  }

  fclose(fp_in);

  return c;
}
