#include <mpi.h>
#include <iostream>
using namespace std;

int main(int argc, char* argv[]) {
  int i;
  int rank;
  int size;
  int tag = 201;
  int receive_message;
  
  MPI_Init(&argc, &argv);
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);

  if (rank < argc)
    cout << rank << ": " << argv[rank] << endl;
}
