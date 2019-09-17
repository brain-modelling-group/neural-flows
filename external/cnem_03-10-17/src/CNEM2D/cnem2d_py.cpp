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

#include <Python.h>
#include "scni_cnem2d.h"
#include "interpol_cnem2d.h"
#include "mesh_cnem2d.h"
#include "utile_py.h"

PyObject* Py_SCNI_CNEM2D(PyObject* self,PyObject* args)
{
    PyObject* Py_XY_Noeud;
    PyObject* Py_Nb_Noeud_Front;
    PyObject* Py_Ind_Noeud_Front;

    if(!PyArg_ParseTuple(args,"OOO",&Py_XY_Noeud,&Py_Nb_Noeud_Front,&Py_Ind_Noeud_Front))return (PyObject*)Py_BuildValue("");
    if(!PySequence_Check(Py_XY_Noeud))return (PyObject*)Py_BuildValue("");
    if(!PySequence_Check(Py_Nb_Noeud_Front))return (PyObject*)Py_BuildValue("");
    if(!PySequence_Check(Py_Ind_Noeud_Front))return (PyObject*)Py_BuildValue("");

    size_t Size;
    Size=PySequence_Size(Py_XY_Noeud);
    size_t Nb_Noeud=Size/2;
    double* P_XY_Noeud=Tuple_F_2_Tab_D(Py_XY_Noeud,Size);

    Size=PySequence_Size(Py_Nb_Noeud_Front);
    size_t Nb_Front=Size;
    size_t* P_Nb_Noeud_Front=Tuple_L_2_Tab_UL(Py_Nb_Noeud_Front,Size);
    
    Size=PySequence_Size(Py_Ind_Noeud_Front);
    size_t* P_Ind_Noeud_Front=Tuple_L_2_Tab_UL(Py_Ind_Noeud_Front,Size);
    
    //-----------------------------------------------------------------------//

    printf("\n\nCalling scni cnem2d...\n\n");

    vector<size_t> Vec_Ind_Noeud_New_Old;
    vector<size_t> Vec_Ind_Noeud_Old_New;
    vector<double> Vec_Vol_Cel;
    vector<double> Vec_XY_CdM;
    vector<size_t> Vec_Nb_Contrib;
    vector<size_t> Vec_INV;
    vector<double> Vec_Grad;
    vector<size_t> Vec_Tri;

	bool out_cel_vc=0;
	bool axi=0;

	scni_cnem2d(Nb_Noeud,P_XY_Noeud,Nb_Front,P_Nb_Noeud_Front,P_Ind_Noeud_Front,out_cel_vc,axi,
                &Vec_Ind_Noeud_New_Old,&Vec_Ind_Noeud_Old_New,&Vec_Vol_Cel,&Vec_XY_CdM,&Vec_Nb_Contrib,&Vec_INV,&Vec_Grad,&Vec_Tri,
				NULL,NULL,NULL,NULL,NULL,NULL);

    //-----------------------------------------------------------------------//
    
    PyObject* Py_Res=PyTuple_New(8);

    PyTuple_SetItem(Py_Res,0,Vec_UL_2_Tuple_L(&Vec_Ind_Noeud_New_Old));
    PyTuple_SetItem(Py_Res,1,Vec_UL_2_Tuple_L(&Vec_Ind_Noeud_Old_New));
    PyTuple_SetItem(Py_Res,2,Vec_D_2_Tuple_F(&Vec_Vol_Cel));
    PyTuple_SetItem(Py_Res,3,Vec_D_2_Tuple_F(&Vec_XY_CdM));
    PyTuple_SetItem(Py_Res,4,Vec_UL_2_Tuple_L(&Vec_Nb_Contrib));
    PyTuple_SetItem(Py_Res,5,Vec_UL_2_Tuple_L(&Vec_INV));
    PyTuple_SetItem(Py_Res,6,Vec_D_2_Tuple_F(&Vec_Grad));
    PyTuple_SetItem(Py_Res,7,Vec_UL_2_Tuple_L(&Vec_Tri));
    
    //-----------------------------------------------------------------------//

    free(P_XY_Noeud);
    free(P_Nb_Noeud_Front);
    free(P_Ind_Noeud_Front);

    return Py_Res;
}

PyObject* Py_INTERPOL_CNEM2D(PyObject* self,PyObject* args)
{
    PyObject* Py_XY_Noeud;
    PyObject* Py_Nb_Noeud_Front;
    PyObject* Py_Ind_Noeud_Front;
    PyObject* Py_XY_PntInt;

    if(!PyArg_ParseTuple(args,"OOOO",&Py_XY_Noeud,&Py_Nb_Noeud_Front,&Py_Ind_Noeud_Front,&Py_XY_PntInt))return (PyObject*)Py_BuildValue("");
    if(!PySequence_Check(Py_XY_Noeud))return (PyObject*)Py_BuildValue("");
    if(!PySequence_Check(Py_Nb_Noeud_Front))return (PyObject*)Py_BuildValue("");
    if(!PySequence_Check(Py_Ind_Noeud_Front))return (PyObject*)Py_BuildValue("");
    if(!PySequence_Check(Py_XY_PntInt))return (PyObject*)Py_BuildValue("");

    size_t Size;
    Size=PySequence_Size(Py_XY_Noeud);
    size_t Nb_Noeud=Size/2;
    double* P_XY_Noeud=Tuple_F_2_Tab_D(Py_XY_Noeud,Size);

    Size=PySequence_Size(Py_Nb_Noeud_Front);
    size_t Nb_Front=Size;
    size_t* P_Nb_Noeud_Front=Tuple_L_2_Tab_UL(Py_Nb_Noeud_Front,Size);
    
    Size=PySequence_Size(Py_Ind_Noeud_Front);
    size_t* P_Ind_Noeud_Front=Tuple_L_2_Tab_UL(Py_Ind_Noeud_Front,Size);

    Size=PySequence_Size(Py_XY_PntInt);
    size_t Nb_PntInt=Size/2;
    double* P_XY_PntInt=Tuple_F_2_Tab_D(Py_XY_PntInt,Size);
    
    //-----------------------------------------------------------------------//

    printf("\n\nCalling interpol cnem2d...\n\n");

    vector<size_t> Vec_Ind_Noeud_New_Old;
    vector<size_t> Vec_Ind_Noeud_Old_New;
    vector<size_t> Vec_Nb_Contrib;
    vector<size_t> Vec_INV;
    vector<double> Vec_Phi;
    vector<double> Vec_Gard;

    interpol_cnem2d(Nb_Noeud,P_XY_Noeud,Nb_Front,P_Nb_Noeud_Front,P_Ind_Noeud_Front,Nb_PntInt,P_XY_PntInt,
                    &Vec_Ind_Noeud_New_Old,&Vec_Ind_Noeud_Old_New,&Vec_Nb_Contrib,&Vec_INV,&Vec_Phi,&Vec_Gard);

    //-----------------------------------------------------------------------//
    
    PyObject* Py_Res=PyTuple_New(5);

    PyTuple_SetItem(Py_Res,0,Vec_UL_2_Tuple_L(&Vec_Ind_Noeud_New_Old));
    PyTuple_SetItem(Py_Res,1,Vec_UL_2_Tuple_L(&Vec_Ind_Noeud_Old_New));
    PyTuple_SetItem(Py_Res,2,Vec_UL_2_Tuple_L(&Vec_Nb_Contrib));
    PyTuple_SetItem(Py_Res,3,Vec_UL_2_Tuple_L(&Vec_INV));
    PyTuple_SetItem(Py_Res,4,Vec_D_2_Tuple_F(&Vec_Phi));
    
    //-----------------------------------------------------------------------//

    free(P_XY_Noeud);
    free(P_Nb_Noeud_Front);
    free(P_Ind_Noeud_Front);
    free(P_XY_PntInt);

    return Py_Res;
}

PyObject* Py_MESH_CNEM2D(PyObject* self,PyObject* args)
{
    PyObject* Py_XY_Noeud;
    PyObject* Py_Nb_Noeud_Front;
    PyObject* Py_Ind_Noeud_Front;

    if(!PyArg_ParseTuple(args,"OOO",&Py_XY_Noeud,&Py_Nb_Noeud_Front,&Py_Ind_Noeud_Front))return (PyObject*)Py_BuildValue("");
    if(!PySequence_Check(Py_XY_Noeud))return (PyObject*)Py_BuildValue("");
    if(!PySequence_Check(Py_Nb_Noeud_Front))return (PyObject*)Py_BuildValue("");
    if(!PySequence_Check(Py_Ind_Noeud_Front))return (PyObject*)Py_BuildValue("");

    size_t Size;
    Size=PySequence_Size(Py_XY_Noeud);
    size_t Nb_Noeud=Size/2;
    double* P_XY_Noeud=Tuple_F_2_Tab_D(Py_XY_Noeud,Size);

    Size=PySequence_Size(Py_Nb_Noeud_Front);
    size_t Nb_Front=Size;
    size_t* P_Nb_Noeud_Front=Tuple_L_2_Tab_UL(Py_Nb_Noeud_Front,Size);
    
    Size=PySequence_Size(Py_Ind_Noeud_Front);
    size_t* P_Ind_Noeud_Front=Tuple_L_2_Tab_UL(Py_Ind_Noeud_Front,Size);
    
    //-----------------------------------------------------------------------//

    printf("\n\nCalling mesh cnem2d...\n\n");

    vector<size_t> Vec_Ind_Noeud_New_Old;
    vector<size_t> Vec_Ind_Noeud_Old_New;
    vector<size_t> Vec_Tri;

    mesh_cnem2d(Nb_Noeud,P_XY_Noeud,Nb_Front,P_Nb_Noeud_Front,P_Ind_Noeud_Front,
                &Vec_Ind_Noeud_New_Old,&Vec_Ind_Noeud_Old_New,&Vec_Tri);

    //-----------------------------------------------------------------------//
    
    PyObject* Py_Res=PyTuple_New(3);

    PyTuple_SetItem(Py_Res,0,Vec_UL_2_Tuple_L(&Vec_Ind_Noeud_New_Old));
    PyTuple_SetItem(Py_Res,1,Vec_UL_2_Tuple_L(&Vec_Ind_Noeud_Old_New));
    PyTuple_SetItem(Py_Res,2,Vec_UL_2_Tuple_L(&Vec_Tri));
    
    //-----------------------------------------------------------------------//

    free(P_XY_Noeud);
    free(P_Nb_Noeud_Front);
    free(P_Ind_Noeud_Front);

    return Py_Res;
}

static PyMethodDef Methods_Module_CNEM2D[]={
    {"SCNI_CNEM2D",Py_SCNI_CNEM2D,METH_VARARGS},
    {"INTERPOL_CNEM2D",Py_INTERPOL_CNEM2D,METH_VARARGS},
    {"MESH_CNEM2D",Py_INTERPOL_CNEM2D,METH_VARARGS},
    {NULL,NULL}};

#if PYTHON_VERSION == 2

extern "C" void initCNEM2D()
{
    Py_InitModule("CNEM2D",Methods_Module_CNEM2D);
}

#elif PYTHON_VERSION == 3

static struct PyModuleDef Module_CNEM2D = {
   PyModuleDef_HEAD_INIT,
   "CNEM2D",   /* name of module */
   NULL, /* module documentation, may be NULL */
   -1,   /* size of per-interpreter state of the module,
            or -1 if the module keeps state in global variables. */
   Methods_Module_CNEM2D
};

extern "C" PyMODINIT_FUNC PyInit_CNEM2D(void)
{
    return PyModule_Create(&Module_CNEM2D);
}

#endif
