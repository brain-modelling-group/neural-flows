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

#include <Python.h>
#include <vector>
using namespace std;

size_t* Tuple_L_2_Tab_UL(PyObject* Tuple,size_t Size);
double* Tuple_F_2_Tab_D(PyObject* Tuple,size_t Size);
PyObject* Tab_UL_2_Tuple_L(size_t* Tab,size_t Size);
PyObject* Tab_D_2_Tuple_F(double* Tab,size_t Size);
PyObject* Vec_UL_2_Tuple_L(vector<size_t>* Vec);
PyObject* Vec_D_2_Tuple_F(vector<double>* Vec);

long Num_2_UL(PyObject* Num);
