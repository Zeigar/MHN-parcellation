#include <iostream>
#include <unordered_map>
#include <utility>
#include <string>
#include <stdio.h>
#include <sstream>
#include <vector>
#include <fstream>
#include <tuple>
#include <boost/functional/hash.hpp>
#include <time.h>
using namespace std;

const int init_cap_conn=100000;
const int init_cap_grid = 3000;

typedef vector<int> intVector;
typedef vector<float> floatVector;

// hash for vector<> keys
template <typename Container>
struct container_hash {
  size_t operator()(Container const& c) const {
    return boost::hash_range(c.begin(), c.end());
  }
};

// hash table for the mean connectivity profiles
unordered_map<intVector, floatVector, container_hash<intVector> > & conn_profile();

// hash table for mapping coordinates to indices
unordered_map<intVector, int, container_hash<intVector> > & coarse_map();

// resolution of the coarse grid
int& dimlow();

string exec(string cmd);

void fine2coarse(floatVector& c, intVector& c_cgrid);


void update_hash(string coordfile);
    
void distribute_conn_mass(floatVector& lc, floatVector& rc, intVector& lc_cgrid, intVector& rc_cgrid, int val);
 
void append_conn(string connfile, string coordfile);
void append_conn(string connfile, string coordfile, string coordfile_local2std, string coordfile_std);

void appendpf_local2std(string coordfile_std);

// combine the stored profile in file with current hash map
void combine_profile(int dim_profile, string file);
      
// write computed conn profile to file
void write_profile(string filename);

// initialize empty connectivity profile
template <typename t1, typename t2, typename t3>
  void init_profile(int dim_profile, int num_records, string keyfile, unordered_map<t1, t2, t3>& connpf);

// initialize coarse map
void init_coarse(int dim_profile, string coarsefile);

