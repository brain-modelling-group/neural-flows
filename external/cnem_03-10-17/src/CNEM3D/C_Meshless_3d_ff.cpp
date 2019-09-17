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
// Fonction de forme

#include "C_Meshless_3d.h"

//---------------------------------------------------------------------------//

C_Sommet* C_Meshless_3d::Descente_Gradiant(long Ind_Sommet_Initialisation,double* Noeud_a_Inserer,long* P_Ind_Face,long* P_Ind_Noeud)
{
    C_Sommet* P_Sommet_Recherche=NULL;
    long Ind_Face=-1;
    long Ind_Noeud=-1;

    C_Sommet* P_Sommet_Temp;
    
    if(Ind_Sommet_Initialisation+1)
        P_Sommet_Temp=Diag_Vor.List_Sommet[Ind_Sommet_Initialisation];
    else
        P_Sommet_Temp=Diag_Vor.Trouve_Sommet_non_Infini();
    
    do
    {
        long Index_Max=-1;
            
        double Signe=1.;
        double PrS_Max=0.;
        double PrS[4];

        bool Point_Sur_Plan[4]={0,0,0,0};

        double Dist_N_Tetra_N_a_Inserer[4]={0.,0.,0.,0.};

        long i;
        for(i=0;i<4;i++)
        {
            C_Vec3d N_Tetra_N_a_Inserer=C_Vec3d(&Diag_Vor.Tab_Noeud[P_Sommet_Temp->Ind_Noeud[i]*3],Noeud_a_Inserer);

            Dist_N_Tetra_N_a_Inserer[i]=N_Tetra_N_a_Inserer.Magnitude();

            C_Vec3d Normale_Face=(C_Vec3d(&Diag_Vor.Tab_Noeud[P_Sommet_Temp->Ind_Noeud[i]*3],&Diag_Vor.Tab_Noeud[P_Sommet_Temp->Ind_Noeud[(i+1)%4]*3])^
                                  C_Vec3d(&Diag_Vor.Tab_Noeud[P_Sommet_Temp->Ind_Noeud[i]*3],&Diag_Vor.Tab_Noeud[P_Sommet_Temp->Ind_Noeud[(i+2)%4]*3])).Normalized();

            /*if(i==0)
            {
                double Vol_Tet=C_Vec3d(&Diag_Vor.Tab_Noeud[P_Sommet_Temp->Ind_Noeud[3]*3],&Diag_Vor.Tab_Noeud[P_Sommet_Temp->Ind_Noeud[0]*3])*Normale_Face;
                if(Vol_Tet<=0.)return P_Sommet_Recherche;
            }*/

            PrS[i]=Signe*(N_Tetra_N_a_Inserer*Normale_Face);

            if(PrS[i]>PRECISION_1) 
            {
                double PrS_Normee=PrS[i]/Dist_N_Tetra_N_a_Inserer[i];

                if(PrS_Normee>PrS_Max)
                {
                    PrS_Max=PrS_Normee;
                     Index_Max=i;
                }
            }
            else
            {
                if(PrS[i]>-(PRECISION_1))
                    Point_Sur_Plan[i]=1;
            }
            
            Signe*=-1.;
        }

        if(Index_Max+1)
        {
            P_Sommet_Temp=Diag_Vor.List_Sommet[P_Sommet_Temp->Ind_Sommet[Index_Max]];
            if(P_Sommet_Temp->Sommet_Infinie)
            {
                if(P_Sommet_Temp->Ind_Sommet_Out==-1)break;
                else P_Sommet_Temp=Diag_Vor.List_Sommet[P_Sommet_Temp->Ind_Sommet_Out];
            }
        }
        else
        {
            P_Sommet_Recherche=P_Sommet_Temp;

            for(i=0;i<4;i++)
            {
                if((Diag_Vor.List_Sommet[P_Sommet_Temp->Ind_Sommet[i]]->Sommet_Infinie)&&Point_Sur_Plan[i])
                {
                    Ind_Face=i;
                    break;
                }
            }
            
            for(i=0;i<4;i++)
            {
                if(Dist_N_Tetra_N_a_Inserer[i]<PRECISION_0)
                {
                    Ind_Noeud=i;
                    break;
                }
            }

            break;
        }
    }while(1);

    if(P_Ind_Face!=NULL)*P_Ind_Face=Ind_Face;
    if(P_Ind_Noeud!=NULL)*P_Ind_Noeud=Ind_Noeud;

    return P_Sommet_Recherche;
}

//---------------------------------------------------------------------------//

C_Sommet* C_Meshless_3d::Recherche_Tache_d_Huile
(long Ind_Sommet_Initialisation,double* Noeud_a_Inserer,long& Ind_Face,
 bool* Tab_Sommet_Visite)
{
    vector<C_Sommet*> Front_n;
    vector<C_Sommet*> Front_n_p_1;

    vector<C_Sommet*>* P_Front_n=&Front_n;
    vector<C_Sommet*>* P_Front_n_p_1=&Front_n_p_1;
    vector<C_Sommet*>* P_Front_Temp;
    
    vector<long> List_Ind_Sommet_Visite;

    Front_n.push_back(Diag_Vor.List_Sommet[Ind_Sommet_Initialisation]);
    List_Ind_Sommet_Visite.push_back(Ind_Sommet_Initialisation);
    Tab_Sommet_Visite[Ind_Sommet_Initialisation]=1;

    Ind_Face=-1;
    C_Sommet* P_Sommet_Recherche=NULL;
    
    do
    {
    
        bool Tetra_Trouve=0;

        vector<C_Sommet*>::iterator i;
        for(i=P_Front_n->begin();i!=P_Front_n->end();i++)
        {
            C_Sommet* P_Sommet_i=(*i);

            Tetra_Trouve=1;

            bool Point_Sur_Plan[4]={0,0,0,0};

            double Signe=1.;
            long j;
            for(j=0;j<4;j++)
            {
                C_Vec3d N_Tetra_N_a_Inserer=C_Vec3d(&Diag_Vor.Tab_Noeud[P_Sommet_i->Ind_Noeud[j]*3],Noeud_a_Inserer);

                C_Vec3d Normale_Face=(C_Vec3d(&Diag_Vor.Tab_Noeud[P_Sommet_i->Ind_Noeud[j]*3],&Diag_Vor.Tab_Noeud[P_Sommet_i->Ind_Noeud[(j+1)%4]*3])^
                                      C_Vec3d(&Diag_Vor.Tab_Noeud[P_Sommet_i->Ind_Noeud[j]*3],&Diag_Vor.Tab_Noeud[P_Sommet_i->Ind_Noeud[(j+2)%4]*3])).Normalized();
            
                double PrS=Signe*(N_Tetra_N_a_Inserer*Normale_Face);

                if(PrS>(PRECISION_1*1.e+3))
                {
                    Tetra_Trouve=0;
                    break;
                }
                else
                {
                    if(PrS>-(PRECISION_1*1.e+3))
                        Point_Sur_Plan[j]=1;
                }
            
                Signe*=-1.;
            }

            if(Tetra_Trouve)
            {
                P_Sommet_Recherche=P_Sommet_i;
                
                for(j=0;j<4;j++)
                {
                    if((Diag_Vor.List_Sommet[P_Sommet_i->Ind_Sommet[j]]->Sommet_Infinie)&&(Point_Sur_Plan[j]))
                    {
                        Ind_Face=j;
                        break;
                    }
                }

                break;
            }

            for(j=0;j<4;j++)
            {
                C_Sommet* P_Sommet_j=Diag_Vor.List_Sommet[P_Sommet_i->Ind_Sommet[j]];
                bool b=1;
                if(P_Sommet_j->Sommet_Infinie)
                {
                    if(P_Sommet_j->Ind_Sommet_Out==-1)b=0;
                    else P_Sommet_j=Diag_Vor.List_Sommet[P_Sommet_j->Ind_Sommet_Out];
                }
                
                if(b)
                {
                    if(!Tab_Sommet_Visite[P_Sommet_j->My_Index])
                    {
                        Tab_Sommet_Visite[P_Sommet_j->My_Index]=1;
                        List_Ind_Sommet_Visite.push_back(P_Sommet_j->My_Index);
                        P_Front_n_p_1->push_back(P_Sommet_j);
                    }
                }
            }
        }

        if(Tetra_Trouve)
            break;

        P_Front_n->clear();
        P_Front_Temp=P_Front_n;
        P_Front_n=P_Front_n_p_1;
        P_Front_n_p_1=P_Front_Temp;
    }while(!P_Front_n->empty());

    vector<long>::iterator i;
    for(i=List_Ind_Sommet_Visite.begin();i!=List_Ind_Sommet_Visite.end();i++)
    {
        long Ind_Sommet_Visite=(*i);
        Tab_Sommet_Visite[Ind_Sommet_Visite]=0;
    }

    return P_Sommet_Recherche;
}

//---------------------------------------------------------------------------//

bool C_Meshless_3d::Calcul_Cellule_Noeud_a_Inserer
(long Ind_Noeud_a_Inserer,
 double* Noeud_a_Inserer,
 C_Sommet* P_Pr_Sommet_a_Suprimer,
 vector<C_Sommet_1*>* P_List_P_Sommet_Nouvelle_Cellule,
 vector<C_Sommet*>* P_List_P_Sommet_Cavite,
 bool* Tab_Sommet_Visite) 
{
    //-----------------------------------------------------------------------//

    vector<C_Sommet_Cavite> List_Sommet_Cavite_Temp;
    vector<C_Sommet_Cavite> List_Sommet_Cavite;
    vector<C_Sommet*> List_P_Sommet_a_Suprimer;
        
    //-----------------------------------------------------------------------//
    
    List_P_Sommet_a_Suprimer.push_back(P_Pr_Sommet_a_Suprimer);    
    //P_Pr_Sommet_a_Suprimer->Valide=0;
    Tab_Sommet_Visite[P_Pr_Sommet_a_Suprimer->My_Index]=1;
    
    //-----------------------------------------------------------------------//
    
    bool Direct;
    long i;
    for(i=0;i<4;i++)
    {
        C_Sommet_Cavite S_C_Temp;
        S_C_Temp.P_Sommet=Diag_Vor.List_Sommet[P_Pr_Sommet_a_Suprimer->Ind_Sommet[i]];
        Direct=1;
        long j;
        for(j=0;j<4;j++)
        {
            if(S_C_Temp.P_Sommet->Ind_Sommet[j]==P_Pr_Sommet_a_Suprimer->My_Index)
            {
                S_C_Temp.Ind_Face=j;
                S_C_Temp.Face_Direct=Direct;
                break;
            }
            Direct=!Direct;
        }
        List_Sommet_Cavite_Temp.push_back(S_C_Temp);
    }
    
    //-----------------------------------------------------------------------//

    while(!List_Sommet_Cavite_Temp.empty())
    {
        C_Sommet_Cavite S_C_Temp_1=List_Sommet_Cavite_Temp.back();
        List_Sommet_Cavite_Temp.pop_back();

        //if(S_C_Temp_1.P_Sommet->Valide)
        if(!Tab_Sommet_Visite[S_C_Temp_1.P_Sommet->My_Index])
        {
            if(S_C_Temp_1.P_Sommet->Sommet_Infinie)
                List_Sommet_Cavite.push_back(S_C_Temp_1);
            else
            {
                bool Sommet_a_Suprimer=0;

                double Distance_au_Centre=C_Vec3d(S_C_Temp_1.P_Sommet->Sommet,Noeud_a_Inserer).Magnitude();
                if((Distance_au_Centre-S_C_Temp_1.P_Sommet->Rayon_Sphere)<PRECISION_0)
                    Sommet_a_Suprimer=1;
                else
                {                
                    C_Vec3d Normale_Face_Cavite=(C_Vec3d(&Diag_Vor.Tab_Noeud[S_C_Temp_1.P_Sommet->Ind_Noeud[S_C_Temp_1.Ind_Face]*3],&Diag_Vor.Tab_Noeud[S_C_Temp_1.P_Sommet->Ind_Noeud[(S_C_Temp_1.Ind_Face+1)%4]*3])^
                                                 C_Vec3d(&Diag_Vor.Tab_Noeud[S_C_Temp_1.P_Sommet->Ind_Noeud[S_C_Temp_1.Ind_Face]*3],&Diag_Vor.Tab_Noeud[S_C_Temp_1.P_Sommet->Ind_Noeud[(S_C_Temp_1.Ind_Face+2)%4]*3])).Normalized();
                    if(S_C_Temp_1.Ind_Face%2)
                        Normale_Face_Cavite*=-1.;
                    
                    C_Vec3d NaI_NFC=C_Vec3d(Noeud_a_Inserer,&Diag_Vor.Tab_Noeud[S_C_Temp_1.P_Sommet->Ind_Noeud[S_C_Temp_1.Ind_Face]*3]).Normalized();
                    
                    double PrS=Normale_Face_Cavite*NaI_NFC;
                    
                    if(PrS>-PRECISION_5)  
                        Sommet_a_Suprimer=1;
                }
                
                if(Sommet_a_Suprimer)
                {
                    //S_C_Temp_1.P_Sommet->Valide=0;
                    Tab_Sommet_Visite[S_C_Temp_1.P_Sommet->My_Index]=1;
                    List_P_Sommet_a_Suprimer.push_back(S_C_Temp_1.P_Sommet);
                    
                    for(i=0;i<4;i++)
                    {
                        if(i!=S_C_Temp_1.Ind_Face)
                        {
                            C_Sommet* P_Sommet_Temp=Diag_Vor.List_Sommet[S_C_Temp_1.P_Sommet->Ind_Sommet[i]];
                            C_Sommet_Cavite S_C_Temp2;
                            S_C_Temp2.P_Sommet=P_Sommet_Temp;
                            Direct=1;
                            long j;
                            for(j=0;j<4;j++)
                            {
                                if(P_Sommet_Temp->Ind_Sommet[j]==S_C_Temp_1.P_Sommet->My_Index)
                                {
                                    S_C_Temp2.Ind_Face=j;
                                    S_C_Temp2.Face_Direct=Direct;
                                    break;
                                }
                                Direct=!Direct;
                            }
                            List_Sommet_Cavite_Temp.push_back(S_C_Temp2);
                        }
                    }
                }
                else
                    List_Sommet_Cavite.push_back(S_C_Temp_1);
            }
        }
    }
 
    //-----------------------------------------------------------------------//

    if(Ind_Noeud_a_Inserer+1)
    {
        vector<C_Sommet*> List_P_Nouveau_Sommet;

        while(!List_Sommet_Cavite.empty())
        {
            C_Sommet_Cavite S_C_Temp=List_Sommet_Cavite.back();
             List_Sommet_Cavite.pop_back();

            //if(S_C_Temp.P_Sommet->Valide)
            if(!Tab_Sommet_Visite[S_C_Temp.P_Sommet->My_Index])
            {
                C_Sommet* P_Nouveau_Sommet = new C_Sommet;
                List_P_Nouveau_Sommet.push_back(P_Nouveau_Sommet);
        
                TGM.circumsphere(Noeud_a_Inserer,
                                         &Diag_Vor.Tab_Noeud[S_C_Temp.P_Sommet->Ind_Noeud[(S_C_Temp.Ind_Face+1)%4]*3],
                                         &Diag_Vor.Tab_Noeud[S_C_Temp.P_Sommet->Ind_Noeud[S_C_Temp.Ind_Face]*3],
                                         &Diag_Vor.Tab_Noeud[S_C_Temp.P_Sommet->Ind_Noeud[(S_C_Temp.Ind_Face+2)%4]*3],
                                         P_Nouveau_Sommet->Sommet,&P_Nouveau_Sommet->Rayon_Sphere);

                P_Nouveau_Sommet->Ind_Noeud[0]=S_C_Temp.P_Sommet->Ind_Noeud[S_C_Temp.Ind_Face];
          
                if(S_C_Temp.Face_Direct)
                {
                     P_Nouveau_Sommet->Ind_Noeud[1]=S_C_Temp.P_Sommet->Ind_Noeud[(S_C_Temp.Ind_Face+2)%4];
                    P_Nouveau_Sommet->Ind_Noeud[2]=S_C_Temp.P_Sommet->Ind_Noeud[(S_C_Temp.Ind_Face+1)%4];
                }
                else
                {
                     P_Nouveau_Sommet->Ind_Noeud[1]=S_C_Temp.P_Sommet->Ind_Noeud[(S_C_Temp.Ind_Face+1)%4];
                    P_Nouveau_Sommet->Ind_Noeud[2]=S_C_Temp.P_Sommet->Ind_Noeud[(S_C_Temp.Ind_Face+2)%4];
                } 
        
                P_Nouveau_Sommet->Ind_Noeud[3]=Ind_Noeud_a_Inserer;

                P_Nouveau_Sommet->Ind_Sommet[0]=S_C_Temp.P_Sommet->My_Index;
                P_Nouveau_Sommet->Ind_Sommet[1]=-1;
                P_Nouveau_Sommet->Ind_Sommet[2]=-1;
                P_Nouveau_Sommet->Ind_Sommet[3]=-1;

                Diag_Vor.Ajout_Sommet(P_Nouveau_Sommet);
                S_C_Temp.P_Sommet->Ind_Sommet[S_C_Temp.Ind_Face]=P_Nouveau_Sommet->My_Index;

            }
        }
            
        //-------------------------------------------------------------------//

        while(!List_P_Nouveau_Sommet.empty())
        {
            C_Sommet* P_Sommet_1=List_P_Nouveau_Sommet.back();
            List_P_Nouveau_Sommet.pop_back();

            bool b[3];

            for(i=0;i<3;i++)
                b[i]=(P_Sommet_1->Ind_Sommet[(i+2)%3+1]==-1);
        
            if(b[0]||b[1]||b[2])
            {
                long Size=List_P_Nouveau_Sommet.size();
                for(i=0;i<Size;i++)
                {
                    C_Sommet* P_Sommet_2=List_P_Nouveau_Sommet[i];
            
                    long j;
                    for(j=0;j<3;j++)
                    {
                        if(b[j])
                        {
                            long k;
                            for(k=0;k<3;k++)
                            {
                                if(P_Sommet_1->Ind_Noeud[j]==P_Sommet_2->Ind_Noeud[(k+1)%3] &&
                                    P_Sommet_1->Ind_Noeud[(j+1)%3]==P_Sommet_2->Ind_Noeud[k])
                                {
                                    P_Sommet_1->Ind_Sommet[(j+2)%3+1]=P_Sommet_2->My_Index;
                                    P_Sommet_2->Ind_Sommet[(k+2)%3+1]=P_Sommet_1->My_Index;
                                    
                                    b[j]=0;
                                
                                     j=2;
                                    break;
                                }
                            }
                        }
                    }

                    if(!b[0]&&!b[1]&&!b[2])
                        break;
                }
            }
        }

        //-------------------------------------------------------------------//

        while(!List_P_Sommet_a_Suprimer.empty())
        {
            C_Sommet* P_Sommet_Temp=List_P_Sommet_a_Suprimer.back();
            List_P_Sommet_a_Suprimer.pop_back();
            Diag_Vor.Retire_Sommet(P_Sommet_Temp->My_Index);
        }

        //-------------------------------------------------------------------//
    }
    else
    {
        if(P_List_P_Sommet_Nouvelle_Cellule!=NULL)
        {
            vector<C_Sommet_1*> List_P_Nouveau_Sommet;

            while(!List_Sommet_Cavite.empty())
            {
                C_Sommet_Cavite S_C_Temp=List_Sommet_Cavite.back();
                 List_Sommet_Cavite.pop_back();
                
                //if(S_C_Temp.P_Sommet->Valide)
                if(!Tab_Sommet_Visite[S_C_Temp.P_Sommet->My_Index])
                {
                    C_Sommet_1* P_Nouveau_Sommet = new C_Sommet_1;
                    List_P_Nouveau_Sommet.push_back(P_Nouveau_Sommet);

                    TGM.circumsphere(Noeud_a_Inserer,
                                            &Diag_Vor.Tab_Noeud[S_C_Temp.P_Sommet->Ind_Noeud[(S_C_Temp.Ind_Face+1)%4]*3],
                                            &Diag_Vor.Tab_Noeud[S_C_Temp.P_Sommet->Ind_Noeud[S_C_Temp.Ind_Face]*3],
                                            &Diag_Vor.Tab_Noeud[S_C_Temp.P_Sommet->Ind_Noeud[(S_C_Temp.Ind_Face+2)%4]*3],
                                            P_Nouveau_Sommet->Sommet,&P_Nouveau_Sommet->Rayon_Sphere);

                    P_Nouveau_Sommet->Ind_Noeud[0]=S_C_Temp.P_Sommet->Ind_Noeud[S_C_Temp.Ind_Face];
             
                    if(S_C_Temp.Face_Direct)
                    {
                        P_Nouveau_Sommet->Ind_Noeud[1]=S_C_Temp.P_Sommet->Ind_Noeud[(S_C_Temp.Ind_Face+2)%4];
                        P_Nouveau_Sommet->Ind_Noeud[2]=S_C_Temp.P_Sommet->Ind_Noeud[(S_C_Temp.Ind_Face+1)%4];
                    }
                    else
                    {
                        P_Nouveau_Sommet->Ind_Noeud[1]=S_C_Temp.P_Sommet->Ind_Noeud[(S_C_Temp.Ind_Face+1)%4];
                        P_Nouveau_Sommet->Ind_Noeud[2]=S_C_Temp.P_Sommet->Ind_Noeud[(S_C_Temp.Ind_Face+2)%4];
                    } 
            
                    P_Nouveau_Sommet->Ind_Sommet_Externe=S_C_Temp.P_Sommet->My_Index;
                
                    P_Nouveau_Sommet->P_Sommet[0]=NULL;
                    P_Nouveau_Sommet->P_Sommet[1]=NULL;
                    P_Nouveau_Sommet->P_Sommet[2]=NULL;

                    P_List_P_Sommet_Nouvelle_Cellule->push_back(P_Nouveau_Sommet);
                }
            }
        
            //-------------------------------------------------------------------//
            
            while(!List_P_Nouveau_Sommet.empty())
            {
                C_Sommet_1* P_Sommet_A=List_P_Nouveau_Sommet.back();
                List_P_Nouveau_Sommet.pop_back();

                bool b[3];

                for(i=0;i<3;i++)
                    b[i]=(P_Sommet_A->P_Sommet[i]==NULL);
            
                if(b[0]||b[1]||b[2])
                {
                    long Size=List_P_Nouveau_Sommet.size();
                    for(i=0;i<Size;i++)
                    {
                        C_Sommet_1* P_Sommet_B=List_P_Nouveau_Sommet[i];
                
                        long j;
                        for(j=0;j<3;j++)
                        {
                            if(b[j])
                            {
                                long k;
                                for(k=0;k<3;k++)
                                {
                                    if(P_Sommet_A->Ind_Noeud[j]==P_Sommet_B->Ind_Noeud[(k+1)%3] &&
                                     P_Sommet_A->Ind_Noeud[(j+1)%3]==P_Sommet_B->Ind_Noeud[k])
                                    {
                                        P_Sommet_A->P_Sommet[j]=P_Sommet_B;
                                        P_Sommet_B->P_Sommet[k]=P_Sommet_A;
                                        
                                        b[j]=0;
                                    
                                         j=2;
                                        break;
                                    }
                                }
                            }
                        }

                        if(!b[0]&&!b[1]&&!b[2])
                            break;
                    }
                }
            }
        }
        
        //-------------------------------------------------------------------//

        if(P_List_P_Sommet_Cavite!=NULL)
        {
            P_List_P_Sommet_Cavite->resize(List_P_Sommet_a_Suprimer.size());
            copy(List_P_Sommet_a_Suprimer.begin(),List_P_Sommet_a_Suprimer.end(),P_List_P_Sommet_Cavite->begin());
        }
        
        //-------------------------------------------------------------------//

        while(!List_P_Sommet_a_Suprimer.empty())
        {
            C_Sommet* P_Sommet_Temp=List_P_Sommet_a_Suprimer.back();
            List_P_Sommet_a_Suprimer.pop_back();
            //P_Sommet_Temp->Valide=1;
            Tab_Sommet_Visite[P_Sommet_Temp->My_Index]=0;
        }

        //-------------------------------------------------------------------//
    }

    return 1;
}

//---------------------------------------------------------------------------//

double C_Meshless_3d::Fonction_de_Forme_NEM_SIBSON_Topo_TDC
(double* X,vector<C_Sommet*>* P_List_P_Sommet_Cavite,vector<S_FoFo>* P_List_SFoFo,
 bool* Tab_Sommet_Visite,bool* Tab_Voisin_O_N_Tampon,double* Tab_Contrib_Voisin_Tampon,
 long*& Tab_Ind_Voisin,long& Size_Tab_Ind_Voisin)
{
    /*long Init=0;//time(NULL);
    srand(Init);
    ofstream Sortie_TP("data.dat");
    Sortie_TP.precision(16);
    Sortie_TP<<"VARIABLES = X Y Z W\n";
    double Couleur;*/

    multimap<long,S_2Long> MMap_S_Ind_Arete_Cavite;
    typedef multimap<long,S_2Long>::iterator mmit;

    long Ind_Ind_NAT[6][2]= {{0,1},{1,2},{2,0},{3,0},{3,1},{3,2}};
    long Ind_Face_d_g[6][2]={{3,0},{1,0},{2,0},{3,2},{1,3},{2,1}};
    long i;
    long Nb_S_Cavite=P_List_P_Sommet_Cavite->size();
        
    for(i=0;i<Nb_S_Cavite;i++)
    {
        //P_List_P_Sommet_Cavite->at(i)->Type=10;
        Tab_Sommet_Visite[P_List_P_Sommet_Cavite->at(i)->My_Index]=1;
        //Couleur=rand()/(double)RAND_MAX;
        //Sortie_Tecplot_Tetraedre(List_P_Sommet_Cavite[i],Couleur,"Cavite",Sortie_TP);
    }
    
    //map<long,double> Map_Ind_Voisin_Vol_Contrib;

    long I=0;

    for(i=0;i<Nb_S_Cavite;i++)
    {
        C_Sommet* P_Sommet_C_i=P_List_P_Sommet_Cavite->at(i);
        long j;
        for(j=0;j<6;j++)
        {
            long Ind_NAT_j[2]={P_Sommet_C_i->Ind_Noeud[Ind_Ind_NAT[j][0]],P_Sommet_C_i->Ind_Noeud[Ind_Ind_NAT[j][1]]};
            long S=Ind_NAT_j[0]+Ind_NAT_j[1];
            bool b=1;        
            pair<mmit,mmit> k=MMap_S_Ind_Arete_Cavite.equal_range(S);
            mmit l;
            for(l=k.first;l!=k.second;l++)
            {
                pair<long,S_2Long> Paire_l=*l;
                if(((Paire_l.second.L[0]==Ind_NAT_j[0])&&(Paire_l.second.L[1]==Ind_NAT_j[1]))||
                   ((Paire_l.second.L[0]==Ind_NAT_j[1])&&(Paire_l.second.L[1]==Ind_NAT_j[0])))
                {
                    b=0;
                    break;
                }
            }

            if(b)
            {    
                /*Sortie_TP<<"ZONE T=Arete_"<<I<<" I=2 F=POINT\n";
                long J;
                for(J=0;J<3;J++)
                    Sortie_TP<<Diag_Vor.Tab_Noeud[Ind_NAT_j[0]*3+J]<<"\n";
                Sortie_TP<<Couleur<<"\n";

                for(J=0;J<3;J++)
                    Sortie_TP<<Diag_Vor.Tab_Noeud[Ind_NAT_j[1]*3+J]<<"\n";
                Sortie_TP<<Couleur<<"\n";

                S_Cellule_V* P_Cellule_a_Tronquer=Diag_Vor.List_Cellule[Ind_NAT_j[0]];
                for(J=0;J<P_Cellule_a_Tronquer->P_List_Ind_Face->size();J++)
                {
                    S_Face_V* P_Face_a_Tronquer=Diag_Vor.List_Face[P_Cellule_a_Tronquer->P_List_Ind_Face->at(J)];
                    if((P_Face_a_Tronquer->Ind_Noeud[0]==Ind_NAT_j[1])||(P_Face_a_Tronquer->Ind_Noeud[1]==Ind_NAT_j[1]))
                    {
                        Sortie_Tecplot_Face_Vor(P_Face_a_Tronquer,Couleur,Sortie_TP);
                    }
                }*/

                list<double*> List_Coord_Sommet_Face;
                List_Coord_Sommet_Face.push_back(P_Sommet_C_i->Sommet);

                /*string Nom_Face="Tet_Face_";
                char I_char[255];
                itoa(I,I_char,10);
                Nom_Face+=I_char;
                Couleur=rand()/(double)RAND_MAX;
                Sortie_Tecplot_Tetraedre(P_Sommet_C_i,Couleur,Nom_Face,Sortie_TP);*/

                long Ind_Noeud_Face_Fin_d_g[2][3];
                double Coord_Sommet_Fin_d_g[2][3];
                
                bool Face_Ouverte=1;
                long Ind_Face_Temp=Ind_Face_d_g[j][0];
                C_Sommet* P_Sommet_Temp=P_Sommet_C_i;
                do
                {
                    C_Sommet* P_Sommet_Temp_mm=P_Sommet_Temp;
                    P_Sommet_Temp=Diag_Vor.List_Sommet[P_Sommet_Temp->Ind_Sommet[Ind_Face_Temp]];
                    //if(P_Sommet_Temp->Type!=10)
                    if(!Tab_Sommet_Visite[P_Sommet_Temp->My_Index])
                    {
                        Ind_Noeud_Face_Fin_d_g[0][0]=P_Sommet_Temp_mm->Ind_Noeud[Ind_Face_Temp];
                        Ind_Noeud_Face_Fin_d_g[0][1]=P_Sommet_Temp_mm->Ind_Noeud[(Ind_Face_Temp+1)%4];
                        Ind_Noeud_Face_Fin_d_g[0][2]=P_Sommet_Temp_mm->Ind_Noeud[(Ind_Face_Temp+2)%4];
                        break;
                    }
                    
                    if(P_Sommet_Temp==P_Sommet_C_i)
                    {
                        Face_Ouverte=0;
                        break;
                    }
                    
                    List_Coord_Sommet_Face.push_back(P_Sommet_Temp->Sommet);

                    //Sortie_Tecplot_Tetraedre(P_Sommet_Temp,Couleur,Nom_Face,Sortie_TP);

                    long m;
                    for(m=0;m<6;m++)
                    {
                        if((P_Sommet_Temp->Ind_Noeud[Ind_Ind_NAT[m][0]]==Ind_NAT_j[0])&&(P_Sommet_Temp->Ind_Noeud[Ind_Ind_NAT[m][1]]==Ind_NAT_j[1]))
                        {
                            Ind_Face_Temp=Ind_Face_d_g[m][0];
                            break;
                        }
                        else
                        {
                            if((P_Sommet_Temp->Ind_Noeud[Ind_Ind_NAT[m][0]]==Ind_NAT_j[1])&&(P_Sommet_Temp->Ind_Noeud[Ind_Ind_NAT[m][1]]==Ind_NAT_j[0]))
                            {
                                Ind_Face_Temp=Ind_Face_d_g[m][1];
                                break;
                            }
                        }
                    }
                                               
                }while(1);

                if(Face_Ouverte)
                {
                    Ind_Face_Temp=Ind_Face_d_g[j][1];
                    C_Sommet* P_Sommet_Temp=P_Sommet_C_i;
                    do
                    {
                        C_Sommet* P_Sommet_Temp_mm=P_Sommet_Temp;
                        P_Sommet_Temp=Diag_Vor.List_Sommet[P_Sommet_Temp->Ind_Sommet[Ind_Face_Temp]];
                        //if(P_Sommet_Temp->Type!=10)
                        if(!Tab_Sommet_Visite[P_Sommet_Temp->My_Index])
                        {
                            Ind_Noeud_Face_Fin_d_g[1][0]=P_Sommet_Temp_mm->Ind_Noeud[Ind_Face_Temp];
                            Ind_Noeud_Face_Fin_d_g[1][1]=P_Sommet_Temp_mm->Ind_Noeud[(Ind_Face_Temp+1)%4];
                            Ind_Noeud_Face_Fin_d_g[1][2]=P_Sommet_Temp_mm->Ind_Noeud[(Ind_Face_Temp+2)%4];
                            break;
                        }
                        
                        List_Coord_Sommet_Face.push_front(P_Sommet_Temp->Sommet);

                        //Sortie_Tecplot_Tetraedre(P_Sommet_Temp,Couleur,Nom_Face,Sortie_TP);

                        long m;
                        for(m=0;m<6;m++)
                        {
                            if((P_Sommet_Temp->Ind_Noeud[Ind_Ind_NAT[m][0]]==Ind_NAT_j[0])&&(P_Sommet_Temp->Ind_Noeud[Ind_Ind_NAT[m][1]]==Ind_NAT_j[1]))
                            {
                                Ind_Face_Temp=Ind_Face_d_g[m][1];
                                break;
                            }    
                            else
                            {
                                if((P_Sommet_Temp->Ind_Noeud[Ind_Ind_NAT[m][0]]==Ind_NAT_j[1])&&(P_Sommet_Temp->Ind_Noeud[Ind_Ind_NAT[m][1]]==Ind_NAT_j[0]))
                                {
                                    Ind_Face_Temp=Ind_Face_d_g[m][0];
                                    break;
                                }
                            }    
                        }
                    }while(1);

                    double Rayon_Sphere_Sommet_Fin;
                    TGM.circumsphere(X,
                                            &Diag_Vor.Tab_Noeud[Ind_Noeud_Face_Fin_d_g[0][0]*3],
                                            &Diag_Vor.Tab_Noeud[Ind_Noeud_Face_Fin_d_g[0][1]*3],
                                            &Diag_Vor.Tab_Noeud[Ind_Noeud_Face_Fin_d_g[0][2]*3],
                                            &Coord_Sommet_Fin_d_g[0][0],&Rayon_Sphere_Sommet_Fin);

                    TGM.circumsphere(X,
                                            &Diag_Vor.Tab_Noeud[Ind_Noeud_Face_Fin_d_g[1][0]*3],
                                            &Diag_Vor.Tab_Noeud[Ind_Noeud_Face_Fin_d_g[1][1]*3],
                                            &Diag_Vor.Tab_Noeud[Ind_Noeud_Face_Fin_d_g[1][2]*3],
                                            &Coord_Sommet_Fin_d_g[1][0],&Rayon_Sphere_Sommet_Fin);

                    List_Coord_Sommet_Face.push_back(&Coord_Sommet_Fin_d_g[0][0]);
                    List_Coord_Sommet_Face.push_back(&Coord_Sommet_Fin_d_g[1][0]);

                    /*Couleur=rand()/(double)RAND_MAX;
                    Sortie_TP<<"ZONE T="<<Nom_Face<<" N=4 E=1 F=FEPOINT ET=Tetrahedron\n";
                    long m;
                    for(m=0;m<3;m++)
                    {
                        long n;
                        for(n=0;n<3;n++)
                            Sortie_TP<<Diag_Vor.Tab_Noeud[3*Ind_Noeud_Face_Fin_d_g[0][m]+n]<<"\n";
                        Sortie_TP<<Couleur<<"\n";
                    }
                    for(m=0;m<3;m++)
                        Sortie_TP<<X[m]<<"\n";
                    Sortie_TP<<Couleur<<"\n";
                    Sortie_TP<<"1 3 2 4\n\n";

                    Couleur=rand()/(double)RAND_MAX;
                    Sortie_TP<<"ZONE T="<<Nom_Face<<" N=4 E=1 F=FEPOINT ET=Tetrahedron\n";
                    for(m=0;m<3;m++)
                    {
                        long n;
                        for(n=0;n<3;n++)
                            Sortie_TP<<Diag_Vor.Tab_Noeud[3*Ind_Noeud_Face_Fin_d_g[1][m]+n]<<"\n";
                        Sortie_TP<<Couleur<<"\n";
                    }
                    for(m=0;m<3;m++)
                        Sortie_TP<<X[m]<<"\n";
                    Sortie_TP<<Couleur<<"\n";
                    Sortie_TP<<"1 3 2 4\n\n";

                    Sortie_TP<<"ZONE T=S_Fin_d_g I=2 F=POINT\n";
                    for(m=0;m<3;m++)
                        Sortie_TP<<Coord_Sommet_Fin_d_g[0][m]<<"\n";
                    Sortie_TP<<Couleur<<"\n";

                    for(m=0;m<3;m++)
                        Sortie_TP<<Coord_Sommet_Fin_d_g[1][m]<<"\n";
                    Sortie_TP<<Couleur<<"\n";*/
                }

                C_Vec3d Normale_Face_Temp(&Diag_Vor.Tab_Noeud[Ind_NAT_j[0]*3],&Diag_Vor.Tab_Noeud[Ind_NAT_j[1]*3]);
                Normale_Face_Temp.Normalize();
                vector<double*> List_Pnt_Face;
                list<double*>::iterator m;
                for(m=List_Coord_Sommet_Face.begin();m!=List_Coord_Sommet_Face.end();m++)List_Pnt_Face.push_back((double*)(*m));

                /*Sortie_TP<<"ZONE T=Face_V_"<<I;
                Couleur=rand()/(double)RAND_MAX;
                Sortie_Tecplot_Polygone(&List_Pnt_Face,Couleur,Sortie_TP);*/

                double Aire_Face_Temp=-Calcul_Aire_Polygon(&List_Pnt_Face,&Normale_Face_Temp);

                C_Pnt3d Pnt_sur_Face_a((Diag_Vor.Tab_Noeud[Ind_NAT_j[0]*3+0]+X[0])/2.,
                                       (Diag_Vor.Tab_Noeud[Ind_NAT_j[0]*3+1]+X[1])/2.,
                                       (Diag_Vor.Tab_Noeud[Ind_NAT_j[0]*3+2]+X[2])/2.);

                C_Pnt3d Pnt_sur_Face_b((Diag_Vor.Tab_Noeud[Ind_NAT_j[1]*3+0]+X[0])/2.,
                                       (Diag_Vor.Tab_Noeud[Ind_NAT_j[1]*3+1]+X[1])/2.,
                                       (Diag_Vor.Tab_Noeud[Ind_NAT_j[1]*3+2]+X[2])/2.);

                C_Pnt3d Pnt_sur_Face_c((Diag_Vor.Tab_Noeud[Ind_NAT_j[0]*3+0]+Diag_Vor.Tab_Noeud[Ind_NAT_j[1]*3+0])/2.,
                                       (Diag_Vor.Tab_Noeud[Ind_NAT_j[0]*3+1]+Diag_Vor.Tab_Noeud[Ind_NAT_j[1]*3+1])/2.,
                                       (Diag_Vor.Tab_Noeud[Ind_NAT_j[0]*3+2]+Diag_Vor.Tab_Noeud[Ind_NAT_j[1]*3+2])/2.);


                C_Vec3d Vec_a_c(Pnt_sur_Face_a,Pnt_sur_Face_c);
                C_Vec3d Vec_b_c(Pnt_sur_Face_b,Pnt_sur_Face_c);

                double Contrib_a=(Vec_a_c*Normale_Face_Temp)*(Aire_Face_Temp/3.);
                double Contrib_b=(Vec_b_c*Normale_Face_Temp)*(-Aire_Face_Temp/3.);

                /*map<long,double>::iterator n=Map_Ind_Voisin_Vol_Contrib.find(Ind_NAT_j[0]);
                if(n!=Map_Ind_Voisin_Vol_Contrib.end())
                {
                    pair<const long,double>& Ref_Paire_n=*n;
                    Ref_Paire_n.second+=Contrib_a;
                }
                else
                    Map_Ind_Voisin_Vol_Contrib.insert(make_pair(Ind_NAT_j[0],Contrib_a));

                n=Map_Ind_Voisin_Vol_Contrib.find(Ind_NAT_j[1]);
                if(n!=Map_Ind_Voisin_Vol_Contrib.end())
                {
                    pair<const long,double>& Ref_Paire_n=*n;
                    Ref_Paire_n.second+=Contrib_b;
                }
                else
                    Map_Ind_Voisin_Vol_Contrib.insert(make_pair(Ind_NAT_j[1],Contrib_b));*/

                if(!Tab_Voisin_O_N_Tampon[Ind_NAT_j[0]])
                {
                    Tab_Voisin_O_N_Tampon[Ind_NAT_j[0]]=1;
                    Tab_Ind_Voisin[I]=Ind_NAT_j[0];I++;
                    if(I==Size_Tab_Ind_Voisin)
                    {
                        Size_Tab_Ind_Voisin*=2;
                        Tab_Ind_Voisin=(long*)realloc(Tab_Ind_Voisin,Size_Tab_Ind_Voisin*sizeof(long));
                    }
                }
                if(!Tab_Voisin_O_N_Tampon[Ind_NAT_j[1]])
                {
                    Tab_Voisin_O_N_Tampon[Ind_NAT_j[1]]=1;
                    Tab_Ind_Voisin[I]=Ind_NAT_j[1];I++;
                    if(I==Size_Tab_Ind_Voisin)
                    {
                        Size_Tab_Ind_Voisin*=2;
                        Tab_Ind_Voisin=(long*)realloc(Tab_Ind_Voisin,Size_Tab_Ind_Voisin*sizeof(long));
                    }
                }

                Tab_Contrib_Voisin_Tampon[Ind_NAT_j[0]]+=Contrib_a;
                Tab_Contrib_Voisin_Tampon[Ind_NAT_j[1]]+=Contrib_b;

                S_2Long Ind_NAT;
                Ind_NAT.L[0]=Ind_NAT_j[0];
                Ind_NAT.L[1]=Ind_NAT_j[1];
                MMap_S_Ind_Arete_Cavite.insert(make_pair(S,Ind_NAT));
            }
        }
    }

    //-----------------------------------------------------------------------//

    double Somme_Contribution=0;
    /*map<long,double>::iterator j;
    for(j=Map_Ind_Voisin_Vol_Contrib.begin();j!=Map_Ind_Voisin_Vol_Contrib.end();j++)
    {
        pair<long,double> Paire_j=*j;
        Somme_Contribution+=Paire_j.second;
    }

    for(j=Map_Ind_Voisin_Vol_Contrib.begin();j!=Map_Ind_Voisin_Vol_Contrib.end();j++)
    {
        pair<long,double> Paire_j=*j;
        S_FoFo FoFo_j;
        FoFo_j.Ind_Voisin=Paire_j.first;
        FoFo_j.Valeur_FF=Paire_j.second/Somme_Contribution;
        P_List_SFoFo->push_back(FoFo_j);
    }*/

    for(i=0;i<I;i++)
    {
        long Ind_Voisin_i=Tab_Ind_Voisin[i];
        double Contrib_Voisin_i=Tab_Contrib_Voisin_Tampon[Ind_Voisin_i];
        Somme_Contribution+=Contrib_Voisin_i;
    }

    double X_Calcule[3]={0.,0.,0.};
    
    for(i=0;i<I;i++)
    {
        long Ind_Voisin_i=Tab_Ind_Voisin[i];
        double Contrib_Voisin_i=Tab_Contrib_Voisin_Tampon[Ind_Voisin_i];
        Contrib_Voisin_i/=Somme_Contribution;

        Tab_Voisin_O_N_Tampon[Ind_Voisin_i]=0;
        Tab_Contrib_Voisin_Tampon[Ind_Voisin_i]=0.;

        long j;for(j=0;j<3;j++)X_Calcule[j]+=Diag_Vor.Tab_Noeud[3*Ind_Voisin_i+j]*Contrib_Voisin_i;

        S_FoFo FoFo_i;
        FoFo_i.Ind_Voisin=Ind_Voisin_i;
        FoFo_i.Valeur_FF=Contrib_Voisin_i;
        P_List_SFoFo->push_back(FoFo_i);
    }

    double Erreur=0.;for(i=0;i<3;i++)Erreur+=fabs(X[i]-X_Calcule[i]);Erreur/=3.;

    //-----------------------------------------------------------------------//

    for(i=0;i<Nb_S_Cavite;i++)
        //P_List_P_Sommet_Cavite->at(i)->Type=10;
        Tab_Sommet_Visite[P_List_P_Sommet_Cavite->at(i)->My_Index]=0;

    //-----------------------------------------------------------------------//

    return Erreur;
}

//---------------------------------------------------------------------------//

double C_Meshless_3d::Fonction_de_Forme_NEM_SIBSON_Watson
(double* X,vector<C_Sommet*>* P_List_P_Sommet_Cavite,vector<S_FoFo>* P_List_SFoFo,
 bool* Tab_Voisin_O_N_Tampon,double* Tab_Contrib_Voisin_Tampon,
 long*& Tab_Ind_Voisin,long& Size_Tab_Ind_Voisin)
{
    long I=0;

    long i;
    long Nb_S_Cavite=P_List_P_Sommet_Cavite->size();
    for(i=0;i<Nb_S_Cavite;i++)
    {
        C_Sommet* P_Sommet_C_i=P_List_P_Sommet_Cavite->at(i);
        
        double Coord_Sommet_Aux[4][3];
        double Rayon_Sphere_Aux[4];
        long j;
        for(j=0;j<4;j++)
        {
            /*double Dist_Face_j=(C_Vec3d(&Diag_Vor.Tab_Noeud[3*P_Sommet_C_i->Ind_Noeud[j]],&Diag_Vor.Tab_Noeud[3*P_Sommet_C_i->Ind_Noeud[(j+1)%4]])^
                                C_Vec3d(&Diag_Vor.Tab_Noeud[3*P_Sommet_C_i->Ind_Noeud[j]],&Diag_Vor.Tab_Noeud[3*P_Sommet_C_i->Ind_Noeud[(j+2)%4]]))*
                                C_Vec3d(&Diag_Vor.Tab_Noeud[3*P_Sommet_C_i->Ind_Noeud[j]],X);*/

            if(!TGM.circumsphere(X,
                                &Diag_Vor.Tab_Noeud[3*P_Sommet_C_i->Ind_Noeud[(j+0)]],
                                &Diag_Vor.Tab_Noeud[3*P_Sommet_C_i->Ind_Noeud[(j+1)%4]],
                                &Diag_Vor.Tab_Noeud[3*P_Sommet_C_i->Ind_Noeud[(j+2)%4]],
                                &Coord_Sommet_Aux[j][0],&Rayon_Sphere_Aux[j]))
            {
                long k;
                for(k=0;k<I;k++)
                {
                    long Ind_Voisin_k=Tab_Ind_Voisin[k];
    
                    Tab_Voisin_O_N_Tampon[Ind_Voisin_k]=0;
                    Tab_Contrib_Voisin_Tampon[Ind_Voisin_k]=0.;
                }

                return 1.;
            }
        }

        double Coef=-1./6.;
        for(j=0;j<4;j++)
        {
            C_Vec3d Normale_j=C_Vec3d(&Coord_Sommet_Aux[j][0],&Coord_Sommet_Aux[(j+1)%4][0])^
                              C_Vec3d(&Coord_Sommet_Aux[j][0],&Coord_Sommet_Aux[(j+2)%4][0]);

            double Vol_j=Normale_j*C_Vec3d(&Coord_Sommet_Aux[j][0],P_Sommet_C_i->Sommet);

            Vol_j*=Coef;

            long Ind_Voisin=P_Sommet_C_i->Ind_Noeud[(j+2)%4];

            if(!Tab_Voisin_O_N_Tampon[Ind_Voisin])
            {
                Tab_Voisin_O_N_Tampon[Ind_Voisin]=1;
                Tab_Ind_Voisin[I]=Ind_Voisin;
                I++;
                if(I==Size_Tab_Ind_Voisin)
                {
                    Size_Tab_Ind_Voisin*=2;
                    Tab_Ind_Voisin=(long*)realloc(Tab_Ind_Voisin,Size_Tab_Ind_Voisin*sizeof(long));
                }
            }

            Tab_Contrib_Voisin_Tampon[Ind_Voisin]+=Vol_j;
            
            Coef*=-1.;
        }
    }

    //-----------------------------------------------------------------------//

    double Somme_Contribution=0.;
    for(i=0;i<I;i++)
    {
        long Ind_Voisin_i=Tab_Ind_Voisin[i];
        double Contrib_Voisin_i=Tab_Contrib_Voisin_Tampon[Ind_Voisin_i];
        Somme_Contribution+=Contrib_Voisin_i;
    }

    double X_Calcule[3]={0.,0.,0.};
    
    for(i=0;i<I;i++)
    {
        long Ind_Voisin_i=Tab_Ind_Voisin[i];
        double Contrib_Voisin_i=Tab_Contrib_Voisin_Tampon[Ind_Voisin_i];
        Contrib_Voisin_i/=Somme_Contribution;

        Tab_Voisin_O_N_Tampon[Ind_Voisin_i]=0;
        Tab_Contrib_Voisin_Tampon[Ind_Voisin_i]=0.;

        long j;for(j=0;j<3;j++)X_Calcule[j]+=Diag_Vor.Tab_Noeud[3*Ind_Voisin_i+j]*Contrib_Voisin_i;

        S_FoFo FoFo_i;
        FoFo_i.Ind_Voisin=Ind_Voisin_i;
        FoFo_i.Valeur_FF=Contrib_Voisin_i;
        P_List_SFoFo->push_back(FoFo_i);
    }

    double Erreur=0.;for(i=0;i<3;i++)Erreur+=fabs(X[i]-X_Calcule[i]);Erreur/=3.;

    //-----------------------------------------------------------------------//

    return Erreur;
}

//---------------------------------------------------------------------------//

double C_Meshless_3d::Fonction_de_Forme_NEM_SIBSON
(double* X,C_Sommet* P_Pr_S_a_Suprimer,bool Gradient,vector<S_FoFo>* P_List_SFoFo,
 bool* Tab_Sommet_Visite,bool* Tab_Voisin_O_N_Tampon,double* Tab_Contrib_Voisin_Tampon,
 long*& Tab_Ind_Voisin,long& Size_Tab_Ind_Voisin)
{
    C_Cellule Cellule_NX;
    vector<C_Sommet*> List_P_Sommet_Cavite;

    if(Gradient)
    {
        Calcul_Cellule_Noeud_a_Inserer(-1,X,P_Pr_S_a_Suprimer,&(Cellule_NX.List_P_Sommet),&List_P_Sommet_Cavite,
                                       Tab_Sommet_Visite);
        Cellule_NX.Build_Topologie();
    }
    else
        Calcul_Cellule_Noeud_a_Inserer(-1,X,P_Pr_S_a_Suprimer,NULL,&List_P_Sommet_Cavite,
                                       Tab_Sommet_Visite);
    
    //-----------------------------------------------------------------------//

    Nb_Cal_FF_Globale++;
    double Erreur=Fonction_de_Forme_NEM_SIBSON_Watson(X,&List_P_Sommet_Cavite,P_List_SFoFo,
                                                      Tab_Voisin_O_N_Tampon,Tab_Contrib_Voisin_Tampon,
                                                      Tab_Ind_Voisin,Size_Tab_Ind_Voisin);

    if(Erreur>PRECISION)
    {
        P_List_SFoFo->clear();
        Erreur=Fonction_de_Forme_NEM_SIBSON_Topo_TDC(X,&List_P_Sommet_Cavite,P_List_SFoFo,
                                                     Tab_Sommet_Visite,Tab_Voisin_O_N_Tampon,Tab_Contrib_Voisin_Tampon,
                                                     Tab_Ind_Voisin,Size_Tab_Ind_Voisin);
        Nb_Cal_FF_Topo_DVC++;
    }
    
    //-----------------------------------------------------------------------//

    if(Gradient)
    {
        double Volume_Cellule_NX=0.;

        C_Vec3d Somme_Gradiant_Volume_Contribution(0.,0.,0.);

        long Nb_Face_CNX=Cellule_NX.List_P_Face.size();
        long i;
        for(i=0;i<Nb_Face_CNX;i++)
        {
            S_Face_V_1* P_Face_CNX_i=Cellule_NX.List_P_Face[i];

            long Ind_Noeud_Voisin=P_Face_CNX_i->Ind_Noeud;
            double* NV=&Diag_Vor.Tab_Noeud[Ind_Noeud_Voisin*3];

            S_Cellule_V* P_Cellule_NV=Diag_Vor.List_Cellule[Ind_Noeud_Voisin];

            //-------------------------------------------------------------------//
            
            vector<double*> List_Pnt_Face_CNX;
                    
            C_Vec3d W(X,NV);
            
            long Nb_Arete_Face_CNX=P_Face_CNX_i->P_List_P_Arete->size();
            long j;
            for(j=0;j<Nb_Arete_Face_CNX;j++)
                List_Pnt_Face_CNX.push_back(P_Face_CNX_i->P_List_P_Arete->at(j)->P_Sommet[0]->Sommet);
            
            double Aire_Face_CNX_par_Module_X_NV=Calcul_Aire_Polygon(&List_Pnt_Face_CNX,&W);
            Volume_Cellule_NX+=Aire_Face_CNX_par_Module_X_NV/6.;
            
            //-------------------------------------------------------------------//
            
            vector<double> List_U_Pnt;
            vector<double> List_V_Pnt;
            
            double O[3]={(X[0]+NV[0])/2.,(X[1]+NV[1])/2.,(X[2]+NV[2])/2.};
            
            double Distance_X_NV=W.Magnitude();
            W/=Distance_X_NV;

            C_Vec3d U;
            
            if(fabs(W.X())>fabs(W.Y()))
            {
                if(fabs(W.X())>fabs(W.Z()))
                {// Axe X
                    U=(W^C_Vec3d(0.,1.,0.)).Normalized();                
                }
                else
                {// Axe Z
                    U=(W^C_Vec3d(1.,0.,0.)).Normalized();                
                }
            }
            else
            {
                if(fabs(W.Y())>fabs(W.Z()))
                {// Axe Y
                    U=(W^C_Vec3d(0.,0.,1.)).Normalized();                
                }
                else
                {// Axe Z
                    U=(W^C_Vec3d(1.,0.,0.)).Normalized();                
                }
            }

            C_Vec3d V=W^U;

            for(j=0;j<Nb_Arete_Face_CNX;j++)
            {
                C_Vec3d OS(O,List_Pnt_Face_CNX[j]);
                List_U_Pnt.push_back(U*OS);
                List_V_Pnt.push_back(V*OS);
            }
            List_U_Pnt.push_back(List_U_Pnt[0]);
            List_V_Pnt.push_back(List_V_Pnt[0]);
        
            double Au=0.;
            double Av=0.;
            for(j=0;j<Nb_Arete_Face_CNX;j++)
            {
                Au+=(List_U_Pnt[j+1]-List_U_Pnt[j])*
                    (List_V_Pnt[j+1]*List_V_Pnt[j+1]+
                     List_V_Pnt[j]*List_V_Pnt[j]+
                     List_V_Pnt[j+1]*List_V_Pnt[j]);

                Av+=(List_V_Pnt[j+1]-List_V_Pnt[j])*
                    (List_U_Pnt[j+1]*List_U_Pnt[j+1]+
                     List_U_Pnt[j]*List_U_Pnt[j]+
                     List_U_Pnt[j+1]*List_U_Pnt[j]);
            }
            Au=-Au/(6.*Distance_X_NV);
            Av=Av/(6.*Distance_X_NV);

            C_Vec3d Grad_Volume_U=U*Av;
            C_Vec3d Grad_Volume_V=V*Au;
            C_Vec3d Grad_Volume_W=W*(Aire_Face_CNX_par_Module_X_NV/(Distance_X_NV*2.));
            C_Vec3d Grad_Volume_UVW=Grad_Volume_U+Grad_Volume_V+Grad_Volume_W;

            for(j=0;j<P_List_SFoFo->size();j++)
            {
                S_FoFo& Ref_S_FoFo_j=P_List_SFoFo->at(j);
                if(Ref_S_FoFo_j.Ind_Voisin==Ind_Noeud_Voisin)
                {
                    Ref_S_FoFo_j.Grad_FF=Grad_Volume_UVW;
                    break;
                }
            }
            
            Somme_Gradiant_Volume_Contribution+=Grad_Volume_UVW;
        }

        for(i=0;i<Nb_Face_CNX;i++)
        {
            S_FoFo& Ref_SFoFo=P_List_SFoFo->at(i);
            Ref_SFoFo.Grad_FF=Ref_SFoFo.Grad_FF/Volume_Cellule_NX-Somme_Gradiant_Volume_Contribution*(Ref_SFoFo.Valeur_FF/Volume_Cellule_NX);
        }
    }

    //-----------------------------------------------------------------------//

    return Erreur;
}

//---------------------------------------------------------------------------//
// Laplace

double C_Meshless_3d::Fonction_de_Forme_NEM_NON_SIBSON_1
(double* X,C_Sommet* P_Pr_S_a_Suprimer,vector<S_FoFo>* P_List_SFoFo,
 bool* Tab_Sommet_Visite,bool* Tab_Voisin_O_N_Tampon,double* Tab_Contrib_Voisin_Tampon,
 long*& Tab_Ind_Voisin,long& Size_Tab_Ind_Voisin)
{
    //long T_0,T_1;

    C_Cellule Cellule_NX;
    Calcul_Cellule_Noeud_a_Inserer(-1,X,P_Pr_S_a_Suprimer,&(Cellule_NX.List_P_Sommet),NULL,Tab_Sommet_Visite);
    
    //-----------------------------------------------------------------------//

    //T_0=clock();

    long I=0;

    vector<C_Sommet_1*>::iterator i;
    for(i=Cellule_NX.List_P_Sommet.begin();i!=Cellule_NX.List_P_Sommet.end();i++)
    {
        C_Sommet_1* P_Sommet_1_i=*i;
        C_Vec3d Si_SVj[3]={C_Vec3d(P_Sommet_1_i->Sommet,P_Sommet_1_i->P_Sommet[0]->Sommet),
                           C_Vec3d(P_Sommet_1_i->Sommet,P_Sommet_1_i->P_Sommet[1]->Sommet),
                           C_Vec3d(P_Sommet_1_i->Sommet,P_Sommet_1_i->P_Sommet[2]->Sommet)};
        long j;
        for(j=0;j<3;j++)
        {
            double Mid_X_NV[3]={(X[0]+Diag_Vor.Tab_Noeud[3*P_Sommet_1_i->Ind_Noeud[j]])/2.,
                                (X[1]+Diag_Vor.Tab_Noeud[3*P_Sommet_1_i->Ind_Noeud[j]+1])/2.,
                                (X[2]+Diag_Vor.Tab_Noeud[3*P_Sommet_1_i->Ind_Noeud[j]+2])/2.};

            C_Vec3d Si_Mid_X_NV(P_Sommet_1_i->Sommet,Mid_X_NV);
            
            C_Vec3d Contrib_Air_Face=Si_Mid_X_NV^(Si_SVj[(j+2)%3]-Si_SVj[j]);
            C_Vec3d X_Mid_X_NV=C_Vec3d(X,Mid_X_NV);
        
            if(!Tab_Voisin_O_N_Tampon[P_Sommet_1_i->Ind_Noeud[j]])
            {
                Tab_Voisin_O_N_Tampon[P_Sommet_1_i->Ind_Noeud[j]]=1;
                Tab_Ind_Voisin[I]=P_Sommet_1_i->Ind_Noeud[j];
                I++;
                if(I==Size_Tab_Ind_Voisin)
                {
                    Size_Tab_Ind_Voisin*=2;
                    Tab_Ind_Voisin=(long*)realloc(Tab_Ind_Voisin,Size_Tab_Ind_Voisin*sizeof(long));
                }
            }

            double Module2_X_Mid_X_NV=X_Mid_X_NV.SquareMagnitude();
            double Contribution_NV=Contrib_Air_Face*X_Mid_X_NV;
            Contribution_NV/=Module2_X_Mid_X_NV;

            Tab_Contrib_Voisin_Tampon[P_Sommet_1_i->Ind_Noeud[j]]+=Contribution_NV;
        }
    }
    
    //T_1=clock();

    //Time[1]+=T_1-T_0;
    
    //-----------------------------------------------------------------------//

    double Somme_Contribution=0.;
    long j;
    for(j=0;j<I;j++)
    {
        long Ind_Voisin_j=Tab_Ind_Voisin[j];
        double Contrib_Voisin_j=Tab_Contrib_Voisin_Tampon[Ind_Voisin_j];
        Somme_Contribution+=Contrib_Voisin_j;
    }

    double X_Calcule[3]={0.,0.,0.};
    
    for(j=0;j<I;j++)
    {
        long Ind_Voisin_j=Tab_Ind_Voisin[j];
        double Contrib_Voisin_j=Tab_Contrib_Voisin_Tampon[Ind_Voisin_j];
        Contrib_Voisin_j/=Somme_Contribution;

        Tab_Voisin_O_N_Tampon[Ind_Voisin_j]=0;
        Tab_Contrib_Voisin_Tampon[Ind_Voisin_j]=0.;

        long k;for(k=0;k<3;k++)X_Calcule[k]+=Diag_Vor.Tab_Noeud[3*Ind_Voisin_j+k]*Contrib_Voisin_j;

        S_FoFo FoFo_j;
        FoFo_j.Ind_Voisin=Ind_Voisin_j;
        FoFo_j.Valeur_FF=Contrib_Voisin_j;
        P_List_SFoFo->push_back(FoFo_j);
    }

    //-----------------------------------------------------------------------//

    double Erreur=0.;for(j=0;j<3;j++)Erreur+=fabs(X[j]-X_Calcule[j]);Erreur/=3.;

    //-----------------------------------------------------------------------//

    return Erreur;
}

//---------------------------------------------------------------------------//
//EFL

double C_Meshless_3d::Fonction_de_Forme_FEM_LINAIRE_sur_Tri(bool Tri_Front_Ini,long Ind_Tri_Front,long Nb_Cal,double X[][3],double FoFo[][3])
{
    double* Coord_Noeud_Tri[3];
    long i;
    for(i=0;i<3;i++)
    {
        if(Tri_Front_Ini)
            Coord_Noeud_Tri[i]=&Diag_Vor.Tab_Noeud[Tab_Ind_Noeud_Tri_Front_Ini[Ind_Tri_Front*3+i]*3];
        else
            Coord_Noeud_Tri[i]=&Diag_Vor.Tab_Noeud[Tab_Ind_Noeud_Tri_Front[Ind_Tri_Front*3+i]*3];
    }

    return Fonction_de_Forme_FEM_LINAIRE_sur_Tri(Coord_Noeud_Tri,Nb_Cal,X,FoFo);
}

double C_Meshless_3d::Fonction_de_Forme_FEM_LINAIRE_sur_Tri(C_Sommet* P_Sommet,long Ind_Face,long Nb_Cal,double X[][3],double FoFo[][3])
{
    double* Coord_Noeud_Tri[3];
    long i;
    for(i=0;i<3;i++)
        Coord_Noeud_Tri[i]=&Diag_Vor.Tab_Noeud[P_Sommet->Ind_Noeud[(Ind_Face+i)%4]*3];

    return Fonction_de_Forme_FEM_LINAIRE_sur_Tri(Coord_Noeud_Tri,Nb_Cal,X,FoFo);
}

double C_Meshless_3d::Fonction_de_Forme_FEM_LINAIRE_sur_Tri(double** Coord_Noeud_Tri,long Nb_Cal,double X[][3],double FoFo[][3])
{
    C_Vec3d Dir_x=C_Vec3d(Coord_Noeud_Tri[0],Coord_Noeud_Tri[1]);
    double Mod_Dir_x=Dir_x.Magnitude();
    Dir_x/=Mod_Dir_x;
    C_Vec3d Dir_y0=C_Vec3d(Coord_Noeud_Tri[0],Coord_Noeud_Tri[2]);
    double Mod_Dir_y0=Dir_y0.Magnitude();
    Dir_y0/=Mod_Dir_y0;
    
    C_Vec3d Dir_y1=(Dir_x^Dir_y0).Normalized()^Dir_x;
    
    double x1_y0=Dir_y0*Dir_x;
    double y1_y0=Dir_y0*Dir_y1;
    
    long i;
    for(i=0;i<Nb_Cal;i++)
    {
        C_Vec3d Vec_NT0_X(Coord_Noeud_Tri[0],X[i]);

        double x1_X=Vec_NT0_X*Dir_x;
        double y1_X=Vec_NT0_X*Dir_y1;

         double y0_X=y1_X/y1_y0;
        double x0_X=x1_X-y0_X*x1_y0;

        x0_X/=Mod_Dir_x;
        y0_X/=Mod_Dir_y0;

        FoFo[i][0]=1.-x0_X-y0_X;
        FoFo[i][1]=x0_X;
        FoFo[i][2]=y0_X;
    }

    double Max_Erreur_FoFo=0.;
    for(i=0;i<Nb_Cal;i++)
    {
        long j;
        for(j=0;j<3;j++)
        {
            double X_Calule=0.;

            long k;
            for(k=0;k<3;k++)
                X_Calule+=FoFo[i][k]*Coord_Noeud_Tri[k][j];

            double Erreur_FoFo=fabs(X[i][j]-X_Calule);

            if(Erreur_FoFo>Max_Erreur_FoFo)
                Max_Erreur_FoFo=Erreur_FoFo;
        }
    }
    return Max_Erreur_FoFo;
}

//---------------------------------------------------------------------------//

double C_Meshless_3d::Fonction_de_Forme_FEM_LINAIRE(double* X,C_Sommet* P_Sommet,vector<S_FoFo>* P_List_SFoFo)
{
    double* Coord_Noeud_Tetra[4];
    double FoFo[4];
    long i;
    for(i=0;i<4;i++)
        Coord_Noeud_Tetra[i]=&Diag_Vor.Tab_Noeud[3*P_Sommet->Ind_Noeud[i]];
    
    double X_Temp[1][3]={{X[0],X[1],X[2]}};

    double Erreur=Fonction_de_Forme_FEM_LINAIRE(Coord_Noeud_Tetra,1,X_Temp,&FoFo);
    
    for(i=0;i<4;i++)
    {
        S_FoFo FoFo_i;
        FoFo_i.Ind_Voisin=P_Sommet->Ind_Noeud[i];
        FoFo_i.Valeur_FF=FoFo[i];
        P_List_SFoFo->push_back(FoFo_i);
    }
    return Erreur;
}

double C_Meshless_3d::Fonction_de_Forme_FEM_LINAIRE(double** Coord_Noeud_Tetra,long Nb_Cal,double X[][3],double FoFo[][4])
{
    C_Vec3d Dir_x=C_Vec3d(Coord_Noeud_Tetra[0],Coord_Noeud_Tetra[2]);
    double Mod_Dir_x=Dir_x.Magnitude();
    Dir_x/=Mod_Dir_x;
    C_Vec3d Dir_y=C_Vec3d(Coord_Noeud_Tetra[0],Coord_Noeud_Tetra[1]);
    double Mod_Dir_y=Dir_y.Magnitude();
    Dir_y/=Mod_Dir_y;
    C_Vec3d Dir_z=C_Vec3d(Coord_Noeud_Tetra[0],Coord_Noeud_Tetra[3]);
    double Mod_Dir_z=Dir_z.Magnitude();
    Dir_z/=Mod_Dir_z;

    C_Vec3d Dir_Z=(Dir_x^Dir_y).Normalized();
    double A=Dir_z*Dir_Z;
    
    C_Vec3d Dir_Y=Dir_Z^Dir_x;
    double B=Dir_y*Dir_Y;

    long i;
    for(i=0;i<Nb_Cal;i++)
    {
        C_Vec3d Vec_NT0_X(Coord_Noeud_Tetra[0],X[i]);

        double Z_=(Vec_NT0_X*Dir_Z)/(A*Mod_Dir_z);

        C_Vec3d Vec_NT0_X_dans_Plan_xy=Vec_NT0_X-Dir_z*(Mod_Dir_z*Z_);

        double Y_=(Vec_NT0_X_dans_Plan_xy*Dir_Y)/(B*Mod_Dir_y);

        C_Vec3d Vec_NT0_X_dans_Dir_x=Vec_NT0_X_dans_Plan_xy-Dir_y*(Mod_Dir_y*Y_);

        double X_=(Vec_NT0_X_dans_Dir_x*Dir_x)/Mod_Dir_x;


        C_Vec3d Vec_NT0_X_Calcule=Dir_x*Mod_Dir_x*X_+Dir_y*Mod_Dir_y*Y_+Dir_z*Mod_Dir_z*Z_;
        
        FoFo[i][0]=1.-X_-Y_-Z_;
        FoFo[i][1]=Y_;
        FoFo[i][2]=X_;
        FoFo[i][3]=Z_;
    }

    double Max_Erreur_FoFo=0.;
    for(i=0;i<Nb_Cal;i++)
    {
        long j;
        for(j=0;j<3;j++)
        {
            double X_Calule=0.;

            long k;
            for(k=0;k<4;k++)
                X_Calule+=FoFo[i][k]*Coord_Noeud_Tetra[k][j];

            double Erreur_FoFo=fabs(X[i][j]-X_Calule);

            if(Erreur_FoFo>Max_Erreur_FoFo)
                Max_Erreur_FoFo=Erreur_FoFo;
        }
    }
    return Max_Erreur_FoFo;
}

double C_Meshless_3d::Fonction_de_Forme_FEM_LINAIRE
(double** Coord_Noeud_Tetra,long Nb_Cal,double X[][3],double& Volume_Tetra,double Grad_FoFo[][3],double FoFo[][4])
{
    C_Vec3d Arete_Tetra[4];

    long i;
    for(i=0;i<4;i++)
        Arete_Tetra[i]=C_Vec3d(Coord_Noeud_Tetra[i],Coord_Noeud_Tetra[(i+1)%4]);

    C_Vec3d Face_Tetra[4];

    Face_Tetra[0]=Arete_Tetra[1]^Arete_Tetra[0];
    Face_Tetra[1]=Arete_Tetra[1]^Arete_Tetra[2];
    Face_Tetra[2]=Arete_Tetra[3]^Arete_Tetra[2];
    Face_Tetra[3]=Arete_Tetra[3]^Arete_Tetra[0];

    Volume_Tetra=Face_Tetra[0]*Arete_Tetra[2];

    for(i=0;i<Nb_Cal;i++)
    {
        C_Vec3d N0_X(Coord_Noeud_Tetra[0],X[i]);
        C_Vec3d N1_X(Coord_Noeud_Tetra[1],X[i]);
    
        FoFo[i][0]=(Face_Tetra[1]*N1_X)/Volume_Tetra;
        FoFo[i][1]=(Face_Tetra[2]*N0_X)/Volume_Tetra;
        FoFo[i][2]=(Face_Tetra[3]*N0_X)/Volume_Tetra;
        FoFo[i][3]=(Face_Tetra[0]*N0_X)/Volume_Tetra;
    }

    for(i=0;i<4;i++)
    {
        Grad_FoFo[i][0]=Face_Tetra[(i+1)%4].X()/Volume_Tetra;
        Grad_FoFo[i][1]=Face_Tetra[(i+1)%4].Y()/Volume_Tetra;
        Grad_FoFo[i][2]=Face_Tetra[(i+1)%4].Z()/Volume_Tetra;
    }

    Volume_Tetra=fabs(Volume_Tetra)/6.;

    double Max_Erreur_FoFo=0.;
    for(i=0;i<Nb_Cal;i++)
    {
        long j;
        for(j=0;j<3;j++)
        {
            double X_Calule=0.;

            long k;
            for(k=0;k<4;k++)
                X_Calule+=FoFo[i][k]*Coord_Noeud_Tetra[k][j];

            double Erreur_FoFo=fabs(X[i][j]-X_Calule);

            if(Erreur_FoFo>Max_Erreur_FoFo)
                Max_Erreur_FoFo=Erreur_FoFo;
        }
    }

    double Grad_Champ_X[3][3]={{0.,0.,0.},{0.,0.,0.},{0.,0.,0.}};
    for(i=0;i<4;i++)
    {
        long j;
        for(j=0;j<3;j++)
        {
            long k;
            for(k=0;k<3;k++)
                Grad_Champ_X[j][k]+=Grad_FoFo[i][k]*Coord_Noeud_Tetra[i][j];
        }
    }

    double Max_Erreur_Grad_FoFo=0.;

    for(i=0;i<3;i++)
    {
        long j;
        for(j=0;j<3;j++)
        {
            double Erreur;
            if(i==j)
                Erreur=fabs(Grad_Champ_X[i][j]-1.);
            else
                Erreur=fabs(Grad_Champ_X[i][j]);
    
            if(Erreur>Max_Erreur_Grad_FoFo)
                Max_Erreur_Grad_FoFo=Erreur;
        }
    }

    if(Max_Erreur_Grad_FoFo>Max_Erreur_FoFo)
        Max_Erreur_FoFo=Max_Erreur_Grad_FoFo;

    return Max_Erreur_FoFo;
}

//---------------------------------------------------------------------------//

double C_Meshless_3d::Fonction_de_Forme
(long Type_FoFo,double* X,C_Sommet* P_Sommet,vector<S_FoFo>* P_List_SFoFo,
 bool* Tab_Sommet_Visite,bool* Tab_Voisin_O_N_Tampon,double* Tab_Contrib_Voisin_Tampon,
 long*& Tab_Ind_Voisin,long& Size_Tab_Ind_Voisin)
{
    double Erreur=0;
    switch(Type_FoFo)
    {
    case 0:
        Erreur=Fonction_de_Forme_NEM_SIBSON(X,P_Sommet,0,P_List_SFoFo,
                                            Tab_Sommet_Visite,Tab_Voisin_O_N_Tampon,Tab_Contrib_Voisin_Tampon,
                                            Tab_Ind_Voisin,Size_Tab_Ind_Voisin);
        long i;
        for(i=0;i<P_List_SFoFo->size();i++)
        {
            if(P_List_SFoFo->at(i).Valeur_FF<0.)
            {
                P_List_SFoFo->clear();
                Erreur=Fonction_de_Forme_FEM_LINAIRE(X,P_Sommet,P_List_SFoFo);
                break;
            }
        }
        break;
    case 1:
        Erreur=Fonction_de_Forme_NEM_NON_SIBSON_1(X,P_Sommet,P_List_SFoFo,
                                                  Tab_Sommet_Visite,Tab_Voisin_O_N_Tampon,Tab_Contrib_Voisin_Tampon,
                                                  Tab_Ind_Voisin,Size_Tab_Ind_Voisin);
        break;
    case 2:
        Erreur=Fonction_de_Forme_FEM_LINAIRE(X,P_Sommet,P_List_SFoFo);
        break;
	case 3://Sibson Raw
        Erreur=Fonction_de_Forme_NEM_SIBSON(X,P_Sommet,1,P_List_SFoFo,
                                            Tab_Sommet_Visite,Tab_Voisin_O_N_Tampon,Tab_Contrib_Voisin_Tampon,
                                            Tab_Ind_Voisin,Size_Tab_Ind_Voisin);
        break;
    }
    return Erreur;
}

//---------------------------------------------------------------------------//
