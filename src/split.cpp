/******************************************************************************/

#include <Rcpp.h>
using namespace Rcpp;

#define BUFLEN (64 * 1024)

/******************************************************************************/

// [[Rcpp::export]]
List split_every_nlines(std::string name_in,
                        std::string prefix_out,
                        int every_nlines) {

  FILE *fp_in = fopen(name_in.c_str(), "rb"), *fp_out;
  setvbuf(fp_in, NULL, _IOLBF, BUFLEN);

  const char *fn_out = prefix_out.c_str();
  char *name_out = new char[strlen(fn_out) + 20];

  size_t line_size;
  size_t size = 100;
  size_t last = size - 2;

  char *line = new char[size];

  bool not_eol, not_eof = true;
  int i, k = 0, c = 0;


  while (not_eof) {

    // Open file number 'k'
    sprintf(name_out, "%s_%d.txt", fn_out, ++k);
    fp_out = fopen(name_out, "wb");
    setvbuf(fp_out, NULL, _IOFBF, BUFLEN);

    // Fill it with 'every_nlines' lines
    i = 0;
    while (i < every_nlines) {

      if (fgets(line, size, fp_in) == NULL) {
        not_eof = false;
        break;
      }

      line_size = strlen(line);

      fputs(line, fp_out);

      if (line_size > last) {

        not_eol = (line[last] != '\n');

        fflush(fp_out);
        size *= 2;
        delete[] line;
        line = new char[size];
        last = size - 2;

        if (not_eol) continue;
      }

      // End of line
      i++;

    }

    c += i;

    // Close file number 'k'
    fflush(fp_out);
    fclose(fp_out);
    if (i == 0) {
      // nothing has been written because of EOF -> rm file
      remove(name_out);
      k--;
    }

  }

  fclose(fp_in);

  delete[] name_out;
  delete[] line;

  return List::create(
    _["name_in"]     = name_in,
    _["prefix_out"]  = prefix_out,
    _["nfiles"]      = k,
    _["nlines_part"] = every_nlines,
    _["nlines_all"]  = c
  );
}

/******************************************************************************/
