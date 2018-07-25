#include <iostream>
#include <fstream>
#include <Rcpp.h>
using namespace std;

// [[Rcpp::export]]
std::string file2string(std::string fn) {

  std::string str, strTotal;
  ifstream in;
  in.open(fn.c_str());
  getline(in, str);
  while ( in ) {
    Rcpp::Rcout << strTotal.max_size() << std::endl;
    strTotal += str + '\n';
    getline(in, str);
  }

  return strTotal;
}

// [[Rcpp::export]]
std::string file2string2(std::string fn) {

  std::ifstream ifs(fn.c_str());
  std::string content( (std::istreambuf_iterator<char>(ifs) ),
                       (std::istreambuf_iterator<char>()    ) );

  return content;
}


/*** R
test <- file2string("text-write.txt")
writeLines(test)
test2 <- file2string2("text-write.txt")
writeLines(test2)
csv2 <- "tmp-data/mtcars-long.csv"
# system.time(test3 <- file2string2(csv2))
*/
