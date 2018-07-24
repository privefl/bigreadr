#include <Rcpp.h>
using namespace Rcpp;

#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <stdlib.h>

#define BUFLEN (64 * 1024)

// [[Rcpp::export]]
int test_setvbuf3(std::string filename,
                  std::string filename2,
                  int size = 100) {

  FILE *fp_in = fopen(filename.c_str(), "r");
  FILE *fp_out = fopen(filename2.c_str(), "w");

  unsigned sizem1 = size - 1;
  int last = size - 2;

  char * line = new char[size];
  char * temp;
  // char *id;
  // char *token;
  // char *buf = (char*)malloc(BUFLEN);
  int c = 0;

  setvbuf ( fp_in , NULL , _IOLBF, BUFLEN );
  setvbuf ( fp_out , NULL , _IOFBF, BUFLEN );


  while (fgets(line, size, fp_in) != NULL) {

    fputs(line, fp_out);

    // Rcout << strlen(line) << std::endl;
    if (strlen(line) < sizem1) {
      c++;
      // if (c % 1000 == 1) fflush(fp_out);
    } else {
      // Rcout << (line[last] == '\n') << std::endl;
      if (line[last] == '\n') c++;
      size *= 2;
      temp = new char[size];
      delete [] line;
      line = temp;
      sizem1 = size - 1;
      last = size - 2;
    }

    // id = strtok(line, "\t");
    // token = strtok(NULL, "\t");
    //
    // char *fnout = malloc(strlen(id)+5);
    // fnout = strcat(fnout, id);
    // fnout = strcat(fnout, ".seq");
    //
    // fpout = fopen(fnout, "w");
    // setvbuf ( fpout , NULL , _IONBF , 0 );
    // fprintf(fpout, "%s", token);
    // fclose(fpout);
  }

  fclose(fp_in);
  fflush(fp_out);
  fclose(fp_out);

  return c;
}

/*** R
test_setvbuf3("text-write.txt", "text-write2.txt")
*/
