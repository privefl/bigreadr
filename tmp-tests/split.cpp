#include <bigstatsr/BMAcc.h>

#define BUFLEN (64 * 1024)

// [[Rcpp::export]]
NumericVector test_setvbuf7(std::string filename,
                            std::string filename2,
                            int every_nlines,
                            Environment parts_) {

  XPtr<FBM> xptr = parts_["address"];
  BMAcc<int> parts(xptr);

  FILE *fp_in = fopen(filename.c_str(), "rb"), *fp_out;
  setvbuf(fp_in, NULL, _IOLBF, BUFLEN);

  const char *fn_out = filename2.c_str();
  char name_out[strlen(fn_out) + 20];

  size_t line_size;
  size_t size = 100;
  size_t last = size - 2;

  char *line = new char[size];
  char *temp;

  bool not_eol, not_eof = true;
  int i, k = 0, c = 0;


  while (not_eof) {

    // Open file number 'k'
    sprintf(name_out, "%s%d.txt", fn_out, ++k);
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
        temp = new char[size];
        delete [] line;
        line = temp;
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
    parts(k - 1, 0) = 1;  // OK to porcess
    Rcout << k << std::endl;

  }

  fclose(fp_in);

  return NumericVector::create(_["K"] = k, _["every"] = every_nlines, _["N"] = c);
}

