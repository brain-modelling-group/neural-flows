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

#include "C_Meshless_3d.h"

#include "InterpolParal.h"

long interpol_cnem3d
(//IN
size_t Nb_Noeud,
double* Tab_Noeud,
size_t Nb_Tri_Front,
size_t* Tab_Ind_Noeud_Tri_Front,
size_t Nb_Point,
double* Tab_Point,
size_t Type_Appel_Tetgen,
size_t Type_FF,
/*size_t nb_core_for_ff_cal,*/
//OUT
vector<size_t>* P_Vec_Ind_Noeud_New_Old,
vector<size_t>* P_Vec_Ind_Noeud_Old_New,
vector<size_t>* P_Vec_INVNN,
vector<double>* P_Vec_PNVNN,
vector<size_t>* P_Vec_Ind_Point,
vector<size_t>* P_Vec_Nb_Contrib,
vector<size_t>* P_Vec_INV,
vector<double>* P_Vec_Phi,
vector<double>* P_Vec_Gard
)
{
/*
int main()
{
size_t Nb_Tri_Front=0;
size_t* Tab_Ind_Noeud_Tri_Front=NULL;

size_t Nb_Noeud=0;
double* Tab_Noeud=NULL;

size_t Nb_Point=0;
double* Tab_Point=NULL;

ifstream data;
data.open("data_test",ios::binary);
data.read((char*)&Nb_Noeud,sizeof(size_t));
Tab_Noeud=(double*)malloc(sizeof(double)*3*Nb_Noeud);
data.read((char*)Tab_Noeud,sizeof(double)*3*Nb_Noeud);
data.read((char*)&Nb_Point,sizeof(size_t));
Tab_Point=(double*)malloc(sizeof(double)*3*Nb_Point);
data.read((char*)Tab_Point,sizeof(double)*3*Nb_Point);
data.close();

size_t Type_Appel_Tetgen=1;
size_t Type_FF=0;
size_t nb_core_for_ff_cal=1;
//OUT
vector<size_t>* P_Vec_Ind_Noeud_New_Old=new vector<size_t>;
vector<size_t>* P_Vec_Ind_Noeud_Old_New=new vector<size_t>;
vector<size_t>* P_Vec_INVNN=new vector<size_t>;
vector<double>* P_Vec_PNVNN=new vector<double>;
vector<size_t>* P_Vec_Ind_Point=new vector<size_t>;
vector<size_t>* P_Vec_Nb_Contrib=new vector<size_t>;
vector<size_t>* P_Vec_INV=new vector<size_t>;
vector<double>* P_Vec_Phi=new vector<double>;
vector<double>* P_Vec_Gard=new vector<double>;
*/
    //-----------------------------------------------------------------------//

    size_t i;
    
    double* Copy_Tab_Noeud=(double*)malloc(3*Nb_Noeud*sizeof(double));
    long* Copy_Tab_Ind_Noeud_Tri_Front=(Nb_Tri_Front!=0)?(long*)malloc(3*Nb_Tri_Front*sizeof(long)):NULL;
    
    memcpy(Copy_Tab_Noeud,Tab_Noeud,3*Nb_Noeud*sizeof(double));
    if(Nb_Tri_Front!=0)for(i=0;i<3*Nb_Tri_Front;i++)Copy_Tab_Ind_Noeud_Tri_Front[i]=Tab_Ind_Noeud_Tri_Front[i];

    //-----------------------------------------------------------------------//

    C_Meshless_3d* PML= new C_Meshless_3d(Nb_Noeud,Copy_Tab_Noeud,Nb_Tri_Front,Copy_Tab_Ind_Noeud_Tri_Front,1.e-9,0);

    //cout<<"\nConstruction base--------------------------------------------------------------\n"<<endl;

    vector<long> Ind_Voisin;
    vector<double> Phi_Voisin;

    if(Nb_Tri_Front!=0)
    {
        PML->Verif_Topo_Tri_Front_et_Initialise_Set_Ind_Noeud_Front_0();

        if(!PML->Voronoi_Contrain_TetGen(Type_Appel_Tetgen,"pnV",1,0))
        {
            free(Copy_Tab_Noeud);
            free(Copy_Tab_Ind_Noeud_Tri_Front);
            return(1);
        }
     
        PML->Calcul_Interpolation_Noeud_Esclave(&Ind_Voisin,&Phi_Voisin);
    }
    else
    {
        if(!PML->Voronoi_Contrain_TetGen(Type_Appel_Tetgen,"nV",0,0))
        {
            free(Copy_Tab_Noeud);
            return(1);
        }
    }

    //cout<<"\nConstruction base ok...\n"<<endl;

    //-----------------------------------------------------------------------//

    //cout<<"\ninterpolation------------------------------------------------------------------\n"<<endl;

    //task_scheduler_init init(nb_core_for_ff_cal);
	size_t nb_core_for_ff_cal=task_scheduler_init::default_num_threads();
    
    //cout<<"\nnb thread : "<<nb_core_for_ff_cal<<endl;
    
    InterpolParal
        (PML,Nb_Point,Tab_Point,Type_FF,nb_core_for_ff_cal,
         P_Vec_Ind_Point,P_Vec_Nb_Contrib,P_Vec_INV,P_Vec_Phi,P_Vec_Gard);

    //cout<<"\ninterpoltaion ok...\n"<<endl;

    //-----------------------------------------------------------------------//
    // Sortie corespandance noeus new to old et inv:
    //----------------------------------------------
    
    for(i=0;i<PML->New_Ind_Old_Noeud_Ini.size();i++)P_Vec_Ind_Noeud_New_Old->push_back(PML->New_Ind_Old_Noeud_Ini[i]+1);
    for(i=0;i<PML->Old_Ind_New_Noeud_Ini.size();i++)P_Vec_Ind_Noeud_Old_New->push_back(PML->Old_Ind_New_Noeud_Ini[i]+1);
    P_Vec_INVNN->assign(Ind_Voisin.begin(),Ind_Voisin.end());
    P_Vec_PNVNN->assign(Phi_Voisin.begin(),Phi_Voisin.end());

    //-----------------------------------------------------------------------//
/*
    set<long> Set_Ind_Noeud_GU;
    vector<C_Sommet*>::iterator J;
    for(J=PML->Diag_Vor.List_Sommet.begin();J!=PML->Diag_Vor.List_Sommet.end();J++)
    {
        C_Sommet* P_Sommet_J=*J;
        if((P_Sommet_J->Valide)&&(P_Sommet_J->Type==0)&&(!P_Sommet_J->Sommet_Infinie))
        {
            if((Nb_Tri_Front==0)||(P_Sommet_J->Ind_Group==1))
                for(i=0;i<4;i++)Set_Ind_Noeud_GU.insert(P_Sommet_J->Ind_Noeud[i]);
        }
    }
    P_Vec_Ind_Noeud_GU->assign(Set_Ind_Noeud_GU.begin(),Set_Ind_Noeud_GU.end());
*/    
    delete(PML);

    free(Copy_Tab_Noeud);
    if(Nb_Tri_Front!=0)free(Copy_Tab_Ind_Noeud_Tri_Front);

    //-----------------------------------------------------------------------//

    return 0;
}
