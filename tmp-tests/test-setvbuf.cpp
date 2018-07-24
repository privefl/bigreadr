#include <Rcpp.h>
using namespace Rcpp;

#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <stdlib.h>

#define BUFLEN (64 * 1024)

// [[Rcpp::export]]
int test_setvbuf(std::string filename, int size = 100) {

  FILE *fp = fopen(filename.c_str(), "r");

  unsigned sizem1 = size - 1;
  int last = size - 2;

  char line[size];
  // char *id;
  // char *token;
  char *buf = (char*)malloc(BUFLEN);
  int c = 0;

  setvbuf ( fp , buf , _IOLBF, BUFLEN );
  while (fgets(line, size, fp) != NULL) {
    // Rcout << strlen(line) << std::endl;
    if (strlen(line) < sizem1) {
      c++;
    } else {
      // Rcout << (line[last] == '\n') << std::endl;
      if (line[last] == '\n') c++;
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

  fclose(fp);

  return c;

}

// [[Rcpp::export]]
int test_setvbuf2(std::string filename, int size = 100) {

  FILE *fp = fopen(filename.c_str(), "r");

  unsigned sizem1 = size - 1;
  int last = size - 2;

  char * line = new char[size];
  char * temp;
  // char *id;
  // char *token;
  // char *buf = (char*)malloc(BUFLEN);
  int c = 0;

  setvbuf ( fp , NULL , _IOLBF, BUFLEN );
  while (fgets(line, size, fp) != NULL) {
    // Rcout << strlen(line) << std::endl;
    if (strlen(line) < sizem1) {
      c++;
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

  fclose(fp);

  return c;

}

/*** R
test_setvbuf("text-write.txt")
test_setvbuf2("text-write.txt")
*/
