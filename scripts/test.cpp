#include <iostream>
#include <string>
using namespace std;

string pr(char* input) {
  return string(input);
}

int main() {
  string str  = "input is here!";
  cout << pr((char*)str.c_str()) << endl;
  cout << (int)3.9 << endl;
}
