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
//

#include "C_Meshless_3d.h"


void out_elem_celqt
(C_Meshless_3d* PML,vector<long>* P_Ind_Voisin_NE,vector<double>* P_Phi_Voisin_NE,
 vector<long>*  P_Ind_Noeud_Hexa,vector<long>* P_Ind_Cel_Elem_Hexa,
 vector<long>*  P_Ind_Noeud_Tet,vector<long>* P_Ind_Cel_Elem_Tet,
 vector<long>* P_Ind_S_Elem_Tet,vector<long>* P_Id_in_S_Elem_Tet,
 vector<double>* P_Coord_Noeud,
 vector<long>* P_Nb_Voisin,vector<long>* P_Ind_Voisin,vector<double>* P_Phi_Voisin);
