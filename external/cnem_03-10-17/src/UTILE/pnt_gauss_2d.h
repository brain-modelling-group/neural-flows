#include <vector>
using namespace std;
#include <math.h>

struct S_Point_de_Gauss
{
	double Poids;
	double Poids_Position[3];
};

void Initialisation_Point_de_Gauss(vector<S_Point_de_Gauss>* List_SPoint_de_Gauss);
