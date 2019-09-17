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

#include "utile_py.h"

size_t* Tuple_L_2_Tab_UL(PyObject* Tuple,size_t Size)
{
    size_t* Tab=(size_t*)malloc(sizeof(size_t)*Size);
    size_t i;
    for(i=0;i<Size;i++)
    {
        PyObject* item=PySequence_GetItem(Tuple,i);
        Py_DECREF(item);
        item=PyNumber_Long(item);
        Tab[i]=PyLong_AsSsize_t(item);
        Py_DECREF(item);
    }
    return Tab;
}

double* Tuple_F_2_Tab_D(PyObject* Tuple,size_t Size)
{
    double* Tab=(double*)malloc(sizeof(double)*Size);
    size_t i;
    for(i=0;i<Size;i++)
    {
        PyObject* item=PySequence_GetItem(Tuple,i);
        Py_DECREF(item);
        item=PyNumber_Float(item);
        Tab[i]=PyFloat_AsDouble(item);
        Py_DECREF(item);
    }
    return Tab;
}

PyObject* Tab_UL_2_Tuple_L(size_t* Tab,size_t Size)
{
    PyObject* Tuple=PyTuple_New(Size);
    size_t i;
    for(i=0;i<Size;i++)PyTuple_SetItem(Tuple,i,PyLong_FromSize_t(Tab[i]));
    return Tuple;
}

PyObject* Tab_D_2_Tuple_F(double* Tab,size_t Size)
{
    PyObject* Tuple=PyTuple_New(Size);
    size_t i;
    for(i=0;i<Size;i++)PyTuple_SetItem(Tuple,i,PyFloat_FromDouble(Tab[i]));
    return Tuple;
}

PyObject* Vec_UL_2_Tuple_L(vector<size_t>* Vec)
{
    PyObject* Tuple=PyTuple_New(Vec->size());
    size_t i;
    for(i=0;i<Vec->size();i++)PyTuple_SetItem(Tuple,i,PyLong_FromSize_t(Vec->at(i)));
    return Tuple;
}

PyObject* Vec_D_2_Tuple_F(vector<double>* Vec)
{
    PyObject* Tuple=PyTuple_New(Vec->size());
    size_t i;
    for(i=0;i<Vec->size();i++)PyTuple_SetItem(Tuple,i,PyFloat_FromDouble(Vec->at(i)));
    return Tuple;
}

long Num_2_UL(PyObject* Num)
{
    Num=PyNumber_Long(Num);
    size_t UL=PyLong_AsSsize_t(Num);
    Py_DECREF(Num);
    return UL;
}
