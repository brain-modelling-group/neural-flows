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
#include "GradStabParal.h"
#include "out_elem_celqt.h"

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
vector<size_t>* P_Vec_Ind_Noeud_Tet)
{
    //-----------------------------------------------------------------------//
    
    size_t i;

    double* Copy_Tab_Noeud=(double*)malloc(3*Nb_Noeud*sizeof(double));
    long* Copy_Tab_Ind_Noeud_Tri_Front=(long*)malloc(3*Nb_Tri_Front*sizeof(long));
    
    memcpy(Copy_Tab_Noeud,Tab_Noeud,3*Nb_Noeud*sizeof(double));
    if(Nb_Tri_Front!=0)for(i=0;i<3*Nb_Tri_Front;i++)Copy_Tab_Ind_Noeud_Tri_Front[i]=Tab_Ind_Noeud_Tri_Front[i];

    //-----------------------------------------------------------------------//

    C_Meshless_3d* PML= new C_Meshless_3d(Nb_Noeud,Copy_Tab_Noeud,Nb_Tri_Front,Copy_Tab_Ind_Noeud_Tri_Front,1.e-9,0);

    cout<<"\nConstruction base--------------------------------------------------------------\n"<<endl;

    vector<long> Ind_Voisin;
    vector<double> Phi_Voisin;

    if(Nb_Tri_Front!=0)
    {
        PML->Verif_Topo_Tri_Front_et_Initialise_Set_Ind_Noeud_Front_0();

        if(!PML->Voronoi_Contrain_TetGen(Type_Appel_Tetgen,"pnV",0,1))
        {
            free(Copy_Tab_Noeud);
            free(Copy_Tab_Ind_Noeud_Tri_Front);
            return(1);
        }
     
        PML->Calcul_Interpolation_Noeud_Esclave(&Ind_Voisin,&Phi_Voisin);
    }
    else
    {
        if(!PML->Voronoi_Contrain_TetGen(Type_Appel_Tetgen,"nV",0,1))
        {
            free(Copy_Tab_Noeud);
            return(1);
        }
    }

    vector<long> Tab_Ind_S_Elem_Tet;
    vector<long> Tab_Id_in_S_Elem_Tet;
    vector<long> Tab_Ind_Noeud_Hexa;
    vector<long> Tab_Ind_Cel_Elem_Hexa;
    vector<long> Tab_Ind_Noeud_Tet;
    vector<long> Tab_Ind_Cel_Elem_Tet;
    vector<double> Tab_Coord_Noeud_Elem;
    vector<long> Tab_Nb_Voisin_Noeud_Elem;
    vector<long> Tab_Ind_Voisin_Noeud_Elem;
    vector<double> Tab_Phi_Voisin_Noeud_Elem;

    out_elem_celqt(PML,&Ind_Voisin,&Phi_Voisin,
                   &Tab_Ind_Noeud_Hexa,&Tab_Ind_Cel_Elem_Hexa,
                   &Tab_Ind_Noeud_Tet,&Tab_Ind_Cel_Elem_Tet,
                   &Tab_Ind_S_Elem_Tet,&Tab_Id_in_S_Elem_Tet,
                   &Tab_Coord_Noeud_Elem,
                   &Tab_Nb_Voisin_Noeud_Elem,&Tab_Ind_Voisin_Noeud_Elem,&Tab_Phi_Voisin_Noeud_Elem);

    cout<<"\nConstruction base ok...\n"<<endl;

    //-----------------------------------------------------------------------//

    cout<<"\nIntegration -------------------------------------------------------------------\n"<<endl;

    //task_scheduler_init init(nb_core_for_gs_cal);
	size_t nb_core_for_gs_cal=8; //task_scheduler_init::default_num_threads();
    
    cout<<"\nnb thread : "<<nb_core_for_gs_cal<<endl;
        
    concurrent_hash_map<const long,C_Vec3d,HashCompareGSKey>** Tab_Gradiant_Stabilisee=NULL;
    double* Tab_Volume_Cellule=NULL;
     
    Integration_Stabilisee_Paral
        (PML,Tab_Gradiant_Stabilisee,Tab_Volume_Cellule,Type_Int,Type_FF,nb_core_for_gs_cal,Sup_NN_GS,
         &Ind_Voisin,&Phi_Voisin,
         &Tab_Ind_Noeud_Tet,&Tab_Ind_Cel_Elem_Tet,&Tab_Ind_S_Elem_Tet,&Tab_Id_in_S_Elem_Tet,&Tab_Coord_Noeud_Elem);

    cout<<"\nIntegration ok...\n"<<endl;

    //-----------------------------------------------------------------------//
    // Sortie corespandance noeus new to old et inv:
    //----------------------------------------------
    
    for(i=0;i<PML->New_Ind_Old_Noeud_Ini.size();i++)P_Vec_Ind_Noeud_New_Old->push_back(PML->New_Ind_Old_Noeud_Ini[i]+1);
    for(i=0;i<PML->Old_Ind_New_Noeud_Ini.size();i++)P_Vec_Ind_Noeud_Old_New->push_back(PML->Old_Ind_New_Noeud_Ini[i]+1);

    //-----------------------------------------------------------------------//
    // New Noeuds:
    //------------

    for(i=3*PML->Nb_Noeud_Ini;i<3*PML->Diag_Vor.Nb_Noeud;i++)P_Vec_New_Noeud->push_back(PML->Diag_Vor.Tab_Noeud[i]);
    for(i=0;i<Ind_Voisin.size();i++){P_Vec_INVNN->push_back(Ind_Voisin[i]);P_Vec_PNVNN->push_back(Phi_Voisin[i]);}

    //-----------------------------------------------------------------------//
    //Sortie grad stab:
    //-----------------

    long Size_Tab_GS=Sup_NN_GS?PML->Nb_Noeud_Ini:PML->Diag_Vor.Nb_Noeud;

    for(i=0;i<Size_Tab_GS;i++)
    {
        P_Vec_Vol_Cel->push_back(Tab_Volume_Cellule[i]);
        P_Vec_Nb_Contrib->push_back(Tab_Gradiant_Stabilisee[i]->size());
        concurrent_hash_map<const long,C_Vec3d,HashCompareGSKey>::iterator j;
        for(j=Tab_Gradiant_Stabilisee[i]->begin();j!=Tab_Gradiant_Stabilisee[i]->end();j++)
        {
            pair<const long,C_Vec3d> paire_j=*j;
            P_Vec_INV->push_back(paire_j.first);
            P_Vec_Grad->push_back(paire_j.second.X());
            P_Vec_Grad->push_back(paire_j.second.Y());
            P_Vec_Grad->push_back(paire_j.second.Z());
        }
    }

    //-----------------------------------------------------------------------//
    //Sortie new Tri:
    //---------------

    for(i=0;i<3*PML->Nb_Tri_Front;i++)P_Vec_Ind_Noeud_New_Tri->push_back(PML->Tab_Ind_Noeud_Tri_Front[i]);

    //-----------------------------------------------------------------------//
    //Sortie tet:
    //-----------

    vector<C_Sommet*>::iterator J;
    for(J=PML->Diag_Vor.List_Sommet.begin();J!=PML->Diag_Vor.List_Sommet.end();J++)
    {
        C_Sommet* P_Sommet_J=*J;
        if((P_Sommet_J->Valide)&&(P_Sommet_J->Type==0)&&(!P_Sommet_J->Sommet_Infinie))
        {
            P_Vec_Ind_Noeud_Tet->push_back(P_Sommet_J->Ind_Noeud[1]);
            P_Vec_Ind_Noeud_Tet->push_back(P_Sommet_J->Ind_Noeud[0]);
            P_Vec_Ind_Noeud_Tet->push_back(P_Sommet_J->Ind_Noeud[2]);
            P_Vec_Ind_Noeud_Tet->push_back(P_Sommet_J->Ind_Noeud[3]);
        }
    }

    //-----------------------------------------------------------------------//
    cout<<"\nFreeing stuff...\n"<<endl;

    for(i=0;i<Size_Tab_GS;i++)delete Tab_Gradiant_Stabilisee[i];
    free(Tab_Gradiant_Stabilisee);
    free(Tab_Volume_Cellule);

    delete(PML);

    free(Copy_Tab_Noeud);
    if(Nb_Tri_Front!=0)free(Copy_Tab_Ind_Noeud_Tri_Front);

    //-----------------------------------------------------------------------//

    return 0;
}
