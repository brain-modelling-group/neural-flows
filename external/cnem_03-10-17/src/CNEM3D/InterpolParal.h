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

void InterpolParal
(C_Meshless_3d* PML,size_t Nb_Point,double* Tab_Point,long Type_FF,long nb_thread,
 vector<size_t>* P_Vec_Ind_Point,vector<size_t>* P_Vec_Nb_Contrib,vector<size_t>* P_Vec_INV,vector<double>* P_Vec_Phi,vector<double>* P_Vec_Gard=NULL);

