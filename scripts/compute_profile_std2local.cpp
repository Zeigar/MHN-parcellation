#include "combine_profile_utils.h"
#include <sys/stat.h>
extern unordered_map<intVector, floatVector, container_hash<intVector> > & conn_profile();

int main(int argc, char* argv[]) {
  if (argc<2) {
    cout << "Usage: ./compute_profile dir" << endl;
    exit(1);
  }
 
  // directory setup
  string BASE_DIR = "/fs/nara-scratch/qwang37/brain_data/"+string(argv[1]);
  string partial_profile;
  string d2s, d2;
  
  // io streams on the final mean_conn_profile file
  ifstream in;
  ofstream out;
  //clock
  clock_t begin_t0;

  // read the dimensions
  int dim_profile, num_records;
  in.open("/fs/nara-scratch/qwang37/brain_data/scripts/dims");
  in >> dim_profile; in >> num_records; in >> dimlow();

  // initialize hash table
  string keyfile = "/fs/nara-scratch/qwang37/brain_data/scripts/keyfile";
  // initialize the coarse map
  cout << "initializing coarse map" << endl;
  string coarsefile = "/fs/nara-scratch/qwang37/brain_data/scripts/coarse_map_file";
  init_coarse(dim_profile, coarsefile);

  // compute conn_profile of subjects in a single data chunk
  cout << "Computing conn profile of data: " << argv[1] << endl;
  mkdir( (BASE_DIR + "/processed").c_str(), S_IRWXU|S_IRWXG|S_IROTH|S_IXOTH );
  d2s = exec("ls " + BASE_DIR + " -l | egrep '^d' | awk '$9~/^S/ {print $9}'");

  stringstream d2s_in(d2s);

    
  d2s_in >> d2;
  while(d2s_in.good()) { // stringstream::goodbit is set to false when any of eofbit, failbit, or badbit is set   
    string totaldir = BASE_DIR + '/' + d2;
    string connfile =  totaldir + "/track_aal_90_0/fdt_matrix3.dot";
    string coordfile = totaldir + "/track_aal_90_0/coords_pruned";
    string coordfile_local2std = totaldir + "/track_aal_90_0/coords_standard";
    string coordfile_std2local = totaldir + "/track_aal_90_0/coords_standard_in_diff";
    // clear conn profile
    init_profile(dim_profile, num_records, keyfile, conn_profile());
    // do something
    cout << "Processing " + totaldir << endl;
    begin_t0 = clock();
    append_conn(connfile, coordfile, coordfile_local2std, coordfile_std2local);
    cout << "completed in " << float(clock()-begin_t0)/CLOCKS_PER_SEC << " seconds" << endl;

    // write
    partial_profile = BASE_DIR + '/' + d2 + "/partial_profile_std2local";
    cout << "writing to disk...\n";
    begin_t0 = clock();
    write_profile(partial_profile);
    cout << "completed in " << float( (clock()-begin_t0)/CLOCKS_PER_SEC ) << " seconds" << endl;

    // move
    rename( (BASE_DIR + '/' + d2).c_str(), (BASE_DIR + "/processed/" + d2).c_str() );

    d2s_in >> d2;
  }

}

