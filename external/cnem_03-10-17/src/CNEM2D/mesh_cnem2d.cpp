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

//int main()
int mesh_cnem2d
(//IN
size_t Nb_Noeud,
double* P_XY_Noeud,    
size_t Nb_Front,
size_t* P_Nb_Noeud_Front,
size_t* P_Ind_Noeud_Front,
//OUT
vector<size_t>* P_Vec_Ind_Noeud_New_Old,
vector<size_t>* P_Vec_Ind_Noeud_Old_New,
vector<size_t>* P_Vec_Tri)
{
/*
    size_t Nb_Noeud;
    double* P_XY_Noeud;    
    size_t Nb_Front;
    size_t* P_Nb_Noeud_Front;
    size_t* P_Ind_Noeud_Front;
//OUT
    vector<size_t>* P_Vec_Ind_Noeud_New_Old=new vector<size_t>;
    vector<size_t>* P_Vec_Ind_Noeud_Old_New=new vector<size_t>;
    vector<size_t>* P_Vec_Tri=new vector<size_t>;
    
    ifstream data;
    data.open("F:\\actu\\CNEM\\matlab\\tuto2d\\data_bug",ios::binary);
    data.read((char*)&Nb_Noeud,sizeof(size_t));
    P_XY_Noeud=(double*)malloc(sizeof(double)*2*Nb_Noeud);
    data.read((char*)P_XY_Noeud,sizeof(double)*2*Nb_Noeud);
    data.read((char*)&Nb_Front,sizeof(size_t));
    P_Nb_Noeud_Front=(size_t*)malloc(sizeof(size_t)*Nb_Front);
    data.read((char*)P_Nb_Noeud_Front,sizeof(size_t)*Nb_Front);
    size_t Nb_Ind_Front=0;size_t i;for(i=0;i<Nb_Front;i++)Nb_Ind_Front+=P_Nb_Noeud_Front[i];
    P_Ind_Noeud_Front=(size_t*)malloc(sizeof(size_t)*Nb_Ind_Front);
    data.read((char*)P_Ind_Noeud_Front,sizeof(size_t)*Nb_Ind_Front);
    data.close();
*/
    //-----------------------------------------------------------------------//
    // Initialistation base:
    //----------------------

    C_Meshless_2d ML(Nb_Noeud,P_XY_Noeud,Nb_Front,P_Nb_Noeud_Front,P_Ind_Noeud_Front);

    ML.Voronoi_Non_Contrain();
    ML.Voronoi_Contrain();    

    //-----------------------------------------------------------------------//
    // Sortie corespandance noeus new to old et inv :
    //----------------------------------------------

    size_t i;
    for(i=0;i<ML.Vec_Ind_Noeud_New_Old.size()-3;i++)P_Vec_Ind_Noeud_New_Old->push_back(ML.Vec_Ind_Noeud_New_Old[i]+1);
    for(i=0;i<ML.Vec_Ind_Noeud_Old_New.size();i++)P_Vec_Ind_Noeud_Old_New->push_back(ML.Vec_Ind_Noeud_Old_New[i]+1);
		
    //-----------------------------------------------------------------------//
    // Sortie triangulation :
    //-----------------------

	//map<const long,S_Sommet>::iterator k;
	vector<S_Sommet>::iterator k;
    for(k=ML.List_Sommet.begin();k!=ML.List_Sommet.end();k++)
    {
        //pair<const long,S_Sommet> Paire_k=(*k);
		S_Sommet S_k=(*k);
		if(S_k.Valide&&(!S_k.Sommet_Infini))//&&(S_k.Ind_Noeud[0]<Nb_Noeud)&&(S_k.Ind_Noeud[1]<Nb_Noeud)&&(S_k.Ind_Noeud[2]<Nb_Noeud))
        {
            P_Vec_Tri->push_back(S_k.Ind_Noeud[0]);
            P_Vec_Tri->push_back(S_k.Ind_Noeud[1]);
            P_Vec_Tri->push_back(S_k.Ind_Noeud[2]);
		}
    }
   
    return 0;
}
