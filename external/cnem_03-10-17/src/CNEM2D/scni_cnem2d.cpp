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

int scni_cnem2d
(//IN
size_t Nb_Noeud,
double* P_XY_Noeud,    
size_t Nb_Front,
size_t* P_Nb_Noeud_Front,
size_t* P_Ind_Noeud_Front,
bool out_cel_vc,
bool axi,
//OUT
vector<size_t>* P_Vec_Ind_Noeud_New_Old,
vector<size_t>* P_Vec_Ind_Noeud_Old_New,
vector<double>* P_Vec_Vol_Cel,
vector<double>* P_Vec_XY_CdM,
vector<size_t>* P_Vec_Nb_Contrib,
vector<size_t>* P_Vec_INV,
vector<double>* P_Vec_Grad,
vector<size_t>* P_Vec_Tri,
vector<size_t>* P_Ind_Noeud_Cel,
vector<size_t>* P_Nb_S_Cel,
vector<double>* P_S_Cel,
vector<size_t>* P_Vec_Nb_Contrib_Int,
vector<size_t>* P_Vec_INV_Int,
vector<double>* P_Vec_Phi_Int)
{
    //-----------------------------------------------------------------------//
    // Initialistation base:
    //----------------------

    C_Meshless_2d ML(Nb_Noeud,P_XY_Noeud,Nb_Front,P_Nb_Noeud_Front,P_Ind_Noeud_Front);

    ML.Voronoi_Non_Contrain();
    ML.Voronoi_Contrain();    
    ML.Intersection_Voronoi_Contrain_avec_Frontiere();
 
    ML.Integration_Stabilisee(P_Vec_Nb_Contrib,P_Vec_Vol_Cel,P_Vec_XY_CdM,P_Vec_INV,P_Vec_Grad);


	if(axi)
	{
		size_t nb_pnt_int=P_Vec_XY_CdM->size()/2;
		vector<size_t> close_node(nb_pnt_int);
		size_t i;for(i=0;i<nb_pnt_int;i++)close_node[i]=i;
		ML.Interpolation_point(nb_pnt_int,&(P_Vec_XY_CdM->at(0)),&close_node[0],P_Vec_Nb_Contrib_Int,P_Vec_INV_Int,P_Vec_Phi_Int);
	}

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
		if(S_k.Valide&&(!S_k.Sommet_Infini))
        {
            P_Vec_Tri->push_back(S_k.Ind_Noeud[0]);
            P_Vec_Tri->push_back(S_k.Ind_Noeud[1]);
            P_Vec_Tri->push_back(S_k.Ind_Noeud[2]);
		}
    }
    
    //-----------------------------------------------------------------------//
	// Sortie Cel VC :
	//----------------

	if(out_cel_vc)ML.Sortie_Cellule_VC(P_Ind_Noeud_Cel,P_Nb_S_Cel,P_S_Cel);

    return 0;
}
