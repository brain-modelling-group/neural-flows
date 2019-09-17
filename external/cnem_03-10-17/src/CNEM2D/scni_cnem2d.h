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
vector<double>* P_Vec_Phi_Int);