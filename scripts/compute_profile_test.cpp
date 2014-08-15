#include "combine_profile_utils.h"
//#include <mpi.h>

int main(int argc, char* argv[]) {
  if (argc<2) {
    cout << "Usage: ./compute_profile dir" << endl;
    exit(1);
  }
 
  // directory setup
  string BASE_DIR = "/fs/nara-scratch/qwang37/brain_data/"+string(argv[1]);
  string partial_profile = BASE_DIR + "/partial_profile";
  string d2s, d2;
  
  // io streams on the final mean_conn_profile file
  ifstream in;
  ofstream out;
  //clock
  clock_t begin_t0;

  // read the dimensions
  int dim_profile, num_records;
  in.open("/fs/nara-scratch/qwang37/brain_data/scripts/dims_test");
  in >> dim_profile; in >> num_records; in >> dimlow();

  // initialize hash table
  cout << "initializing empty hash table" << endl;
  begin_t0 = clock();
  string keyfile = "/fs/nara-scratch/qwang37/brain_data/scripts/keyfile_test";
  init_profile(dim_profile, num_records, keyfile);
  cout << "completed in " << float(clock()-begin_t0)/CLOCKS_PER_SEC << " seconds" << endl;
  // initialize the coarse map
  cout << "initializing coarse map" << endl;
  begin_t0 = clock();
  string coarsefile = "/fs/nara-scratch/qwang37/brain_data/scripts/coarse_map_file_test";
  init_coarse(dim_profile, coarsefile);
  cout << "completed in " << float(clock()-begin_t0)/CLOCKS_PER_SEC << " seconds" << endl;

  // compute conn_profile of subjects in a single data chunk
  cout << "Computing conn profile of data: " << argv[1] << endl;
  d2s = exec("ls " + BASE_DIR + " -l | egrep '^d' | awk '$9~/^S/ {print $9}'");

  stringstream d2s_in(d2s);

  //initial combine
  cout << "loading the existing conn profile file" << endl;
  begin_t0 = clock();
  combine_profile(dim_profile, partial_profile);
  cout << "completed in " << float(clock()-begin_t0)/CLOCKS_PER_SEC << " seconds" << endl;

  time_t begin_t1 = clock();
    
  d2s_in >> d2;
  while(d2s_in.good()) { // stringstream::goodbit is set to false when any of eofbit, failbit, or badbit is set   
    string totaldir = BASE_DIR + '/' + d2;
    string connfile =  totaldir + '/' + "/track_aal_90_0/fdt_matrix3.dot";
    string coordfile = totaldir + '/' + "/track_aal_90_0/coords_standard";
    // do something
    cout << "Processing " + totaldir << endl;
    begin_t0 = clock();
    append_conn(connfile, coordfile);
    cout << "completed in " << float(clock()-begin_t0)/CLOCKS_PER_SEC << " seconds" << endl;

    //write checkpoints
    if ( float((clock()-begin_t1)/CLOCKS_PER_SEC > 7200) ) { // checkpointing every two hours
      cout << "checkpointing...\n";
      begin_t0 = clock();
      write_profile(partial_profile);
      cout << "complete in " << float( (clock()-begin_t0)/CLOCKS_PER_SEC ) << " seconds" << endl;
      begin_t1 = clock();
    }
    d2s_in >> d2;
  }
  
  // final write
  cout << "conn profile computation done, start saving...\n";
  begin_t0 = clock();
  write_profile(partial_profile);
  cout << "complete in " << float( (clock()-begin_t0)/CLOCKS_PER_SEC ) << " seconds" << endl;


}

