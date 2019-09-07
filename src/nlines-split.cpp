/******************************************************************************/

#include <Rcpp.h>
using namespace Rcpp;

#define BUFLEN (64 * 1024)

/******************************************************************************/

char * fgets_full_line(char * str, FILE * stream,
                       size_t * p_size, size_t * p_last) {

  bool reached_eol = false;

  while (!reached_eol) {

    str = fgets(str, *p_size, stream);
    if (str == NULL) return NULL;

    if (strlen(str) > *p_last) {

      reached_eol = (str[*p_last] == '\n');

      // increase size of str
      fseek(stream , 1 - *p_size, SEEK_CUR);
      *p_size *= 2;
      *p_last = *p_size - 2;

      delete [] str;
      str = new char[*p_size];

    } else {
      reached_eol = true;
    }
  }

  return str;
}

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
//'
// [[Rcpp::export]]
double nlines(std::string file) {

  FILE *fp_in = fopen(file.c_str(), "r");
  if (fp_in == NULL) Rcpp::stop("Error while reading file '%s'.", file);

  size_t size = 100;
  size_t last = size - 2;

  char *line = new char[size];
  size_t c = 0;

  while ( (line = fgets_full_line(line, fp_in, &size, &last)) != NULL ) {
    c++;
  }

  fclose(fp_in);
  delete [] line;

  return c;
}

/******************************************************************************/

// [[Rcpp::export]]
List split_every_nlines(std::string name_in,
                        std::string prefix_out,
                        int every_nlines,
                        bool repeat_header) {

  FILE *fp_in = fopen(name_in.c_str(), "rb"), *fp_out;
  setvbuf(fp_in, NULL, _IOLBF, BUFLEN);

  const char *fn_out = prefix_out.c_str();
  char *name_out = new char[strlen(fn_out) + 20];

  size_t line_size;
  size_t size = 100;
  size_t last = size - 2;

  char *line = new char[size];

  // when repeating the header
  char *head = new char[size];

  bool not_eol, not_eof = true;
  int i, k = 0, c = 0;

  bool copied_header = false;

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

      if (repeat_header) {

        if ((i == 0) & copied_header)
          fputs(head, fp_out);

        if (!copied_header) {
          strcpy(head, line);
          copied_header = true;
        }
      }

      fputs(line, fp_out);

      line_size = strlen(line);
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
  delete[] head;

  return List::create(
    _["name_in"]     = name_in,
    _["prefix_out"]  = prefix_out,
    _["nfiles"]      = k,
    _["nlines_part"] = every_nlines,
    _["nlines_all"]  = c
  );
}

/******************************************************************************/