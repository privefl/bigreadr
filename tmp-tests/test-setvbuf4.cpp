#include <Rcpp.h>
using namespace Rcpp;

#define BUFLEN (64 * 1024)

// [[Rcpp::export]]
int test_setvbuf5(std::string filename, std::string filename2) {

  FILE *fp_in = fopen(filename.c_str(), "rb"), *fp_out;
  setvbuf(fp_in, NULL, _IOLBF, BUFLEN);

  const char *fn_out = filename2.c_str();
  char name_out[strlen(fn_out) + 20];

  size_t line_size;
  size_t size = 100;
  size_t last = size - 2;

  char *line = new char[size];
  char *temp;
  int c = 0;
  bool not_eol;

  sprintf(name_out, "%s%d.txt", fn_out, c);
  fp_out = fopen(name_out, "wb");
  setvbuf(fp_out, NULL, _IOFBF, BUFLEN);

  while (fgets(line, size, fp_in) != NULL) {

    line_size = strlen(line);

    fputs(line, fp_out);

    if (line_size > last) {

      not_eol = (line[last] != '\n');

      fflush(fp_out);
      size *= 2;
      temp = new char[size];
      delete [] line;
      line = temp;
      last = size - 2;

      if (not_eol) continue;
    }

    // End of line
    c++;
    fflush(fp_out);
    fclose(fp_out);
    sprintf(name_out, "%s%d.txt", fn_out, c);
    fp_out = fopen(name_out, "wb");
    setvbuf(fp_out, NULL, _IOFBF, BUFLEN);

  }

  fflush(fp_out);
  fclose(fp_out); // last one has nothing inside
  fclose(fp_in);

  return c;
}

/*** R
test_setvbuf5("text-write.txt", "tmp/text-write-part")
readLines("text-write.txt")[[6]]
readLines("tmp/text-write-part5.txt")
*/
