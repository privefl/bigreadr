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

  size_t size = 100;
  size_t last = size - 2;

  char *line = new char[size];

  // read header once and store it
  line = fgets_full_line(line, fp_in, &size, &last);
  char *head = new char[size];
  strcpy(head, line);
  rewind(fp_in);

  bool not_eof = true, header_added = false;
  int k = 0, c = 0;

  while (not_eof) {

    // Open file number 'k'
    sprintf(name_out, "%s_%d.txt", fn_out, ++k);
    fp_out = fopen(name_out, "wb");
    setvbuf(fp_out, NULL, _IOFBF, BUFLEN);

    // Fill it with 'every_nlines' lines
    int i = 0;
    while (i < every_nlines) {

      if ( (line = fgets_full_line(line, fp_in, &size, &last)) == NULL ) {
        not_eof = false;
        break;
      }

      if (repeat_header & (i == 0) & (k > 1)) {
        fputs(head, fp_out);
        header_added = true;
      };

      fputs(line, fp_out);
      i++;
    }

    // Close file number 'k'
    fflush(fp_out);
    fclose(fp_out);
    if (i == 0) {
      // nothing has been written because of EOF -> rm file
      remove(name_out);
      k--;
    } else {
      c += i + header_added;
    }
  }

  fclose(fp_in);

  delete[] name_out;
  delete[] line;
  delete[] head;

  return List::create(
    _["name_in"]       = name_in,
    _["prefix_out"]    = prefix_out,
    _["nfiles"]        = k,
    _["nlines_part"]   = every_nlines,
    _["nlines_all"]    = c,
    _["repeat_header"] = repeat_header
  );
}

/******************************************************************************/
