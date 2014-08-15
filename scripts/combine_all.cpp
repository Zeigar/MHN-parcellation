#include "combine_profile_utils.h"
//#include <string>
//using namespace std;


int main() {
  // directory setup
  string BASE_DIR = "/fs/nara-scratch/qwang37/brain_data";
  string d1s, d2s, d1, d2; 
  // iterate using linux shell command
  d1s = exec("ls " + BASE_DIR + " -l | egrep '^d' | awk '$9~/^d[01]/ {print $9}'");
  stringstream d1s_in;
  // io streams on the final mean_conn_profile file
  ifstream in;
  ofstream out;
  clock_t begin_t0;
  
  // read in parameters
  int dim_profile, num_records;
  in.open("/fs/nara-scratch/qwang37/brain_data/scripts/dims");
  in >> dim_profile; in >> num_records; in >> dimlow();

  // initialzie conn profile
  cout << "Initializing empty profile" << endl;
  string keyfile = "/fs/nara-scratch/qwang37/brain_data/scripts/keyfile";
  init_profile(dim_profile, num_records, keyfile);

  // in the first ru, we do nothing but to determine the dim of connectivity profile, and materialize coarse_map
  cout << "start iterating" << endl;
  d1s_in.str(d1s);
  d1s_in >> d1;
  while(d1s_in.good()) {
    cout << "reading " << d1 << endl;
    begin_t0 = clock();
    combine_profile(dim_profile, BASE_DIR + '/' + d1 + "/partial_profile");
    cout << "complete in " << float( clock()-begin_t0 ) / CLOCKS_PER_SEC << " seconds" << endl;
    d1s_in >> d1;
  }

  cout << "Writing files...\n" << endl;
  begin_t0 = clock();
  write_profile("/fs/nara-scratch/qwang37/brain_data/scripts/final_profile");
  cout << "completed in " << float( clock()-begin_t0) / CLOCKS_PER_SEC << "seconds" << endl;
}

