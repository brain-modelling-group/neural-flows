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
// Gradiant stabilisee paralelle

#include "GradStabParal.h"

//---------------------------------------------------------------------------//

void Calcul_Erreur_Gradiant_Stabilise
(concurrent_hash_map<const long,C_Vec3d,HashCompareGSKey>** Tab_Gradiant_Stabilisee,double* Tab_Volume_Cellule,double* Tab_Noeud,long Nb_Noeud)
{
    //ofstream data("erreur_moy.txt");
    //data.precision(16);

    //cout<<"\nCalcul erreur gradiant stabilise-----------------------------------------------\n"<<endl;

    double Erreur_Max=0.;
    double Erreur_Moy=0.;

    double Vol_Cel[3];

    //-----------------------------------------------------------------------//

    //ofstream gs3874("gs3874.dat");
    //ofstream gs3686("gs3686.dat");

    long i;
    for(i=0;i<Nb_Noeud;i++)
    {
        C_Vec3d Grad_Champs_X(0.,0.,0.);
        C_Vec3d Grad_Champs_Y(0.,0.,0.);
        C_Vec3d Grad_Champs_Z(0.,0.,0.);
    
        concurrent_hash_map<const long,C_Vec3d,HashCompareGSKey>::iterator k;
        for(k=Tab_Gradiant_Stabilisee[i]->begin();k!=Tab_Gradiant_Stabilisee[i]->end();k++)
        {
            pair<const long,C_Vec3d> Paire_k=(*k);

            Grad_Champs_X+=Paire_k.second*Tab_Noeud[3*Paire_k.first];
            Grad_Champs_Y+=Paire_k.second*Tab_Noeud[3*Paire_k.first+1];
            Grad_Champs_Z+=Paire_k.second*Tab_Noeud[3*Paire_k.first+2];

            /*if(i==3874)
            {
                gs3874<<Paire_k.first<<' '<<Paire_k.second.X()<<' '<<Paire_k.second.Y()<<' '<<Paire_k.second.Z()<<endl;
            }

            if(i==3686)
            {
                gs3686<<Paire_k.first<<' '<<Paire_k.second.X()<<' '<<Paire_k.second.Y()<<' '<<Paire_k.second.Z()<<endl;
            }*/
        }

        double Erreur;

        //data<<i<<' ';

        Erreur=fabs(Grad_Champs_X.X()-1.);
        Erreur_Moy+=Erreur;
        if(Erreur>Erreur_Max)
            Erreur_Max=Erreur;
        
        //data<<Erreur<<' ';

        Erreur=fabs(Grad_Champs_X.Y());
        Erreur_Moy+=Erreur;
        if(Erreur>Erreur_Max)
            Erreur_Max=Erreur;
        
        //data<<Erreur<<' ';

        Erreur=fabs(Grad_Champs_X.Z());
        Erreur_Moy+=Erreur;
        if(Erreur>Erreur_Max)
            Erreur_Max=Erreur;

        //data<<Erreur<<' ';
        
        Erreur=fabs(Grad_Champs_Y.X());
        Erreur_Moy+=Erreur;
        if(Erreur>Erreur_Max)
            Erreur_Max=Erreur;

        //data<<Erreur<<' ';
        
        Erreur=fabs(Grad_Champs_Y.Y()-1.);
        Erreur_Moy+=Erreur;
        if(Erreur>Erreur_Max)
            Erreur_Max=Erreur;

        //data<<Erreur<<' ';
        
        Erreur=fabs(Grad_Champs_Y.Z());
        Erreur_Moy+=Erreur;
        if(Erreur>Erreur_Max)
            Erreur_Max=Erreur;

        //data<<Erreur<<' ';
        
        Erreur=fabs(Grad_Champs_Z.X());
        Erreur_Moy+=Erreur;
        if(Erreur>Erreur_Max)
            Erreur_Max=Erreur;

        //data<<Erreur<<' ';
        
        Erreur=fabs(Grad_Champs_Z.Y());
        Erreur_Moy+=Erreur;
        if(Erreur>Erreur_Max)
            Erreur_Max=Erreur;

        //data<<Erreur<<' ';
        
        Erreur=fabs(Grad_Champs_Z.Z()-1.);
        Erreur_Moy+=Erreur;
        if(Erreur>Erreur_Max)
            Erreur_Max=Erreur;

        //data<<Erreur<<endl;

        if(i)
        {
            if(Tab_Volume_Cellule[i]<Vol_Cel[0])Vol_Cel[0]=Tab_Volume_Cellule[i];
            else if(Tab_Volume_Cellule[i]>Vol_Cel[1])Vol_Cel[1]=Tab_Volume_Cellule[i];
            Vol_Cel[2]+=Tab_Volume_Cellule[i];
        }
        else
        {
            Vol_Cel[0]=Tab_Volume_Cellule[0];
            Vol_Cel[1]=Tab_Volume_Cellule[0];
            Vol_Cel[2]=Tab_Volume_Cellule[0];
        }
    }

    //gs3874.close();
    //gs3686.close();

    //data.close();

    Erreur_Moy/=(Nb_Noeud*9.);

    //cout<<"Erreur max gradiant satabilisee = "<<Erreur_Max<<"\nErreur moy gradiant satabilisee = "<<Erreur_Moy<<endl<<endl; 

    //cout<<"Volume cellule min-max-moy : "<<Vol_Cel[0]<<" - "<<Vol_Cel[1]<<" - "<<Vol_Cel[2]/Nb_Noeud<<endl;
    //cout<<"Somme volume cellule = "<<Vol_Cel[2]<<endl;
}

//---------------------------------------------------------------------------//

void Elimination_Nouveaux_Noeuds_DVC_de_GS
(concurrent_hash_map<const long,C_Vec3d,HashCompareGSKey>**& Tab_Gradiant_Stabilisee,double*& Tab_Volume_Cellule,
 long Nb_Noeud_Ini,long Nb_Noeud,vector<long>* P_Ind_Voisin,vector<double>* P_Phi_Voisin)
{
    //cout<<"\nElimination nouveaux noeuds du gradiant stabilisee-----------------------------"<<endl;

    concurrent_hash_map<const long,C_Vec3d,HashCompareGSKey>::accessor chm_acc;

    long i;
    for(i=0;i<Nb_Noeud_Ini;i++)
    {
        concurrent_hash_map<const long,C_Vec3d,HashCompareGSKey>* P_New_Gradiant_Stabilisee_i=new concurrent_hash_map<const long,C_Vec3d,HashCompareGSKey>;
        concurrent_hash_map<const long,C_Vec3d,HashCompareGSKey>::iterator j;
        for(j=Tab_Gradiant_Stabilisee[i]->begin();j!=Tab_Gradiant_Stabilisee[i]->end();j++)
        {
            pair<const long,C_Vec3d> Paire_j=(*j);

            if(Paire_j.first>=Nb_Noeud_Ini)
            {
                long k;
                for(k=0;k<3;k++)
                {
                    long Ind_Voisin_k=P_Ind_Voisin->at(3*(Paire_j.first-Nb_Noeud_Ini)+k);
                    double Phi_Voisin_k=P_Phi_Voisin->at(3*(Paire_j.first-Nb_Noeud_Ini)+k);
                    C_Vec3d Contribution=Paire_j.second*Phi_Voisin_k;
                    if(!P_New_Gradiant_Stabilisee_i->insert(chm_acc,make_pair(Ind_Voisin_k,Contribution)))
                        chm_acc->second+=Contribution;
                    chm_acc.release();
                }
            }
            else
            {
                if(!P_New_Gradiant_Stabilisee_i->insert(chm_acc,Paire_j))
                    chm_acc->second+=Paire_j.second;
                chm_acc.release();
            }
        }
        
        delete Tab_Gradiant_Stabilisee[i];
        Tab_Gradiant_Stabilisee[i]=P_New_Gradiant_Stabilisee_i;
    }

    /*
    for(i=Nb_Noeud_Ini;i<Nb_Noeud;i++)
    {
        double Volume_i=Tab_Volume_Cellule[i];
        
        long j;
        for(j=0;j<3;j++)
        {
            long Ind_Voisin_j=P_Ind_Voisin->at(3*(i-Nb_Noeud_Ini)+j);
            double Phi_Voisin_j=P_Phi_Voisin->at(3*(i-Nb_Noeud_Ini)+j);
            
            Tab_Volume_Cellule[Ind_Voisin_j]+=Phi_Voisin_j*Volume_i;
        }
    }
    */

    for(i=Nb_Noeud_Ini;i<Nb_Noeud;i++)
    {
        delete Tab_Gradiant_Stabilisee[i];
        Tab_Gradiant_Stabilisee[i]=NULL;
        Tab_Volume_Cellule[i]=0.;
    }

    Tab_Gradiant_Stabilisee=(concurrent_hash_map<const long,C_Vec3d,HashCompareGSKey>**)realloc
        (Tab_Gradiant_Stabilisee,sizeof(concurrent_hash_map<const long,C_Vec3d,HashCompareGSKey>*)*Nb_Noeud_Ini);
    Tab_Volume_Cellule=(double*)realloc(Tab_Volume_Cellule,sizeof(double)*Nb_Noeud_Ini);
}

//---------------------------------------------------------------------------//

class GradStabCal_B_Task: public task 
{
public:
    C_Meshless_3d* PML;
    concurrent_hash_map<const long,C_Vec3d,HashCompareGSKey>** Tab_Gradiant_Stabilisee;
    double* Tab_Volume_Cellule;
    long Type_FF;
    long Sup_NN_GS;
    vector<long>* Tab_Ind_Noeud_Tet;
    vector<long>* Tab_Ind_Cel_Elem_Tet;
    vector<long>* Tab_Ind_S_Elem_Tet;
    vector<long>* Tab_Id_in_S_Elem_Tet;
    vector<double>* Tab_Coord_Noeud_Elem;
    long* P_Ind_Sommet;
    long* P_Ind_Tet;
    mutex* P_Mutex_IS;
    mutex* P_Mutex_IT;
    mutex* P_Mutex_P;
    long Nb_S;
    long Nb_T;
    long id_task;

    GradStabCal_B_Task(C_Meshless_3d* PML_,
                       concurrent_hash_map<const long,C_Vec3d,HashCompareGSKey>** Tab_Gradiant_Stabilisee_,
                       double* Tab_Volume_Cellule_,
                       long Type_FF_,
                       long Sup_NN_GS_,
                       vector<long>* Tab_Ind_Noeud_Tet_,
                       vector<long>* Tab_Ind_Cel_Elem_Tet_,
                       vector<long>* Tab_Ind_S_Elem_Tet_,
                       vector<long>* Tab_Id_in_S_Elem_Tet_,
                       vector<double>* Tab_Coord_Noeud_Elem_,
                       long* P_Ind_Sommet_, 
                       long* P_Ind_Tet_, 
                       mutex* P_Mutex_IS_,
                       mutex* P_Mutex_IT_,
                       mutex* P_Mutex_P_,
                       long id_task_):
                       PML(PML_),
                       Tab_Gradiant_Stabilisee(Tab_Gradiant_Stabilisee_),
                       Tab_Volume_Cellule(Tab_Volume_Cellule_),
                       Type_FF(Type_FF_),
                       Sup_NN_GS(Sup_NN_GS_),
                       Tab_Ind_Noeud_Tet(Tab_Ind_Noeud_Tet_),
                       Tab_Ind_Cel_Elem_Tet(Tab_Ind_Cel_Elem_Tet_),
                       Tab_Ind_S_Elem_Tet(Tab_Ind_S_Elem_Tet_),
                       Tab_Id_in_S_Elem_Tet(Tab_Id_in_S_Elem_Tet_),
                       Tab_Coord_Noeud_Elem(Tab_Coord_Noeud_Elem_),
                       P_Ind_Sommet(P_Ind_Sommet_),
                       P_Ind_Tet(P_Ind_Tet_),
                       P_Mutex_IS(P_Mutex_IS_),
                       P_Mutex_IT(P_Mutex_IT_),
                       P_Mutex_P(P_Mutex_P_),
                       id_task(id_task_){}
    task* execute();
};

task* GradStabCal_B_Task::execute()
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
    
    double Erreur_Max_FF=0.;
    long Ind_Erreur=-1;
    long Type_Erreur=-1;
    long Ind_Sommet;
    Nb_S=0;
    
    concurrent_hash_map<const long,C_Vec3d,HashCompareGSKey>::accessor chm_acc;
    long Nb_C_Nb=-1;

    do
    {        
//---------------------------------------------------------------------------//
// Début section critique...
//---------------------------------------------------------------------------//
        {
            mutex::scoped_lock Lock_IS(*P_Mutex_IS);
            Ind_Sommet=*P_Ind_Sommet;
            (*P_Ind_Sommet)++;
        }
//---------------------------------------------------------------------------//
// Fin section critique...
//---------------------------------------------------------------------------//

        if(Ind_Sommet>=Nb_Sommet)
            break;
        
        if(id_task==0)
        {
            long I=100.*double(Ind_Sommet)/double(Nb_Sommet);
            //if(!(I%5))
            //{
            //    char Char[255];sprintf(Char,"%ld",I);string Nb(Char);//for(i=0;i<=Nb_C_Nb;i++)cout<<"\b";Nb_C_Nb=Nb.size();cout<<I<<'%';cout.flush();
            //}
        }

        C_Sommet* P_Sommet=PML->Diag_Vor.List_Sommet[Ind_Sommet];
        Nb_S++;

        if(!P_Sommet->Sommet_Infinie)
        {
            double P[11][3];
            C_Vec3d P10_P[10];
            
            long k;
            for(k=0;k<3;k++)
            {
                long l;
                for(l=0;l<3;l++)
                    P[k][l]=(PML->Diag_Vor.Tab_Noeud[3*P_Sommet->Ind_Noeud[k]+l]+PML->Diag_Vor.Tab_Noeud[3*P_Sommet->Ind_Noeud[(k+1)%3]+l])/2.;
            } 

            for(k=0;k<3;k++)
            {
                long l;
                for(l=0;l<3;l++)
                     P[3+k][l]=(PML->Diag_Vor.Tab_Noeud[3*P_Sommet->Ind_Noeud[3]+l]+PML->Diag_Vor.Tab_Noeud[3*P_Sommet->Ind_Noeud[k]+l])/2.;
            } 

            for(k=0;k<4;k++)
            {
                long l;
                for(l=0;l<3;l++)
                    P[6+k][l]=(PML->Diag_Vor.Tab_Noeud[3*P_Sommet->Ind_Noeud[k]+l]+PML->Diag_Vor.Tab_Noeud[3*P_Sommet->Ind_Noeud[(k+1)%4]+l]+PML->Diag_Vor.Tab_Noeud[3*P_Sommet->Ind_Noeud[(k+2)%4]+l])/3.;
            }  

            for(k=0;k<3;k++)
                P[10][k]=(PML->Diag_Vor.Tab_Noeud[3*P_Sommet->Ind_Noeud[0]+k]+PML->Diag_Vor.Tab_Noeud[3*P_Sommet->Ind_Noeud[1]+k]+PML->Diag_Vor.Tab_Noeud[3*P_Sommet->Ind_Noeud[2]+k]+PML->Diag_Vor.Tab_Noeud[3*P_Sommet->Ind_Noeud[3]+k])/4.;
            
            for(k=0;k<10;k++)
                P10_P[k]=C_Vec3d(P[10],P[k]);

            //---------------------------------------------------------------//

            concurrent_hash_map<const long,C_Vec3d,HashCompareGSKey>* P_Map_Contribution[4];
            for(k=0;k<4;k++)
                P_Map_Contribution[k]=Tab_Gradiant_Stabilisee[P_Sommet->Ind_Noeud[k]];

            //---------------------------------------------------------------//

            for(k=0;k<3;k++)
            {
                C_Vec3d Normale_par_Aire_12=(P10_P[6]^P10_P[k])/2.;
                C_Vec3d Normale_par_Aire_22=(P10_P[k]^P10_P[(k+2)%3+7])/2.;
                C_Vec3d Normale_par_Aire=Normale_par_Aire_12+Normale_par_Aire_22;

                double Aire_12=Normale_par_Aire_12.Magnitude();
                double Aire_22=Normale_par_Aire_22.Magnitude();
                double Aire=Aire_12+Aire_22;

                if(fabs(Aire)<PML->PRECISION_4)continue;

                long l;

                double Pnt_Int[3];
                for(l=0;l<3;l++)
                    Pnt_Int[l]=(Aire_12*(P[10][l]+P[6][l]+P[k][l])+Aire_22*(P[10][l]+P[k][l]+P[(k+2)%3+7][l]))/(3*Aire);
            
                vector<S_FoFo> List_SFoFo;
                double Erreur=PML->Fonction_de_Forme(Type_FF,Pnt_Int,P_Sommet,&List_SFoFo,
                                       Tab_Sommet_Visite,Tab_Voisin_O_N_Tampon,Tab_Contrib_Voisin_Tampon,
                                       Tab_Ind_Voisin,Size_Tab_Ind_Voisin);
                if(Erreur>Erreur_Max_FF){Erreur_Max_FF=Erreur;}//Ind_Erreur=Paire_j.first;Type_Erreur=0;}
                long Nb_FoFo=List_SFoFo.size();
            
                Tab_Volume_Cellule[P_Sommet->Ind_Noeud[k]]+=(C_Vec3d(&PML->Diag_Vor.Tab_Noeud[3*P_Sommet->Ind_Noeud[k]],P[10])*Normale_par_Aire)/3.;
                Tab_Volume_Cellule[P_Sommet->Ind_Noeud[(k+1)%3]]-=(C_Vec3d(&PML->Diag_Vor.Tab_Noeud[3*P_Sommet->Ind_Noeud[(k+1)%3]],P[10])*Normale_par_Aire)/3.;

                for(l=0;l<Nb_FoFo;l++)
                {
                    C_Vec3d Contribution=Normale_par_Aire*List_SFoFo[l].Valeur_FF;
                
                    if(!P_Map_Contribution[k]->insert(chm_acc,make_pair(List_SFoFo[l].Ind_Voisin,Contribution)))
                        chm_acc->second+=Contribution;
                    chm_acc.release();

                    Contribution*=-1.;
                    if(!P_Map_Contribution[(k+1)%3]->insert(chm_acc,make_pair(List_SFoFo[l].Ind_Voisin,Contribution)))
                        chm_acc->second+=Contribution;
                    chm_acc.release();
                }
            }

            for(k=0;k<3;k++)
            {
                C_Vec3d Normale_par_Aire_12=(P10_P[(k+1)%3+7]^P10_P[k+3])/2.;
                C_Vec3d Normale_par_Aire_22=(P10_P[k+3]^P10_P[(k+2)%3+7])/2.;
                C_Vec3d Normale_par_Aire=Normale_par_Aire_12+Normale_par_Aire_22;

                double Aire_12=Normale_par_Aire_12.Magnitude();
                double Aire_22=Normale_par_Aire_22.Magnitude();
                double Aire=Aire_12+Aire_22;

                if(fabs(Aire)<PML->PRECISION_4)continue;

                long l;
                
                double Pnt_Int[3];
                for(l=0;l<3;l++)
                    Pnt_Int[l]=(Aire_12*(P[10][l]+P[(k+1)%3+7][l]+P[k+3][l])+Aire_22*(P[10][l]+P[k+3][l]+P[(k+2)%3+7][l]))/(3*Aire);
            
                vector<S_FoFo> List_SFoFo;
                double Erreur=PML->Fonction_de_Forme(Type_FF,Pnt_Int,P_Sommet,&List_SFoFo,
                                       Tab_Sommet_Visite,Tab_Voisin_O_N_Tampon,Tab_Contrib_Voisin_Tampon,
                                       Tab_Ind_Voisin,Size_Tab_Ind_Voisin);
                if(Erreur>Erreur_Max_FF){Erreur_Max_FF=Erreur;}//Ind_Erreur=Paire_j.first;Type_Erreur=0;}
                long Nb_FoFo=List_SFoFo.size();
                
                Tab_Volume_Cellule[P_Sommet->Ind_Noeud[3]]+=(C_Vec3d(&PML->Diag_Vor.Tab_Noeud[3*P_Sommet->Ind_Noeud[3]],P[10])*Normale_par_Aire)/3.;
                Tab_Volume_Cellule[P_Sommet->Ind_Noeud[k]]-=(C_Vec3d(&PML->Diag_Vor.Tab_Noeud[3*P_Sommet->Ind_Noeud[k]],P[10])*Normale_par_Aire)/3.;
                
                for(l=0;l<Nb_FoFo;l++)
                {
                    C_Vec3d Contribution=Normale_par_Aire*List_SFoFo[l].Valeur_FF;
                        
                    if(!P_Map_Contribution[3]->insert(chm_acc,make_pair(List_SFoFo[l].Ind_Voisin,Contribution)))
                        chm_acc->second+=Contribution;
                    chm_acc.release();

                    Contribution*=-1.;
                    if(!P_Map_Contribution[k]->insert(chm_acc,make_pair(List_SFoFo[l].Ind_Voisin,Contribution)))
                        chm_acc->second+=Contribution;
                    chm_acc.release();
                }
            }

            long Tab_Ind[4][3][2]={{{0,2},{1,0},{2,1}},{{4,1},{1,5},{5,4}},{{5,2},{3,5},{2,3}},{{4,3},{3,0},{0,4}}};
            for(k=0;k<4;k++)
            {
                bool Face_Libre=PML->Diag_Vor.List_Sommet[P_Sommet->Ind_Sommet[k]]->Sommet_Infinie;

                if(Face_Libre)
                {
                    double Pnt_Int[3][3];
                    C_Vec3d Normale_par_Aire[3];

                    long l;
                    for(l=0;l<3;l++)
                    {
                        C_Vec3d NK_PCF(&PML->Diag_Vor.Tab_Noeud[3*P_Sommet->Ind_Noeud[(k+l)%4]],P[k+6]);
                        C_Vec3d Normale_par_Aire_12=(C_Vec3d(&PML->Diag_Vor.Tab_Noeud[3*P_Sommet->Ind_Noeud[(k+l)%4]],P[Tab_Ind[k][l][0]])^NK_PCF)/2.;
                        C_Vec3d Normale_par_Aire_22=(NK_PCF^C_Vec3d(&PML->Diag_Vor.Tab_Noeud[3*P_Sommet->Ind_Noeud[(k+l)%4]],P[Tab_Ind[k][l][1]]))/2.;
                        Normale_par_Aire[l]=Normale_par_Aire_12+Normale_par_Aire_22;
                        
                        double Aire_12=Normale_par_Aire_12.Magnitude();
                        double Aire_22=Normale_par_Aire_22.Magnitude();
                        double Aire=Aire_12+Aire_22;

                        long m;
                        for(m=0;m<3;m++)
                             Pnt_Int[l][m]=(Aire_12*(PML->Diag_Vor.Tab_Noeud[3*P_Sommet->Ind_Noeud[(k+l)%4]+m]+P[Tab_Ind[k][l][0]][m]+P[k+6][m])+Aire_22*(PML->Diag_Vor.Tab_Noeud[3*P_Sommet->Ind_Noeud[(k+l)%4]+m]+P[k+6][m]+P[Tab_Ind[k][l][1]][m]))/(3*Aire);
                    }

                    double FoFo[3][3];
                    PML->Fonction_de_Forme_FEM_LINAIRE_sur_Tri(P_Sommet,k,3,Pnt_Int,FoFo);
                    //if(Erreur>Erreur_Max_FF){Erreur_Max_FF=Erreur;Ind_Erreur=Paire_j.first;Type_Erreur=1;}
    
                    for(l=0;l<3;l++)
                    {
                        long m;
                        for(m=0;m<3;m++)
                        {
                            C_Vec3d Contribution=Normale_par_Aire[l]*FoFo[l][m];
                            
                            if(!P_Map_Contribution[(k+l)%4]->insert(chm_acc,make_pair(P_Sommet->Ind_Noeud[(k+m)%4],Contribution)))
                                chm_acc->second+=Contribution;
                            chm_acc.release(); 
                        }
                    }                
                }
            }
        }
    }while(1);

    if(id_task==0)cout<<endl;
        
    /*{
        mutex::scoped_lock Lock_P(*P_Mutex_P);
        cout<<"nb calcul : "<<Nb_S<<" err : "<<Erreur_Max_FF<<endl;
    }*/

    //--------------------------------------------------------------------------//

    if(Sup_NN_GS){

    Erreur_Max_FF=0.;
    Nb_C_Nb=-1;

    long Nb_Tet=Tab_Ind_Noeud_Tet->size()/4;
    long Ind_Tet;
    Nb_T=0;

    long gui_face_tet[24]={3,0,0,2,2,3,
                           1,0,3,1,0,3,
                           1,2,2,0,0,1,
                           3,2,1,3,2,1};

    long id_fte=2;

    do
    {        
//---------------------------------------------------------------------------//
// Début section critique...
//---------------------------------------------------------------------------//
        {
            mutex::scoped_lock Lock_IT(*P_Mutex_IT);
            Ind_Tet=*P_Ind_Tet;
            (*P_Ind_Tet)++;
        }
//---------------------------------------------------------------------------//
// Fin section critique...
//---------------------------------------------------------------------------//

        if(Ind_Tet>=Nb_Tet)
            break;

        if(id_task==0)
        {
            long I=100.*double(Ind_Tet)/double(Nb_Tet);
            //if(!(I%5))
            //{
            //    char Char[255];sprintf(Char,"%ld",I);string Nb(Char);//for(i=0;i<=Nb_C_Nb;i++)cout<<"\b";Nb_C_Nb=Nb.size();cout<<I<<'%';cout.flush();
            //}
        }

        Nb_T++;

        concurrent_hash_map<const long,C_Vec3d,HashCompareGSKey>* P_Map_Contribution_i=Tab_Gradiant_Stabilisee[Tab_Ind_Cel_Elem_Tet->at(Ind_Tet)];

        C_Sommet* P_Sommet_Pere=PML->Diag_Vor.List_Sommet[Tab_Ind_S_Elem_Tet->at(Ind_Tet)];

        long * Ind_Noeud_Tet_i=&(Tab_Ind_Noeud_Tet->at(4*Ind_Tet));
        double* Coord_Noeud_Tet_i[4]={&(Tab_Coord_Noeud_Elem->at(3*Ind_Noeud_Tet_i[0])),
                                      &(Tab_Coord_Noeud_Elem->at(3*Ind_Noeud_Tet_i[1])),
                                      &(Tab_Coord_Noeud_Elem->at(3*Ind_Noeud_Tet_i[2])),
                                      &(Tab_Coord_Noeud_Elem->at(3*Ind_Noeud_Tet_i[3]))};
        
        C_Vec3d N_F0=C_Vec3d(Coord_Noeud_Tet_i[0],Coord_Noeud_Tet_i[1])^
                     C_Vec3d(Coord_Noeud_Tet_i[0],Coord_Noeud_Tet_i[2]);
        double Aire_F0=N_F0.Magnitude()/2.;

        if(Aire_F0<PML->PRECISION_4)continue;

        double Volume_Tet=N_F0*C_Vec3d(Coord_Noeud_Tet_i[0],Coord_Noeud_Tet_i[3])/6.;
        
        double h_tet=Volume_Tet/Aire_F0;
        
        if(h_tet<PML->PRECISION_1)continue;

        long j;
        for(j=0;j<4;j++)
        {
            double Pnt_Int[3]={(Coord_Noeud_Tet_i[j][0]+Coord_Noeud_Tet_i[(j+1)%4][0]+Coord_Noeud_Tet_i[(j+2)%4][0])/3,
                               (Coord_Noeud_Tet_i[j][1]+Coord_Noeud_Tet_i[(j+1)%4][1]+Coord_Noeud_Tet_i[(j+2)%4][1])/3,
                               (Coord_Noeud_Tet_i[j][2]+Coord_Noeud_Tet_i[(j+1)%4][2]+Coord_Noeud_Tet_i[(j+2)%4][2])/3};
            
            C_Vec3d Normale_par_Aire=C_Vec3d(Coord_Noeud_Tet_i[j],Coord_Noeud_Tet_i[(j+1)%4])^
                                     C_Vec3d(Coord_Noeud_Tet_i[j],Coord_Noeud_Tet_i[(j+2)%4]);
            if(j%2)Normale_par_Aire/=2.;
            else Normale_par_Aire/=-2.;

            bool b=1;
            if(j==id_fte)
            {
                long Ind_Face_Tet_Pere=gui_face_tet[Tab_Id_in_S_Elem_Tet->at(Ind_Tet)];
                if(PML->Diag_Vor.List_Sommet[P_Sommet_Pere->Ind_Sommet[Ind_Face_Tet_Pere]]->Sommet_Infinie)
                {
                    double FoFo[3];                    
                    double Erreur=PML->Fonction_de_Forme_FEM_LINAIRE_sur_Tri(P_Sommet_Pere,Ind_Face_Tet_Pere,1,&Pnt_Int,&FoFo);
                    //if(Erreur>Erreur_Max_FF){Erreur_Max_FF=Erreur;}

                    long k;
                    for(k=0;k<3;k++)
                    {
                       C_Vec3d Contribution=Normale_par_Aire*FoFo[k];
                            
                       if(!P_Map_Contribution_i->insert(chm_acc,make_pair(P_Sommet_Pere->Ind_Noeud[(Ind_Face_Tet_Pere+k)%4],Contribution)))
                           chm_acc->second+=Contribution;
                       chm_acc.release();
                    }

                    b=0;
                }
            }

            if(b)
            {
                vector<S_FoFo> List_SFoFo;
                double Erreur=PML->Fonction_de_Forme(Type_FF,Pnt_Int,P_Sommet_Pere,&List_SFoFo,
                                                     Tab_Sommet_Visite,Tab_Voisin_O_N_Tampon,Tab_Contrib_Voisin_Tampon,
                                                     Tab_Ind_Voisin,Size_Tab_Ind_Voisin);
                if(Erreur>Erreur_Max_FF){Erreur_Max_FF=Erreur;}//Ind_Erreur=Paire_j.first;Type_Erreur=0;}
                long Nb_FoFo=List_SFoFo.size();
                         
                long k;
                for(k=0;k<Nb_FoFo;k++)
                {
                    C_Vec3d Contribution=Normale_par_Aire*List_SFoFo[k].Valeur_FF;
                        
                    if(!P_Map_Contribution_i->insert(chm_acc,make_pair(List_SFoFo[k].Ind_Voisin,Contribution)))
                        chm_acc->second+=Contribution;
                    chm_acc.release();
                }
            }
        }

        Tab_Volume_Cellule[Tab_Ind_Cel_Elem_Tet->at(Ind_Tet)]+=Volume_Tet;

    }while(1);

    if(id_task==0)cout<<endl;
        
    /*{
        mutex::scoped_lock Lock_P(*P_Mutex_P);
        cout<<"nb calcul : "<<Nb_T<<" err : "<<Erreur_Max_FF<<endl;
    }*/
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

void Integration_Stabilisee_Paral
(C_Meshless_3d* PML,
 concurrent_hash_map<const long,C_Vec3d,HashCompareGSKey>**& Tab_Gradiant_Stabilisee,double*& Tab_Volume_Cellule,
 long Type_Int,long Type_FF,long nb_thread,long Sup_NN_GS,
 vector<long>* P_Ind_Voisin,vector<double>* P_Phi_Voisin,
 vector<long>* Tab_Ind_Noeud_Tet,vector<long>* Tab_Ind_Cel_Elem_Tet,
 vector<long>* Tab_Ind_S_Elem_Tet,vector<long>* Tab_Id_in_S_Elem_Tet,
 vector<double>* Tab_Coord_Noeud_Elem)
{
    PML->Nb_Cal_FF_Globale=0;
    PML->Nb_Cal_FF_Topo_DVC=0;

    //-----------------------------------------------------------------------//

    long Nb_Noeud=PML->Diag_Vor.Nb_Noeud;

    Tab_Gradiant_Stabilisee=(concurrent_hash_map<const long,C_Vec3d,HashCompareGSKey>**)malloc(Nb_Noeud*sizeof(concurrent_hash_map<const long,C_Vec3d,HashCompareGSKey>*));
    Tab_Volume_Cellule=(double*)malloc(Nb_Noeud*nb_thread*sizeof(double));

    long i;
    for(i=0;i<Nb_Noeud;i++)
        Tab_Gradiant_Stabilisee[i]=new concurrent_hash_map<const long,C_Vec3d,HashCompareGSKey>; 
    for(i=0;i<Nb_Noeud*nb_thread;i++)
        Tab_Volume_Cellule[i]=0.;

    //-----------------------------------------------------------------------//

    task_list List_GradStabCal_Task;
    long Ind_Sommet=0;
    long Ind_Tet=0;
    mutex Mutex_IS;
    mutex Mutex_IT;
    mutex Mutex_P;
    
    //-----------------------------------------------------------------------//
        
    switch(Type_Int)
    {
    case 0:
        {
            //cout<<"\nIntegration stabilisee Type B, FF Type "<<Type_FF<<"\n\n";
            //cout.flush();
            
            for(i=0;i<nb_thread;i++)
            {
                GradStabCal_B_Task& task_i = * new(task::allocate_root())
                    GradStabCal_B_Task(PML,Tab_Gradiant_Stabilisee,&Tab_Volume_Cellule[Nb_Noeud*i],Type_FF,Sup_NN_GS,
                    Tab_Ind_Noeud_Tet,Tab_Ind_Cel_Elem_Tet,Tab_Ind_S_Elem_Tet,Tab_Id_in_S_Elem_Tet,Tab_Coord_Noeud_Elem,
                    &Ind_Sommet,&Ind_Tet,&Mutex_IS,&Mutex_IT,&Mutex_P,i);

                List_GradStabCal_Task.push_back(task_i);
            }
                        
            break;
        }
    default :
        break;
    }
    
    //-----------------------------------------------------------------------//

    long T_0=clock();

    task::spawn_root_and_wait(List_GradStabCal_Task);

    long T_1=clock();

    //cout<<"\nnb_Cal_FF : Globale = "<<PML->Nb_Cal_FF_Globale<<" - Topo_DVC ="<<PML->Nb_Cal_FF_Topo_DVC<<endl;

    //-----------------------------------------------------------------------//

    for(i=0;i<Nb_Noeud;i++)
    {
        long j;
        for(j=1;j<nb_thread;j++)
            Tab_Volume_Cellule[i]+=Tab_Volume_Cellule[Nb_Noeud*j+i];
    }

    Tab_Volume_Cellule=(double*)realloc(Tab_Volume_Cellule,Nb_Noeud*sizeof(double));

    //-----------------------------------------------------------------------//
    
    if(Sup_NN_GS)
    {
        Elimination_Nouveaux_Noeuds_DVC_de_GS(Tab_Gradiant_Stabilisee,Tab_Volume_Cellule,
                                              PML->Nb_Noeud_Ini,PML->Diag_Vor.Nb_Noeud,P_Ind_Voisin,P_Phi_Voisin);
    }

    //-----------------------------------------------------------------------//
    
    long Size_Tab_GS=Sup_NN_GS?PML->Nb_Noeud_Ini:PML->Diag_Vor.Nb_Noeud;

    for(i=0;i<Size_Tab_GS;i++)
    {
        concurrent_hash_map<const long,C_Vec3d,HashCompareGSKey>::iterator j;
        for(j=Tab_Gradiant_Stabilisee[i]->begin();j!=Tab_Gradiant_Stabilisee[i]->end();j++)
        {
            pair<const long,C_Vec3d>& Ref_Paire_j=*j;
            Ref_Paire_j.second/=Tab_Volume_Cellule[i];
        }
    }

    //-----------------------------------------------------------------------//

    Calcul_Erreur_Gradiant_Stabilise(Tab_Gradiant_Stabilisee,Tab_Volume_Cellule,PML->Diag_Vor.Tab_Noeud,Size_Tab_GS);

    double Temp_de_Calcul=(T_1-T_0)/double(CLOCKS_PER_SEC);
    //cout<<"\nTemp de calcul = "<<Temp_de_Calcul<<" s."<<endl;

    //-----------------------------------------------------------------------//
    
    return;
}
