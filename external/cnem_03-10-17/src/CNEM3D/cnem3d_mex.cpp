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

//#include <yvals.h>
#if (_MSC_VER >= 1600)
#define __STDC_UTF_16__
#endif

#include "mex.h"
#include "scni_cnem3d.h"
#include "interpol_cnem3d.h"
#include "mesh_cnem3d.h"
#include "tetgen.h"


mxArray* VecD_2_MmxD(size_t dim,vector<double>* P_Vec)
{
    mxArray* Mmx=mxCreateNumericMatrix(dim,P_Vec->size()/dim,mxDOUBLE_CLASS,mxREAL);
    double* Pr_Mmx=(double*)mxGetPr(Mmx);
    size_t i;for(i=0;i<P_Vec->size();i++)Pr_Mmx[i]=P_Vec->at(i);
    return Mmx;
}

mxArray* VecS_2_MmxS(size_t dim,vector<size_t>* P_Vec)
{
    mxArray* Mmx=mxCreateNumericMatrix(dim,P_Vec->size()/dim,mxINDEX_CLASS,mxREAL);
    size_t* Pr_Mmx=(size_t*)mxGetPr(Mmx);
    size_t i;for(i=0;i<P_Vec->size();i++)Pr_Mmx[i]=P_Vec->at(i);
    return Mmx;
}

void mexScni(mxArray* plhs[],const mxArray* prhs[])
{
    size_t Nb_Noeud=(size_t)mxGetN(prhs[0]);
    double* Tab_Noeud=(double*)mxGetPr(prhs[0]);
    
    size_t Nb_Tri_Front=(size_t)mxGetN(prhs[1]);
    size_t* Tab_Ind_Noeud_Tri_Front=(size_t*)mxGetPr(prhs[1]);

    size_t Type_Appel_Tetgen=*((double*)mxGetPr(prhs[2]));
    size_t Type_FF=*((double*)mxGetPr(prhs[3]));
    bool Sup_NN_GS=*((double*)mxGetPr(prhs[4]));
    //size_t nb_core_for_gs_cal=*((double*)mxGetPr(prhs[5]));

    size_t Type_Int=0;

    //-----------------------------------------------------------------------//

    vector<size_t> Vec_Ind_Noeud_New_Old;
    vector<size_t> Vec_Ind_Noeud_Old_New;
    vector<double> Vec_New_Noeud;
    vector<size_t> Vec_INVNN;
    vector<double> Vec_PNVNN;
    vector<double> Vec_Vol_Cel;
    vector<size_t> Vec_Nb_Contrib;
    vector<size_t> Vec_INV;
    vector<double> Vec_Grad;
    vector<size_t> Vec_Ind_Noeud_New_Tri;
    vector<size_t> Vec_Ind_Noeud_Tet;

    if(scni_cnem3d
       (Nb_Noeud,Tab_Noeud,Nb_Tri_Front,Tab_Ind_Noeud_Tri_Front,
        Type_Appel_Tetgen,Sup_NN_GS,Type_Int,Type_FF,/*nb_core_for_gs_cal,*/
        &Vec_Ind_Noeud_New_Old,&Vec_Ind_Noeud_Old_New,&Vec_New_Noeud,&Vec_INVNN,&Vec_PNVNN,
        &Vec_Vol_Cel,&Vec_Nb_Contrib,&Vec_INV,&Vec_Grad,
        &Vec_Ind_Noeud_New_Tri,&Vec_Ind_Noeud_Tet))
        return ;

    //-----------------------------------------------------------------------//

    plhs[0]=VecS_2_MmxS(1,&Vec_Ind_Noeud_New_Old);
    plhs[1]=VecS_2_MmxS(1,&Vec_Ind_Noeud_Old_New);
    plhs[2]=VecD_2_MmxD(3,&Vec_New_Noeud);
    plhs[3]=VecS_2_MmxS(3,&Vec_INVNN);
    plhs[4]=VecD_2_MmxD(3,&Vec_PNVNN);
    plhs[5]=VecD_2_MmxD(1,&Vec_Vol_Cel);
    plhs[6]=VecS_2_MmxS(1,&Vec_Nb_Contrib);
    plhs[7]=VecS_2_MmxS(1,&Vec_INV);
    plhs[8]=VecD_2_MmxD(3,&Vec_Grad);
    plhs[9]=VecS_2_MmxS(3,&Vec_Ind_Noeud_New_Tri);
    plhs[10]=VecS_2_MmxS(4,&Vec_Ind_Noeud_Tet);
    
    //-----------------------------------------------------------------------//

    return;
}

void mexInterpol(mxArray* plhs[],const mxArray* prhs[])
{
    size_t Nb_Noeud=(size_t)mxGetN(prhs[0]);
    double* Tab_Noeud=(double*)mxGetPr(prhs[0]);
    
    size_t Nb_Tri_Front=(size_t)mxGetN(prhs[1]);
    size_t* Tab_Ind_Noeud_Tri_Front=(size_t*)mxGetPr(prhs[1]);

    size_t Nb_Point=(size_t)mxGetN(prhs[2]);
    double* Tab_Point=(double*)mxGetPr(prhs[2]);

    size_t Type_Appel_Tetgen=*((double*)mxGetPr(prhs[3]));
    size_t Type_FF=*((double*)mxGetPr(prhs[4]));
    //size_t nb_core_for_ff_cal=*((double*)mxGetPr(prhs[5]));

    //-----------------------------------------------------------------------//

    vector<size_t> Vec_Ind_Noeud_New_Old;
    vector<size_t> Vec_Ind_Noeud_Old_New;
    vector<size_t> Vec_INVNN;
    vector<double> Vec_PNVNN;
    vector<size_t> Vec_Ind_Point;
    vector<size_t> Vec_Nb_Contrib;
    vector<size_t> Vec_INV;
    vector<double> Vec_Phi;

    if(interpol_cnem3d
       (Nb_Noeud,Tab_Noeud,Nb_Tri_Front,Tab_Ind_Noeud_Tri_Front,
        Nb_Point,Tab_Point,
        Type_Appel_Tetgen,Type_FF,/*nb_core_for_ff_cal,*/
        &Vec_Ind_Noeud_New_Old,&Vec_Ind_Noeud_Old_New,&Vec_INVNN,&Vec_PNVNN,
        &Vec_Ind_Point,&Vec_Nb_Contrib,&Vec_INV,&Vec_Phi,NULL))
        return ;

    //-----------------------------------------------------------------------//

    plhs[0]=VecS_2_MmxS(1,&Vec_Ind_Noeud_New_Old);
    plhs[1]=VecS_2_MmxS(1,&Vec_Ind_Noeud_Old_New);
    plhs[2]=VecS_2_MmxS(3,&Vec_INVNN);
    plhs[3]=VecD_2_MmxD(3,&Vec_PNVNN);
    plhs[4]=VecS_2_MmxS(1,&Vec_Ind_Point);
    plhs[5]=VecS_2_MmxS(1,&Vec_Nb_Contrib);
    plhs[6]=VecS_2_MmxS(1,&Vec_INV);
    plhs[7]=VecD_2_MmxD(1,&Vec_Phi);
    
    //-----------------------------------------------------------------------//

    return;
}

void mexSibsonRaw(mxArray* plhs[],const mxArray* prhs[])
{
    size_t Nb_Noeud=(size_t)mxGetN(prhs[0]);
    double* Tab_Noeud=(double*)mxGetPr(prhs[0]);
    
    size_t Nb_Tri_Front=(size_t)mxGetN(prhs[1]);
    size_t* Tab_Ind_Noeud_Tri_Front=(size_t*)mxGetPr(prhs[1]);

    size_t Nb_Point=(size_t)mxGetN(prhs[2]);
    double* Tab_Point=(double*)mxGetPr(prhs[2]);

    size_t Type_Appel_Tetgen=*((double*)mxGetPr(prhs[3]));
    
    //size_t nb_core_for_ff_cal=*((double*)mxGetPr(prhs[5]));

    //-----------------------------------------------------------------------//

    vector<size_t> Vec_Ind_Noeud_New_Old;
    vector<size_t> Vec_Ind_Noeud_Old_New;
    vector<size_t> Vec_INVNN;
    vector<double> Vec_PNVNN;
    vector<size_t> Vec_Ind_Point;
    vector<size_t> Vec_Nb_Contrib;
    vector<size_t> Vec_INV;
    vector<double> Vec_Phi;
	vector<double> Vec_Grad;

    if(interpol_cnem3d
       (Nb_Noeud,Tab_Noeud,Nb_Tri_Front,Tab_Ind_Noeud_Tri_Front,
        Nb_Point,Tab_Point,
        Type_Appel_Tetgen,3,/*nb_core_for_ff_cal,*/
        &Vec_Ind_Noeud_New_Old,&Vec_Ind_Noeud_Old_New,&Vec_INVNN,&Vec_PNVNN,
        &Vec_Ind_Point,&Vec_Nb_Contrib,&Vec_INV,&Vec_Phi,&Vec_Grad))
        return ;

    //-----------------------------------------------------------------------//

    plhs[0]=VecS_2_MmxS(1,&Vec_Ind_Noeud_New_Old);
    plhs[1]=VecS_2_MmxS(1,&Vec_Ind_Noeud_Old_New);
    plhs[2]=VecS_2_MmxS(3,&Vec_INVNN);
    plhs[3]=VecD_2_MmxD(3,&Vec_PNVNN);
    plhs[4]=VecS_2_MmxS(1,&Vec_Ind_Point);
    plhs[5]=VecS_2_MmxS(1,&Vec_Nb_Contrib);
    plhs[6]=VecS_2_MmxS(1,&Vec_INV);
    plhs[7]=VecD_2_MmxD(1,&Vec_Phi);
    plhs[8]=VecD_2_MmxD(3,&Vec_Grad);

    //-----------------------------------------------------------------------//

    return;
}

void mexMesh(mxArray* plhs[],const mxArray* prhs[])
{
    size_t Nb_Noeud=(size_t)mxGetN(prhs[0]);
    double* Tab_Noeud=(double*)mxGetPr(prhs[0]);
    
    size_t Nb_Tri_Front=(size_t)mxGetN(prhs[1]);
    size_t* Tab_Ind_Noeud_Tri_Front=(size_t*)mxGetPr(prhs[1]);

    size_t Type_Appel_Tetgen=*((double*)mxGetPr(prhs[2]));

    //-----------------------------------------------------------------------//

    vector<size_t> Vec_Ind_Noeud_New_Old;
    vector<size_t> Vec_Ind_Noeud_Old_New;
    vector<double> Vec_New_Noeud;
    vector<size_t> Vec_Ind_Noeud_New_Tri;
    vector<size_t> Vec_Ind_Noeud_Tet;

    if(mesh_cnem3d
       (Nb_Noeud,Tab_Noeud,Nb_Tri_Front,Tab_Ind_Noeud_Tri_Front,
        Type_Appel_Tetgen,
        &Vec_Ind_Noeud_New_Old,&Vec_Ind_Noeud_Old_New,&Vec_New_Noeud,
        &Vec_Ind_Noeud_New_Tri,&Vec_Ind_Noeud_Tet))
        return ;

    //-----------------------------------------------------------------------//

    plhs[0]=VecS_2_MmxS(1,&Vec_Ind_Noeud_New_Old);
    plhs[1]=VecS_2_MmxS(1,&Vec_Ind_Noeud_Old_New);
    plhs[2]=VecD_2_MmxD(3,&Vec_New_Noeud);
    plhs[3]=VecS_2_MmxS(3,&Vec_Ind_Noeud_New_Tri);
    plhs[4]=VecS_2_MmxS(4,&Vec_Ind_Noeud_Tet);
    
    //-----------------------------------------------------------------------//

    return;
}

void mexFunction(int nlhs,mxArray* plhs[],int nrhs,const mxArray* prhs[])
{
    long job_id=*((double*)mxGetPr(prhs[0]));
	if(job_id==-1)mexPrintf("$Revision: 108 $ - $Date: 2015-11-26 13:42:10 +0100 (Thu, 26 Nov 2015) $\n");
    else if(job_id==0)mexScni(plhs,&prhs[1]);
    else if(job_id==1)mexInterpol(plhs,&prhs[1]);
	else if(job_id==2)mexMesh(plhs,&prhs[1]);
	else if(job_id==3)mexSibsonRaw(plhs,&prhs[1]);
}
