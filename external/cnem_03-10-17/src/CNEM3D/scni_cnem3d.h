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

#include<vector>
using namespace std;

long scni_cnem3d
(//IN
size_t Nb_Noeud,
double* Tab_Noeud,
size_t Nb_Tri_Front,
size_t* Tab_Ind_Noeud_Tri_Front,
size_t Type_Appel_Tetgen,
bool Sup_NN_GS,
size_t Type_Int,
size_t Type_FF,
/*size_t nb_core_for_gs_cal,*/
//OUT
vector<size_t>* P_Vec_Ind_Noeud_New_Old,
vector<size_t>* P_Vec_Ind_Noeud_Old_New,
vector<double>* P_Vec_New_Noeud,
vector<size_t>* P_Vec_INVNN,
vector<double>* P_Vec_PNVNN,
vector<double>* P_Vec_Vol_Cel,
vector<size_t>* P_Vec_Nb_Contrib,
vector<size_t>* P_Vec_INV,
vector<double>* P_Vec_Grad,
vector<size_t>* P_Vec_Ind_Noeud_New_Tri,
vector<size_t>* P_Vec_Ind_Noeud_Tet);

