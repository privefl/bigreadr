#include <Rcpp.h>

#define BUFLEN (64 * 1024)

// [[Rcpp::export]]
int test_setvbuf4(std::string filename, std::string filename2) {

  FILE *fp_in  = fopen(filename.c_str(),  "rb");
  FILE *fp_out = fopen(filename2.c_str(), "wb");

  size_t line_size;
  size_t size = 100;
  size_t last = size - 2;

  char *line = new char[size];
  char *temp;
  int c = 0;
  bool not_eol;

  setvbuf(fp_in,  NULL, _IOLBF, BUFLEN);
  setvbuf(fp_out, NULL, _IOFBF, BUFLEN);

  while (fgets(line, size, fp_in) != NULL) {

    line_size = strlen(line);

    fputs(line, fp_out);

    if (line_size > last) {

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
  fflush(fp_out);
  fclose(fp_out);

  return c;
}

/*** R
test_setvbuf4("text-write.txt", "text-write2.txt")
*/
