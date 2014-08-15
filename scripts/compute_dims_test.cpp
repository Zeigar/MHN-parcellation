#include "combine_profile_utils.h"
//#include <string>
//using namespace std;


int main() {
  // directory setup
  string BASE_DIR = "/fs/nara-scratch/qwang37/brain_data";
  string d1s, d2s, d1, d2; 
  // iterate using linux shell command
  d1s = exec("ls " + BASE_DIR + " -l | egrep '^d' | awk '$9~/^test_data/ {print $9}'");
  stringstream d1s_in;
  // io streams on the final mean_conn_profile file
  ifstream in;
  ofstream out;
  

  // parameter setup
  dimlow()=4;

  //clock
  clock_t begin_time;

  // in the first ru, we do nothing but to determine the dim of connectivity profile, and materialize coarse_map
  begin_time = clock();
  cout << "compute dimension of connectivity profile" << endl;
  d1s_in.str(d1s);
  d1s_in >> d1;
  while(d1s_in.good()) {
    d2s = exec("ls " + BASE_DIR + "/" + d1 + " -l | egrep '^d' | awk '$9~/^S/ {print $9}'");
    stringstream d2s_in(d2s);
    d2s_in >> d2;
    while (d2s_in.good()) { // stringstream::goodbit is set to false when any of eofbit, failbit, or badbit is set
      string totaldir = BASE_DIR + '/' + d1 + '/' + d2;
      string connfile =  totaldir + '/' + "/track_aal_90_0/fdt_matrix3.dot";
      string coordfile = totaldir + '/' + "/track_aal_90_0/coords_standard";
      // do something
      cout << "Processing " + d1 + "/" + d2 << endl;
      update_hash(coordfile);
      d2s_in >> d2;
    }
    d1s_in >> d1;
  }
  cout << "Time spent: " << float( clock()-begin_time ) / CLOCKS_PER_SEC << endl;

  cout << "Writing files...\n" << endl;

  // record the profile dimension and  number of records
  out.open("/fs/nara-scratch/qwang37/brain_data/scripts/dims_test");
  int dim_profile = coarse_map().size();
  out << dim_profile << ' ' << conn_profile().size() << ' ' << dimlow() << endl;
  out.close();

  // record the keys
  intVector coord;
  out.open("/fs/nara-scratch/qwang37/brain_data/scripts/keyfile_test");
  for (auto it=conn_profile().begin(); it!=conn_profile().end(); it++) {
    coord = it->first;
    for (int i=0; i<3; i++)
      out << coord[i] << ' ';
    out << endl;
  }
  out.close();
  
  // record the coarse map
  int ind;
  out.open("/fs/nara-scratch/qwang37/brain_data/scripts/coarse_map_file_test");
  for (auto it=coarse_map().begin(); it!=coarse_map().end(); it++) {
    coord = it->first; ind = it->second;
    for (int i=0; i<3; i++)
      out << coord[i] << ' ';
    out << ind << endl;
  }
  out.close();
}

