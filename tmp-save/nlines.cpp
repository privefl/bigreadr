#include <Rcpp.h>

#define BUFSIZE (1024 * 1024)


//' Count number of lines
//'
//' @param filename Path to the file.
//'
//' @export
//'
// [[Rcpp::export]]
double nlines1(std::string filename) {

  FILE *fp_in = fopen(filename.c_str(), "rb");
  // setvbuf(fp_in, NULL, _IOLBF, BUFSIZE);

  size_t size = 100;
  size_t last = size - 2;

  char *line = new char[size];
  char *temp= NULL;
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

#include <iostream>
#include <fstream>
using namespace std;

int FileRead(istream& is, char* buff) {
  is.read(buff, BUFSIZE);
  return is.gcount();
}

// [[Rcpp::export]]
double nlines2(const char * filename) {

  ifstream ifs(filename, ios::in | ios::binary);

  char *buff = new char[BUFSIZE];

  size_t nlines = 0;
  while (int cc = FileRead(ifs, buff)) {
    nlines += std::count(buff, buff + cc, '\n');
  }

  delete [] buff;

  return nlines;
}

// [[Rcpp::export]]
double nlines3(const char * filename) {

  FILE *fp = fopen(filename, "r");

  size_t nlines = 0;

  char c = 'a';
  while (c != EOF) {
    c = getc(fp);
    if (c == '\n') nlines++;
  }

  fclose(fp);

  return nlines;
}

// [[Rcpp::export]]
double nlines4(std::string filename, int buff_size = 1024) {

  FILE *fp_in = fopen(filename.c_str(), "rb");
  // setvbuf(fp_in, NULL, _IOFBF, BUFSIZE);

  char *buff = new char[buff_size];
  // int buff_size_minus_one = buff_size - 1;
  size_t nlines = 0;

  while (feof(fp_in) == 0) {
    if (fgets(buff, buff_size, fp_in) == NULL)
      Rcpp::Rcout << "Error?" << std::endl;

    // Rcpp::Rcout << " : "<< strlen(buff) <<
    //   " => " << (buff[strlen(buff) - 1] == '\n') << std::endl;

    if ((buff[strlen(buff) - 1] == '\n')) nlines++;
  }

  fclose(fp_in);

  return nlines;
}

// [[Rcpp::export]]
double nlines5(std::string filename, int buff_size = 1024) {

  FILE *input_file = fopen(filename.c_str(), "rb");
  char buffer[buff_size + 1];
  size_t line_count = 0;

  while (!feof(input_file))
  {
    size_t chars_read = fread(buffer, 1, buff_size, input_file);
    for (unsigned int i = 0; i < chars_read; ++i)
    {
      if (buffer[i] == '\n')
      {
        ++line_count;
      }
    }
  }

  fclose(input_file);

  return line_count;
}

// [[Rcpp::export]]
double nlines6(std::string filename) {

  size_t newlines = 0;
  char buf[BUFSIZE];
  size_t BUFSIZE_M1 = BUFSIZE - 1;
  size_t BUFSIZE_M2 = BUFSIZE - 2;
  FILE* file = fopen(filename.c_str(), "rb");

  while (fgets(buf, BUFSIZE, file)) {
    if (strlen(buf) != BUFSIZE_M1 || buf[BUFSIZE_M2] != '\n')
      newlines++;
  }

  return newlines;
}



#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

// [[Rcpp::export]]
double nlines7(std::string filename) {

  int fd = open(filename.c_str(), O_RDONLY, 0);

  char *buff = new char[BUFSIZE];
  size_t nlines = 0;

  while (int len = read(fd, buff, BUFSIZE)) {

    if (len == -1) {
      (void)close(fd);
      break;
    }

    for (int i = 0; i < len; i++)
      if (buff[i] == '\n') nlines++;
  }

  (void)close(fd);

  return nlines;
}

/*** R
cars2 <- cars[rep(1:50, 20e2), rep(1:2, 100)]
# cars2 <- cars[rep(1:50, 5), rep(1:2, 30e3)]
bigreadr::fwrite2(cars2, "tmp-data/cars.csv")
for (i in 2:10) bigreadr::fwrite2(cars2, "tmp-data/cars.csv", append = TRUE)

system.time(print(nlines7("tmp-data/cars.csv")))
system.time(print(nlines1("tmp-data/cars.csv")))
system.time(system("wc -l tmp-data/cars.csv"))
system.time(print(bigreadr::nlines("tmp-data/cars.csv")))


# microbenchmark::microbenchmark(
#   nlines1("tmp-data/cars.csv"),           # 1000
#   # nlines2("tmp-data/cars.csv"),           # 1500
#   # nlines3("tmp-data/cars.csv"),           # 33500
#   # nlines4("tmp-data/cars.csv", 1024),           # 1050
#   # nlines4("tmp-data/cars.csv", 1024 * 1024),    # 1100
#   # nlines5("tmp-data/cars.csv", 1024),           # 1050
#   # nlines5("tmp-data/cars.csv", 1024 * 1024),    # 1100
#   nlines6("tmp-data/cars.csv"),           # 1050
#   # nlines5("tmp-data/cars.csv", 1024 * 1024 * 64),    # 1100
#   # nlines_mmap("tmp-data/cars.csv"),       # 1900
#   # bigreadr::nlines("tmp-data/cars.csv"),  # 3400
#   system("wc -l tmp-data/cars.csv"),      # 400
#   # system("grep -c '\n' tmp-data/cars.csv"), # 400
#   times = 5
# )
#### 5M x 200 ####
# Unit: milliseconds
# expr       min        lq     mean    median
# nlines("tmp-data/cars.csv") 2092.0324 2098.8990 2138.311 2101.8745
# bigreadr::nlines("tmp-data/cars.csv") 6746.9176 6762.7296 6868.384 6799.3394
# system("wc -l tmp-data/cars.csv")  853.2787  856.6954  863.299  862.6793
# uq       max neval
# 2113.3909 2448.5013    10
# 6816.9416 7438.5126    10
# 867.3886  883.3312    10

#### 5K x 200K ####
# Unit: milliseconds
# expr       min        lq     mean    median
# nlines("tmp-data/cars.csv") 1852.4570 1858.6921 2429.795 1934.0913
# bigreadr::nlines("tmp-data/cars.csv") 6557.9264 6621.6394 6982.951 6836.6807
# system("wc -l tmp-data/cars.csv")  798.7292  845.8318 1426.601  864.2086
# uq      max neval
# 2312.193 5831.689    10
# 7211.877 7922.534    10
# 1092.094 5640.510    10

val <- try(system(paste("wc -l", "tmp-data/cars.csv"), intern = TRUE,
                  ignore.stderr = TRUE), silent = TRUE)
val <- `if`(class(val) == "try-error", nlines1("tmp-data/cars.csv"),
            as.numeric(strsplit(val, " ")[[1]][1]))
*/
