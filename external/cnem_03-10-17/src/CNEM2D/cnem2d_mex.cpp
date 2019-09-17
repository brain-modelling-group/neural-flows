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

#if (_MSC_VER >= 1600)
#include <yvals.h>
#define __STDC_UTF_16__
#endif

#include "mex.h"
#include "scni_cnem2d.h"
#include "interpol_cnem2d.h"
#include "mesh_cnem2d.h"
#include "gauss_cnem2d.h"

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

mxArray* Map_2_Smx(Mat_Map* P_Mat_Map)
{
    if(P_Mat_Map->Row_Major)return NULL;

    mwSize m=P_Mat_Map->m_Size;
    mwSize n=P_Mat_Map->n_Size;
    mwSize nzmax=P_Mat_Map->Mat.size();

    mxArray* P_Sparse=mxCreateSparse(m,n,nzmax,mxREAL);
        
    double* Pr=mxGetPr(P_Sparse);
       mwIndex* Ir=mxGetIr(P_Sparse);
    mwIndex* Jc=mxGetJc(P_Sparse);

    //-----------------------------------------------------------------------//
   
    size_t i;
    for(i=0;i<=n;i++)Jc[i]=0;

    i=0;
    Map_KPL_D::iterator j;
    for(j=P_Mat_Map->Mat.begin();j!=P_Mat_Map->Mat.end();j++)
    {
        pair<pair<size_t,size_t>,double> Paire_j=*j;

        size_t I=Paire_j.first.second;
        size_t J=Paire_j.first.first;

        Jc[J+1]++;
        Pr[i]=Paire_j.second;
        Ir[i]=I;
        i++;
    }

    for(i=0;i<n;i++)Jc[i+1]+=Jc[i];

    //-----------------------------------------------------------------------//

    return P_Sparse;
}


void mexScni(mxArray* plhs[],const mxArray* prhs[])
{
    size_t Nb_Noeud=(size_t)mxGetN(prhs[0]);
    double* P_XY_Noeud=(double*)mxGetPr(prhs[0]);
    
    size_t Nb_Front=mxGetN(prhs[1]);
    size_t* P_Nb_Noeud_Front=(size_t*)mxGetData(prhs[1]);
    size_t* P_Ind_Noeud_Front=(size_t*)mxGetData(prhs[2]);

	size_t out_cel_vc=*((size_t*)mxGetData(prhs[3]));
	size_t axi=*((size_t*)mxGetData(prhs[4]));

    //-----------------------------------------------------------------------//

    vector<size_t> Vec_Ind_Noeud_New_Old;
    vector<size_t> Vec_Ind_Noeud_Old_New;
    vector<double> Vec_Vol_Cel;
    vector<double> Vec_XY_CdM;
    vector<size_t> Vec_Nb_Contrib;
    vector<size_t> Vec_INV;
    vector<double> Vec_Grad;
    
	vector<size_t> Vec_Tri;

	vector<size_t> Ind_Noeud_Cel;
	vector<size_t> Nb_S_Cel;
	vector<double> S_Cel;

	vector<size_t> Vec_Nb_Contrib_Int;
    vector<size_t> Vec_INV_Int;
    vector<double> Vec_Phi_Int;

	scni_cnem2d(Nb_Noeud,P_XY_Noeud,Nb_Front,P_Nb_Noeud_Front,P_Ind_Noeud_Front,out_cel_vc,axi,
                &Vec_Ind_Noeud_New_Old,&Vec_Ind_Noeud_Old_New,&Vec_Vol_Cel,&Vec_XY_CdM,&Vec_Nb_Contrib,&Vec_INV,&Vec_Grad,&Vec_Tri,
				&Ind_Noeud_Cel,&Nb_S_Cel,&S_Cel,&Vec_Nb_Contrib_Int,&Vec_INV_Int,&Vec_Phi_Int);

    //-----------------------------------------------------------------------//

    plhs[0]=VecS_2_MmxS(1,&Vec_Ind_Noeud_New_Old);
    plhs[1]=VecS_2_MmxS(1,&Vec_Ind_Noeud_Old_New);
    plhs[2]=VecD_2_MmxD(1,&Vec_Vol_Cel);
    plhs[3]=VecD_2_MmxD(2,&Vec_XY_CdM);
    plhs[4]=VecS_2_MmxS(1,&Vec_Nb_Contrib);
    plhs[5]=VecS_2_MmxS(1,&Vec_INV);
    plhs[6]=VecD_2_MmxD(2,&Vec_Grad);
    plhs[7]=VecS_2_MmxS(3,&Vec_Tri);

	size_t id_plhs=8;
	
	if(axi)
	{
		plhs[id_plhs]=VecS_2_MmxS(1,&Vec_Nb_Contrib_Int);id_plhs++;
		plhs[id_plhs]=VecS_2_MmxS(1,&Vec_INV_Int);id_plhs++;
		plhs[id_plhs]=VecD_2_MmxD(1,&Vec_Phi_Int);id_plhs++;
	}

	if(out_cel_vc)
	{
		plhs[id_plhs]=VecS_2_MmxS(1,&Ind_Noeud_Cel);id_plhs++;
		plhs[id_plhs]=VecS_2_MmxS(1,&Nb_S_Cel);id_plhs++;
		plhs[id_plhs]=VecD_2_MmxD(2,&S_Cel);id_plhs++;
	}

	//-----------------------------------------------------------------------//

    return;
}

void mexInterpol(mxArray* plhs[],const mxArray* prhs[])
{
    size_t Nb_Noeud=(size_t)mxGetN(prhs[0]);
    double* P_XY_Noeud=(double*)mxGetPr(prhs[0]);
    
    size_t Nb_Front=mxGetN(prhs[1]);
    size_t* P_Nb_Noeud_Front=(size_t*)mxGetData(prhs[1]);
    size_t* P_Ind_Noeud_Front=(size_t*)mxGetData(prhs[2]);

    size_t Nb_PntInt=(size_t)mxGetN(prhs[3]);
    double* P_XY_PntInt=(double*)mxGetPr(prhs[3]);

    //-----------------------------------------------------------------------//

    vector<size_t> Vec_Ind_Noeud_New_Old;
    vector<size_t> Vec_Ind_Noeud_Old_New;
    vector<size_t> Vec_Nb_Contrib;
    vector<size_t> Vec_INV;
    vector<double> Vec_Phi;

    interpol_cnem2d(Nb_Noeud,P_XY_Noeud,Nb_Front,P_Nb_Noeud_Front,P_Ind_Noeud_Front,Nb_PntInt,P_XY_PntInt,
                &Vec_Ind_Noeud_New_Old,&Vec_Ind_Noeud_Old_New,&Vec_Nb_Contrib,&Vec_INV,&Vec_Phi,NULL);

    //-----------------------------------------------------------------------//

    plhs[0]=VecS_2_MmxS(1,&Vec_Ind_Noeud_New_Old);
    plhs[1]=VecS_2_MmxS(1,&Vec_Ind_Noeud_Old_New);
    plhs[2]=VecS_2_MmxS(1,&Vec_Nb_Contrib);
    plhs[3]=VecS_2_MmxS(1,&Vec_INV);
    plhs[4]=VecD_2_MmxD(1,&Vec_Phi);

    //-----------------------------------------------------------------------//

    return;
}

void mexMesh(mxArray* plhs[],const mxArray* prhs[])
{
    size_t Nb_Noeud=(size_t)mxGetN(prhs[0]);
    double* P_XY_Noeud=(double*)mxGetPr(prhs[0]);
    
    size_t Nb_Front=mxGetN(prhs[1]);
    size_t* P_Nb_Noeud_Front=(size_t*)mxGetData(prhs[1]);
    size_t* P_Ind_Noeud_Front=(size_t*)mxGetData(prhs[2]);

    //-----------------------------------------------------------------------//

    vector<size_t> Vec_Ind_Noeud_New_Old;
    vector<size_t> Vec_Ind_Noeud_Old_New;
    vector<size_t> Vec_Tri;

    mesh_cnem2d(Nb_Noeud,P_XY_Noeud,Nb_Front,P_Nb_Noeud_Front,P_Ind_Noeud_Front,
                &Vec_Ind_Noeud_New_Old,&Vec_Ind_Noeud_Old_New,&Vec_Tri);

    //-----------------------------------------------------------------------//

    plhs[0]=VecS_2_MmxS(1,&Vec_Ind_Noeud_New_Old);
    plhs[1]=VecS_2_MmxS(1,&Vec_Ind_Noeud_Old_New);
    plhs[2]=VecS_2_MmxS(3,&Vec_Tri);

    //-----------------------------------------------------------------------//

    return;
}

void mexGauss(mxArray* plhs[],const mxArray* prhs[])
{
    size_t Nb_Noeud=(size_t)mxGetN(prhs[0]);
    double* P_XY_Noeud=(double*)mxGetPr(prhs[0]);
    
    size_t Nb_Front=mxGetN(prhs[1]);
    size_t* P_Nb_Noeud_Front=(size_t*)mxGetData(prhs[1]);
    size_t* P_Ind_Noeud_Front=(size_t*)mxGetData(prhs[2]);

	long Ind_LPG=*((double*)mxGetPr(prhs[3]));Ind_LPG--;
	long Axi=*((double*)mxGetPr(prhs[4]));

	double* Tab_Vec_Coef[5]={NULL,NULL,NULL,NULL,NULL};

	mxArray* Vec_k_mx=mxGetField(prhs[5],0,"k");
	if(Vec_k_mx!=NULL)Tab_Vec_Coef[0]=(double*)mxGetPr(Vec_k_mx);

	mxArray* Vec_roc_mx=mxGetField(prhs[5],0,"roc");
	if(Vec_roc_mx!=NULL)Tab_Vec_Coef[1]=(double*)mxGetPr(Vec_roc_mx);

	mxArray* Vec_nu_mx=mxGetField(prhs[5],0,"nu");
	if(Vec_nu_mx!=NULL)Tab_Vec_Coef[2]=(double*)mxGetPr(Vec_nu_mx);

	mxArray* Vec_lambda_mx=mxGetField(prhs[5],0,"lambda");
	if(Vec_lambda_mx!=NULL)Tab_Vec_Coef[3]=(double*)mxGetPr(Vec_lambda_mx);

    //-----------------------------------------------------------------------//

    vector<size_t> Vec_Ind_Noeud_New_Old;
    vector<size_t> Vec_Ind_Noeud_Old_New;
    vector<size_t> Vec_Tri;
	Mat_Map* Tab_Map_Mat[5]={NULL,NULL,NULL,NULL,NULL};
	
    gauss_cnem2d(Nb_Noeud,P_XY_Noeud,Nb_Front,P_Nb_Noeud_Front,P_Ind_Noeud_Front,Ind_LPG,Axi,0,0,
		         Tab_Vec_Coef,
			     &Vec_Ind_Noeud_New_Old,&Vec_Ind_Noeud_Old_New,&Vec_Tri,Tab_Map_Mat);

    //-----------------------------------------------------------------------//

    plhs[0]=VecS_2_MmxS(1,&Vec_Ind_Noeud_New_Old);
    plhs[1]=VecS_2_MmxS(1,&Vec_Ind_Noeud_Old_New);
    plhs[2]=VecS_2_MmxS(3,&Vec_Tri);

	const char* Mat_Names[5]={"kth","mth","khd","kme","mme"};
	plhs[3]=mxCreateStructMatrix(1,1,5,&Mat_Names[0]);

	if(Tab_Map_Mat[0]!=NULL){mxSetField(plhs[3],0,Mat_Names[0],Map_2_Smx(Tab_Map_Mat[0]));delete Tab_Map_Mat[0];}
	if(Tab_Map_Mat[1]!=NULL){mxSetField(plhs[3],0,Mat_Names[1],Map_2_Smx(Tab_Map_Mat[1]));delete Tab_Map_Mat[1];}
	if(Tab_Map_Mat[2]!=NULL){mxSetField(plhs[3],0,Mat_Names[2],Map_2_Smx(Tab_Map_Mat[2]));delete Tab_Map_Mat[2];}

    //------------------------------------------------------------- ----------//

    return;
}

void mexFunction(int nlhs,mxArray* plhs[],int nrhs,const mxArray* prhs[])
{   
	//mexWarnMsgTxt("\n\ncnem2d : scni and sibson interpolation\nplease contact illoul_amran@yahoo.fr for bug reporting\n\n");
    long job_id=*((double*)mxGetPr(prhs[0]));
    if (job_id==-1)mexPrintf("$Revision: 51 $ - $Date: 2013-04-12 18:21:29 +0200 (Fri, 12 Apr 2013) $\n");
	else if(job_id==0)mexScni(plhs,&prhs[1]);
    else if(job_id==1)mexInterpol(plhs,&prhs[1]);
    else if(job_id==2)mexMesh(plhs,&prhs[1]);
	else if(job_id==3)mexGauss(plhs,&prhs[1]);
}
