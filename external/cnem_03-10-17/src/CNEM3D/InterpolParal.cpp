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

//---------------------------------------------------------------------------//
// Interpolation 3d paralelle

#include "InterpolParal.h"

//---------------------------------------------------------------------------//

class Interpol_Task: public task 
{
public:
    C_Meshless_3d* PML;
    size_t Nb_Point;
    double* Tab_Point;
    long Type_FF;
    vector<size_t>* P_Vec_Ind_Point;
    vector<size_t>* P_Vec_Nb_Contrib;
    vector<size_t>* P_Vec_INV;
    vector<double>* P_Vec_Phi;
    vector<double>* P_Vec_Grad;
    long* P_Ind_Point;
    mutex* P_Mutex_IP;
    mutex* P_Mutex_LO;
    mutex* P_Mutex_P;
    long Nb_P;
    long id_task;

    Interpol_Task(C_Meshless_3d* PML_,
                    size_t Nb_Point_,
                    double* Tab_Point_,
                    long Type_FF_,
                    vector<size_t>* P_Vec_Ind_Point_,
                    vector<size_t>* P_Vec_Nb_Contrib_,
                    vector<size_t>* P_Vec_INV_,
                    vector<double>* P_Vec_Phi_,
                    vector<double>* P_Vec_Grad_,
                    long* P_Ind_Point_,
                    mutex* P_Mutex_IP_,
                    mutex* P_Mutex_LO_,
                    mutex* P_Mutex_P_,
                    long id_task_):
                    PML(PML_),
                    Nb_Point(Nb_Point_),
                    Tab_Point(Tab_Point_),
                    Type_FF(Type_FF_),
                    P_Vec_Ind_Point(P_Vec_Ind_Point_),
                    P_Vec_Nb_Contrib(P_Vec_Nb_Contrib_),
                    P_Vec_INV(P_Vec_INV_),
                    P_Vec_Phi(P_Vec_Phi_),
                    P_Vec_Grad(P_Vec_Grad_),
                    P_Ind_Point(P_Ind_Point_),
                    P_Mutex_IP(P_Mutex_IP_),
                    P_Mutex_LO(P_Mutex_LO_),
                    P_Mutex_P(P_Mutex_P_),
                    id_task(id_task_){}
    task* execute();
};

task* Interpol_Task::execute()
{
    //-----------------------------------------------------------------------//

    long Nb_Sommet=PML->Diag_Vor.List_Sommet.size();
    long Nb_Noeud=PML->Diag_Vor.Nb_Noeud;
    double* Tab_Contrib_Voisin_Tampon=(double*)malloc(Nb_Noeud*sizeof(double));
    bool* Tab_Voisin_O_N_Tampon=(bool*)malloc(Nb_Noeud*sizeof(bool));
    bool* Tab_Sommet_Visite=(bool*)malloc(Nb_Sommet*sizeof(bool));
    long Size_Tab_Ind_Voisin=100;
    long* Tab_Ind_Voisin=(long*)malloc(Size_Tab_Ind_Voisin*sizeof(long));

    long i;
    for(i=0;i<Nb_Noeud;i++){Tab_Contrib_Voisin_Tampon[i]=0.;Tab_Voisin_O_N_Tampon[i]=0;}
    for(i=0;i<Nb_Sommet;i++)Tab_Sommet_Visite[i]=0;

    //-----------------------------------------------------------------------//

    vector<size_t> Vec_Ind_Point_Loc;
    vector<size_t> Vec_Nb_Contrib_Loc;
    vector<size_t> Vec_INV_Loc;
    vector<double> Vec_Phi_Loc;
	vector<double> Vec_Grad_Loc;

	bool Cal_Grad=(P_Vec_Grad==NULL)?0:1;
    
    double Erreur_Max_FF=0.;
    long Ind_Erreur=-1;
    long Type_Erreur=-1;
    long Ind_Point;
    Nb_P=0;
    
    //cout<<endl;

    long Ind_Sommet_Initialisation=-1;
    long Nb_C_Nb=-1;
    do
    {     
//---------------------------------------------------------------------------//
// Début section critique...
//---------------------------------------------------------------------------//
        {
            mutex::scoped_lock Lock_IP(*P_Mutex_IP);
            Ind_Point=*P_Ind_Point;
            (*P_Ind_Point)++;
        }
//---------------------------------------------------------------------------//
// Fin section critique...
//---------------------------------------------------------------------------//

        if(Ind_Point>=Nb_Point)
            break;

        if(id_task==0)
        {
            long I=100.*double(Ind_Point)/double(Nb_Point);
            //if(!(I%5))
            //{
            //    char Char[255];sprintf(Char,"%ld",I);string Nb(Char);//for(i=0;i<=Nb_C_Nb;i++)cout<<"\b";Nb_C_Nb=Nb.size();cout<<I<<'%';cout.flush();
            //}
        }
        
        Vec_Ind_Point_Loc.push_back(Ind_Point);
        double Point_a_Inserer[3]={Tab_Point[3*Ind_Point],Tab_Point[3*Ind_Point+1],Tab_Point[3*Ind_Point+2]};
        long Ind_Face=-1;
        long Ind_Noeud=-1;
        C_Sommet* P_Sommet=PML->Descente_Gradiant(Ind_Sommet_Initialisation,Point_a_Inserer,&Ind_Face,&Ind_Noeud);

        if(P_Sommet!=NULL)
        {
            if(!P_Sommet->Ghost)
            {
                if(Ind_Noeud!=-1)
                {
                    Vec_Nb_Contrib_Loc.push_back(1);
                    Vec_INV_Loc.push_back(P_Sommet->Ind_Noeud[Ind_Noeud]);
                    Vec_Phi_Loc.push_back(1.);
					if(Cal_Grad){Vec_Grad_Loc.push_back(0.);Vec_Grad_Loc.push_back(0.);Vec_Grad_Loc.push_back(0.);}
                }
                else if(Ind_Face!=-1)
                {
                    double FoFo[3];
                    PML->Fonction_de_Forme_FEM_LINAIRE_sur_Tri(P_Sommet,Ind_Face,1,&Point_a_Inserer,&FoFo);
                    Vec_Nb_Contrib_Loc.push_back(3);
                    for(i=0;i<3;i++)
                    {
                        Vec_INV_Loc.push_back(P_Sommet->Ind_Noeud[(Ind_Face+i)%4]);
                        Vec_Phi_Loc.push_back(FoFo[i]);
						if(Cal_Grad){Vec_Grad_Loc.push_back(0.);Vec_Grad_Loc.push_back(0.);Vec_Grad_Loc.push_back(0.);}
                    }
                }
                else
                {
                    vector<S_FoFo> List_SFoFo;
                    double Erreur=PML->Fonction_de_Forme(Type_FF,Point_a_Inserer,P_Sommet,&List_SFoFo,
                                                         Tab_Sommet_Visite,Tab_Voisin_O_N_Tampon,Tab_Contrib_Voisin_Tampon,
                                                         Tab_Ind_Voisin,Size_Tab_Ind_Voisin);
                    if(Erreur>Erreur_Max_FF){Erreur_Max_FF=Erreur;}//Ind_Erreur=Paire_j.first;Type_Erreur=0;}
                    long Nb_FoFo=List_SFoFo.size();    
                    Vec_Nb_Contrib_Loc.push_back(Nb_FoFo);
                    for(i=0;i<Nb_FoFo;i++)
                    {
                        S_FoFo FoFo_i=List_SFoFo[i];
                        Vec_INV_Loc.push_back(FoFo_i.Ind_Voisin);
                        Vec_Phi_Loc.push_back(FoFo_i.Valeur_FF);
						if(Cal_Grad){Vec_Grad_Loc.push_back(FoFo_i.Grad_FF.X());Vec_Grad_Loc.push_back(FoFo_i.Grad_FF.Y());Vec_Grad_Loc.push_back(FoFo_i.Grad_FF.Z());}
                    }
                    Nb_P++;
                }
            }
            else Vec_Nb_Contrib_Loc.push_back(0);
            Ind_Sommet_Initialisation=P_Sommet->My_Index;
        }
        else Vec_Nb_Contrib_Loc.push_back(0);
    
    }while(1);

    //if(id_task==0)cout<<endl;
        
    /*{
        mutex::scoped_lock Lock_P(*P_Mutex_P);
        cout<<"nb calcul : "<<Nb_P<<" err : "<<Erreur_Max_FF<<endl;
    }*/

    {
        mutex::scoped_lock Lock_LO(*P_Mutex_LO);

        vector<size_t>::iterator itst;
        for(itst=Vec_Nb_Contrib_Loc.begin();itst!=Vec_Nb_Contrib_Loc.end();itst++)
            P_Vec_Nb_Contrib->push_back(size_t(*itst));
        for(itst=Vec_Ind_Point_Loc.begin();itst!=Vec_Ind_Point_Loc.end();itst++)
            P_Vec_Ind_Point->push_back(size_t(*itst));
        for(itst=Vec_INV_Loc.begin();itst!=Vec_INV_Loc.end();itst++)
            P_Vec_INV->push_back(size_t(*itst));
        vector<double>::iterator itd;
        for(itd=Vec_Phi_Loc.begin();itd!=Vec_Phi_Loc.end();itd++)
            P_Vec_Phi->push_back(double(*itd));
		if(Cal_Grad)
		{
			for(itd=Vec_Grad_Loc.begin();itd!=Vec_Grad_Loc.end();itd++)
				P_Vec_Grad->push_back(double(*itd));
		}

        Vec_Ind_Point_Loc.clear();
        Vec_Nb_Contrib_Loc.clear();
        Vec_INV_Loc.clear();
        Vec_Phi_Loc.clear();
		Vec_Grad_Loc.clear();
    }

    //--------------------------------------------------------------------------//

    free(Tab_Contrib_Voisin_Tampon);
    free(Tab_Voisin_O_N_Tampon);
    free(Tab_Sommet_Visite);
    free(Tab_Ind_Voisin);

    //--------------------------------------------------------------------------//

    return NULL;
}

//---------------------------------------------------------------------------//

void InterpolParal
(C_Meshless_3d* PML,size_t Nb_Point,double* Tab_Point,long Type_FF,long nb_thread,
 vector<size_t>* P_Ind_Point,vector<size_t>* P_Vec_Nb_Contrib,vector<size_t>* P_Vec_INV,vector<double>* P_Vec_Phi,vector<double>* P_Vec_Gard)
{
    PML->Nb_Cal_FF_Globale=0;
    PML->Nb_Cal_FF_Topo_DVC=0;

    //-----------------------------------------------------------------------//

    task_list List_Interpol_Task;
    long Ind_Point=0;
    mutex Mutex_IP;
    mutex Mutex_LO;
    mutex Mutex_P;
    
    //-----------------------------------------------------------------------//
        
    //cout<<"\nFF Type : "<<Type_FF<<"\n\n";
    //cout.flush();

    long i;
    for(i=0;i<nb_thread;i++)
    {
        Interpol_Task& task_i = * new(task::allocate_root())
            Interpol_Task(PML,Nb_Point,Tab_Point,Type_FF,
                            P_Ind_Point,P_Vec_Nb_Contrib,P_Vec_INV,P_Vec_Phi,P_Vec_Gard,
                            &Ind_Point,&Mutex_IP,&Mutex_LO,&Mutex_P,i);

        List_Interpol_Task.push_back(task_i);
    }
    
    //-----------------------------------------------------------------------//

    long T_0=clock();

    task::spawn_root_and_wait(List_Interpol_Task);

    long T_1=clock();

    //cout<<"\nnb_Cal_FF : Globale = "<<PML->Nb_Cal_FF_Globale<<" - Topo_DVC ="<<PML->Nb_Cal_FF_Topo_DVC<<endl;

    //-----------------------------------------------------------------------//
    
    return;
}
