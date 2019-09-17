/* This file is part of CNEMLIB.
 
Copyright (C) 2003-2011
Lounes ILLOUL (illoul_lounes@yahoo.fr)
Philippe LORONG (philippe.lorong@ensam.eu)
Arts et Metiers ParisTech, Paris, France
 
CNEMLIB is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

CNEMLIB is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with Foobar.  If not, see <http://www.gnu.org/licenses/>.

Please report bugs to illoul_lounes@yahoo.fr */

#include "C_Meshless_2d.h"

int interpol_cnem2d
(//IN
size_t Nb_Noeud,
double* P_XY_Noeud,    
size_t Nb_Front,
size_t* P_Nb_Noeud_Front,
size_t* P_Ind_Noeud_Front,
size_t Nb_PntInt,
double* P_XY_PntInt,
//OUT
vector<size_t>* P_Vec_Ind_Noeud_New_Old,
vector<size_t>* P_Vec_Ind_Noeud_Old_New,
vector<size_t>* P_Vec_Nb_Contrib,
vector<size_t>* P_Vec_INV,
vector<double>* P_Vec_Phi,
vector<double>* P_Vec_Gard)
{
/*int main()
{
    ifstream data("in.dat");
    size_t Nb_Noeud;data>>Nb_Noeud;
    double* P_XY_Noeud=(double*)malloc(sizeof(double)*2*Nb_Noeud);  
    size_t i;for(i=0;i<2*Nb_Noeud;i++)data>>P_XY_Noeud[i];
    
    size_t Nb_Front;data>>Nb_Front;
    size_t* P_Nb_Noeud_Front=(size_t*)malloc(sizeof(size_t)*Nb_Front);
    size_t Nb_Ind_Noeud_Front=0;
    for(i=0;i<Nb_Front;i++){data>>P_Nb_Noeud_Front[i];Nb_Ind_Noeud_Front+=P_Nb_Noeud_Front[i];}

    size_t* P_Ind_Noeud_Front=(size_t*)malloc(sizeof(size_t)*Nb_Ind_Noeud_Front);
    for(i=0;i<Nb_Ind_Noeud_Front;i++)data>>P_Ind_Noeud_Front[i];
    
    size_t Nb_PntInt;data>>Nb_PntInt;
    double* P_XY_PntInt=(double*)malloc(sizeof(double)*2*Nb_PntInt);
    for(i=0;i<2*Nb_PntInt;i++)data>>P_XY_PntInt[i];

    vector<size_t>* P_Vec_Ind_Noeud_New_Old=new vector<size_t>;
    vector<size_t>* P_Vec_Ind_Noeud_Old_New=new vector<size_t>;
    vector<size_t>* P_Vec_Nb_Contrib=new vector<size_t>;
    vector<size_t>* P_Vec_INV=new vector<size_t>;
    vector<double>* P_Vec_Phi=new vector<double>;
    vector<double>* P_Vec_Gard=new vector<double>;
*/
    //-----------------------------------------------------------------------//
    // Initialistation base:
    //----------------------

    C_Meshless_2d ML(Nb_Noeud,P_XY_Noeud,Nb_Front,P_Nb_Noeud_Front,P_Ind_Noeud_Front);
    ML.Voronoi_Non_Contrain();
    ML.Voronoi_Contrain();    

	//-----------------------------------------------------------------------//
    // interpolation point :
    //----------------------

	ML.Interpolation_point(Nb_PntInt,P_XY_PntInt,NULL,P_Vec_Nb_Contrib,P_Vec_INV,P_Vec_Phi);
	
    //-----------------------------------------------------------------------//
    // Sortie corespandance noeus new to old et inv :
    //----------------------------------------------

	size_t i;
    for(i=0;i<ML.Vec_Ind_Noeud_New_Old.size()-3;i++)P_Vec_Ind_Noeud_New_Old->push_back(ML.Vec_Ind_Noeud_New_Old[i]+1);
    for(i=0;i<ML.Vec_Ind_Noeud_Old_New.size();i++)P_Vec_Ind_Noeud_Old_New->push_back(ML.Vec_Ind_Noeud_Old_New[i]+1);
    
    //-----------------------------------------------------------------------//

    return 0;
}
