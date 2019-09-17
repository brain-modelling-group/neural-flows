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

#pragma once

//---------------------------------------------------------------------------//
// Interpolation 3d paralelle

#include "C_Meshless_3d.h"

//---------------------------------------------------------------------------//

struct HashCompareGSKey
{
    static size_t hash(const long x){return (size_t)x;}
    static bool equal(const long x,const long y){return x==y;}
};

void Integration_Stabilisee_Paral
(C_Meshless_3d* PML,
 concurrent_hash_map<const long,C_Vec3d,HashCompareGSKey>**& Tab_Gradiant_Stabilisee,double*& Tab_Volume_Cellule,
 long Type_Int,long Type_FF,long nb_thread,long Sup_NN_GS,
 vector<long>* P_Ind_Voisin,vector<double>* P_Phi_Voisin,
 vector<long>* Tab_Ind_Noeud_Tet,vector<long>* Tab_Ind_Cel_Elem_Tet,
 vector<long>* Tab_Ind_S_Elem_Tet,vector<long>* Tab_Id_in_S_Elem_Tet,
 vector<double>* Tab_Coord_Noeud_Elem);

void Calcul_Erreur_Gradiant_Stabilise
(concurrent_hash_map<const long,C_Vec3d,HashCompareGSKey>** Tab_Gradiant_Stabilisee,double* Tab_Volume_Cellule,double* Tab_Noeud,long Nb_Noeud);

void Elimination_Nouveaux_Noeuds_DVC_de_GS
(concurrent_hash_map<const long,C_Vec3d,HashCompareGSKey>**& Tab_Gradiant_Stabilisee,double*& Tab_Volume_Cellule,
 long Nb_Noeud_Ini,long Nb_Noeud,vector<long>* P_Ind_Voisin,vector<double>* P_Phi_Voisin);

//---------------------------------------------------------------------------//
