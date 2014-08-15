#include "combine_profile_utils.h"
#include <assert.h>

// hash table for the mean connectivity profiles
unordered_map<intVector, floatVector, container_hash<intVector> > & conn_profile() {
  static unordered_map<intVector, floatVector, container_hash<intVector> > conn(init_cap_conn);
  return conn;
}

unordered_map<intVector, intVector, container_hash<intVector> > & conn_profile_local() {
  static unordered_map<intVector, intVector, container_hash<intVector> > conn(init_cap_conn);
  return conn;
}

// hash table for mapping coordinates to indices
unordered_map<intVector, int, container_hash<intVector> > & coarse_map() {
  static unordered_map<intVector, int, container_hash<intVector> > grid(init_cap_grid);
  return grid;
}

// resolution of the coarse grid
int& dimlow() {
  static int res;
  return res;
}

string exec(string cmd) {
  FILE* pipe = popen(cmd.c_str(), "r");
  if (!pipe) return "ERROR";
  char buffer[128];
  string result="";
  while (!feof(pipe))
    if (fgets(buffer, 128, pipe)!=NULL)
      result+=buffer;
  pclose(pipe);
  return result;
}

void fine2coarse(floatVector& c, intVector& c_cgrid) {
  c_cgrid[0]=(int)c[0] / dimlow();
  c_cgrid[1]=(int)c[1] / dimlow();
  c_cgrid[2]=(int)c[2] / dimlow();
}


void update_hash(string coordfile) {
  ifstream coordstream(coordfile);
  floatVector fine(3);
  intVector fineInt(3);
  intVector coarse(3);

  while(coordstream.good()) {
    coordstream >> fine[0]; coordstream >> fine[1]; coordstream >> fine[2];
    for (int z=0; z<2; z++)
      for (int y=0; y<2; y++)
	for (int x=0; x<2; x++) {
	  fineInt[0]=(int)fine[0]+x; fineInt[1]=(int)fine[1]+y; fineInt[2]=(int)fine[2]+z;
	  conn_profile()[fineInt]=vector<float>(); // just to store the key
	}

    fine2coarse(fine, coarse);
    if (!coarse_map().count(coarse))
      coarse_map()[coarse] = coarse_map().size();
  }
}
    
void distribute_conn_mass(floatVector& lc, floatVector& rc, intVector& lc_cgrid, intVector& rc_cgrid, int val) {
  floatVector lcoef(3), rcoef(3); // frational value indicating connectivity assignment along 3 axes
  for (int i=0; i<3; i++) {
    lcoef[i]=lc[i]-floor(lc[i]);
    rcoef[i]=rc[i]-floor(rc[i]);
  }
  
  intVector tmpCoords(3);
  int lc_cgrid_ind=coarse_map()[lc_cgrid]-1, rc_cgrid_ind=coarse_map()[rc_cgrid]-1;
  for (int z=0; z<2; z++) { // Note: we assume that all points are in the interios, therefore exactly 8 points
    float lfracZ=(1-lcoef[2])*(1-z)+lcoef[2]*z;
    float rfracZ=(1-rcoef[2])*(1-z)+rcoef[2]*z;
    for (int y=0; y<2; y++) {
      float lfracZY=lfracZ * ( (1-lcoef[1])*(1-y)+lcoef[1]*y );
      float rfracZY=rfracZ * ( (1-rcoef[1])*(1-y)+rcoef[1]*y );
      for (int x=0; x<2; x++) {
	float lfracZYX=lfracZY * ( (1-lcoef[0])*(1-x)+lcoef[0]*x );
	float rfracZYX=rfracZY * ( (1-rcoef[0])*(1-x)+rcoef[0]*x ); 
	tmpCoords[0]=(int)lc[0]+x; tmpCoords[1]=(int)lc[1]+y; tmpCoords[2]=(int)lc[2]+z; // left
	conn_profile()[tmpCoords][rc_cgrid_ind] += lfracZYX * val;
	tmpCoords[0]=(int)rc[0]+x; tmpCoords[1]=(int)rc[1]+y; tmpCoords[2]=(int)rc[2]+z; // right
	conn_profile()[tmpCoords][lc_cgrid_ind] += rfracZYX * val;
      }
    }
  }
}
	

void append_conn(string connfile, string coordfile) {
  vector<floatVector> coord_map; // store the coordinate-to-index mapping
  floatVector coord(3);
  // readin the coordinate mapping to memory
  ifstream coordstream(coordfile);
  for (int i=0; i<3; i++)
    coordstream >> coord[i];
  while(coordstream.good()) {
    coord_map.push_back(coord);
    for (int i=0; i<3; i++)
      coordstream >> coord[i];
  }
  coordstream.close();
  
  // the connectivity part
  ifstream connstream(connfile);
  int l, r, v; // left node, right node, and connectivity value
  floatVector lc(3), rc(3); // coordinates of left/right nodes
  intVector lc_cgrid(3), rc_cgrid(3); // coordinates in the coarse grid

  connstream >> l; connstream >> r; connstream >> v;
  while(connstream.good()) {
    lc=coord_map[l-1]; rc=coord_map[r-1];
    fine2coarse(lc, lc_cgrid); fine2coarse(rc, rc_cgrid);
    distribute_conn_mass(lc, rc, lc_cgrid, rc_cgrid, v);
    connstream >> l; connstream >> r; connstream >> v;
  }
  connstream.close();
}

// overloaded
void append_conn(string connfile, string coordfile, string coordfile_local2std, string coordfile_std2local) { // connectivity profile represented in the MNI coarser space
  vector<intVector> coord_map; // store the coordinate-to-index mapping
  vector<floatVector> coord_map_local2std; // corresponding coordinate in MNI space
  intVector coord(3);
  floatVector coord_local2std(3);
  // read in the coordinate mapping to memory
  ifstream coordstream(coordfile);
  ifstream coordstream_local2std(coordfile_local2std);

  for (int i=0; i<3; i++)
    coordstream >> coord[i];
  while(coordstream.good()) {
    coord_map.push_back(coord);
    for (int i=0; i<3; i++)
      coordstream >> coord[i];
  }
  coordstream.close();

  for (int i=0; i<3; i++)
    coordstream_local2std >> coord_local2std[i];
  while(coordstream_local2std.good()) {
    coord_map_local2std.push_back(coord_local2std);
    for (int i=0; i<3; i++)
      coordstream_local2std >> coord_local2std[i];
  }
  coordstream_local2std.close();

  assert(coord_map.size()==coord_map_local2std.size());

  // the connectivity part
  ifstream connstream(connfile);
  int l, r, v; // left node, right node, and t=connectivity value
  intVector lc(3), rc(3); // coordinates of left/right nodes
  floatVector lc_local2std(3), rc_local2std(3); // in MNI space
  intVector lc_cgrid(3), rc_cgrid(3); // coordinates in the coarse grid

  init_profile( (conn_profile().begin()->second).size(), coord_map.size(), coordfile, conn_profile_local() ); // reset the local conn profile
  
  connstream >> l; connstream >> r; connstream >> v;
  while(connstream.good()) {
    lc = coord_map[l-1]; rc = coord_map[r-1];
    lc_local2std = coord_map_local2std[l-1]; rc_local2std = coord_map_local2std[r-1]; // int MNI space
    fine2coarse(lc_local2std, lc_cgrid); fine2coarse(rc_local2std, rc_cgrid);
    if (coarse_map().count(rc_cgrid))
      conn_profile_local()[lc][coarse_map()[rc_cgrid]-1] += v;
    if (coarse_map().count(lc_cgrid))
      conn_profile_local()[rc][coarse_map()[lc_cgrid]-1] += v;
    connstream >> l; connstream >> r; connstream >> v;
  }
  connstream.close();

  // transform local profile to MNI space profile
  appendpf_local2std(coordfile_std2local);
}


// append local profile to MNI space profile
void appendpf_local2std(string coordfile_std2local) {
  ifstream coordstream(coordfile_std2local);
  floatVector coord(3);
  vector<floatVector> coord_map_std2local;
  for (int i=0; i<3; i++)
    coordstream >> coord[i];
  while(coordstream.good()) {
    coord_map_std2local.push_back(coord);
    for (int i=0; i<3; i++)
      coordstream >> coord[i];
  }

  assert(coord_map_std2local.size()==conn_profile().size());
  floatVector append;
  intVector start(3);
  floatVector coef(3);
  intVector tmpCoord(3);
  int dim_profile = (conn_profile().begin()->second).size();

  auto it = conn_profile().begin();
  for (int i=0; i<conn_profile().size(); i++, it++) {
    for (int k=0; k<3; k++) {
      start[k]=(int)coord_map_std2local[i][k];
      coef[k] = coord_map_std2local[i][k]-start[k];
    }
    for (int z=0; z<2; z++) { // Note: we assume that all points are within the interiors, therefore exactly 8 neighbors
      float fracZ = (1-coef[2])*(1-z)+coef[2]*z;
      for (int y=0; y<2; y++) {
	float fracZY=fracZ * ( (1-coef[1])*(1-y)+coef[1]*y );
	for (int x=0; x<2; x++) {
	  float fracZYX=fracZY * ( (1-coef[0])*(1-x)+coef[0]*x );
	  tmpCoord[0]=start[0]+x; tmpCoord[1]=start[1]+y; tmpCoord[2]=start[2]+z;
	  if (conn_profile_local().count(tmpCoord)) {
	    for (int k=0; k<dim_profile; k++)
	      (it->second)[k] += fracZYX * conn_profile_local()[tmpCoord][k];
	  }
	}
      }
    }
  }
}


// combine the stored profile in file with current hash map
void combine_profile(int dim_profile, string file) {
  ifstream in(file);
  float val;
  intVector coord(3);
  floatVector profile(dim_profile);
  
  for (int i=0; i<3; i++)
      in >> coord[i];

  while(in.good()) {
    for (int i=0; i<dim_profile; i++) {
      in >> val;
      conn_profile()[coord][i]+=val;
    }
    for (int i=0; i<3; i++)
      in >> coord[i];
  }
  in.close();
}
      
void write_profile(string filename) {
  rename(filename.c_str(), (filename+"_old").c_str()); // save the old file in case of interruption in a long writing
  ofstream out(filename);
  intVector coord;
  floatVector profile;
  for (auto it=conn_profile().begin(); it!=conn_profile().end(); it++) {
    coord = it->first;
    profile = it->second;
    for (int i=0; i<3; i++)
      out << coord[i] << ' ';
    for (int i=0; i<profile.size(); i++)
      out << profile[i] << ' ';
    out << endl;
  }
  out.close();
  remove((filename+"_old").c_str()); // now we can safely remove the old file
}
  

template<typename t1, typename t2, typename t3>
void init_profile(int dim_profile, int num_records, string keyfile, unordered_map<t1, t2, t3>& connpf) {
  connpf.clear();
  // read in the coordinates
  ifstream skeys(keyfile);
  intVector coord(3);

  for (int i=0; i<3; i++)
    skeys >> coord[i];

  while(skeys.good()) {
    connpf[coord] = t2(dim_profile, 0);
    for (int i=0; i<3; i++)
      skeys >> coord[i];
  }
  assert(connpf.size()==num_records);
  skeys.close();
}

template void init_profile<intVector, intVector,  container_hash<intVector> >(int, int, string, unordered_map<intVector, intVector,  container_hash<intVector> >&);
template void init_profile<intVector, floatVector,  container_hash<intVector> >(int, int, string, unordered_map<intVector, floatVector,  container_hash<intVector> >&);


void init_coarse(int dim_profile, string coarsefile) {
  coarse_map().clear();
  // read in the coordinate mappings
  ifstream scoarse(coarsefile);
  intVector coord(3);

  for (int i=0; i<3; i++)
    scoarse >> coord[i];

  while(scoarse.good()) {    
    scoarse >> coarse_map()[coord];
    for (int i=0; i<3; i++)
      scoarse >> coord[i];
  }
  assert(coarse_map().size()==dim_profile);
  scoarse.close();
}
