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
// Interpolation des noeuds esclaves

#include "C_Meshless_3d.h"

//---------------------------------------------------------------------------//

void C_Meshless_3d::Calcul_Interpolation_Noeud_Esclave(vector<long>* P_List_Ind_Noeud_FoFo,vector<double>* P_List_FoFo)
{
    vector<long> List_Ind_Noeud_Esclave;
    long i;
    for(i=Nb_Noeud_Ini;i<Diag_Vor.Nb_Noeud;i++)
        List_Ind_Noeud_Esclave.push_back(i);

    Calcul_Interpolation_Noeud_Esclave_Front(&List_Ind_Noeud_Esclave,P_List_Ind_Noeud_FoFo,P_List_FoFo);
}

void C_Meshless_3d::Calcul_Interpolation_Noeud_Esclave_Front(vector<long>* P_List_Ind_Noeud_Esclave,vector<long>* P_List_Ind_Noeud_FoFo,vector<double>* P_List_FoFo)
{
    cout<<"\nCalcul interpolation noeuds esclave:-------------------------------------------\n"<<endl;

    long T_0=clock();

    //-----------------------------------------------------------------------//

    //P_List_Ind_Noeud_FoFo=new vector<long>;
    //P_List_FoFo=new vector<double>;

    vector<long> List_Ind_Noeud_Tri_Front_Ini_Proche;
    vector<long> List_Ind_Tri_Front_Ini;
    
    Trouve_Ind_Noeud_Tri_Front_Ini_Proche(P_List_Ind_Noeud_Esclave,&List_Ind_Noeud_Tri_Front_Ini_Proche);
    cout<<"1->";cout.flush();

    Trouve_Ind_Tri_Front_Ini(P_List_Ind_Noeud_Esclave,&List_Ind_Noeud_Tri_Front_Ini_Proche,&List_Ind_Tri_Front_Ini);
    cout<<"2->";cout.flush();

    double Erreur_Max=0;
    long i;
    for(i=0;i<P_List_Ind_Noeud_Esclave->size();i++)
    {
        double FoFo[3];
        double X[3]={Diag_Vor.Tab_Noeud[3*P_List_Ind_Noeud_Esclave->at(i)],Diag_Vor.Tab_Noeud[3*P_List_Ind_Noeud_Esclave->at(i)+1],Diag_Vor.Tab_Noeud[3*P_List_Ind_Noeud_Esclave->at(i)+2]};
        double Erreur=Fonction_de_Forme_FEM_LINAIRE_sur_Tri(1,List_Ind_Tri_Front_Ini[i],1,&X,&FoFo);
        
        if(Erreur>Erreur_Max)
            Erreur_Max=Erreur;
        
        long j;
        for(j=0;j<3;j++)
        {
            P_List_Ind_Noeud_FoFo->push_back(Tab_Ind_Noeud_Tri_Front_Ini[3*List_Ind_Tri_Front_Ini[i]+j]);
            P_List_FoFo->push_back(FoFo[j]);
        }
            
        /*Dessine_Point(&Diag_Vor.Tab_Noeud[3*List_Ind_Noeud_Esclave[i]],i);
        Dessine_Point(&Diag_Vor.Tab_Noeud[3*List_Ind_Noeud_Tri_Front_Ini_Proche[i]],i);
        TopoDS_Wire Wire;
        TopoDS_Face Face;
        vector<double*> List_Pnt_Tri;
        List_Pnt_Tri.push_back(&Diag_Vor.Tab_Noeud[3*Tab_Ind_Noeud_Tri_Front_Ini[3*List_Ind_Tri_Front_Ini[i]]]);
        List_Pnt_Tri.push_back(&Diag_Vor.Tab_Noeud[3*Tab_Ind_Noeud_Tri_Front_Ini[3*List_Ind_Tri_Front_Ini[i]+1]]);
        List_Pnt_Tri.push_back(&Diag_Vor.Tab_Noeud[3*Tab_Ind_Noeud_Tri_Front_Ini[3*List_Ind_Tri_Front_Ini[i]+2]]);
        Dessine_Polygone(&List_Pnt_Tri,&List_Tri_Front_Ini[List_Ind_Tri_Front_Ini[i]].Normale,1,1,Wire,Face,1,1,Quantity_NOC_YELLOW,Quantity_NOC_RED,.5);*/
    }
    cout<<"3"<<endl;

    cout<<"\nErreur max = "<<Erreur_Max<<"\n"<<endl;

    //-----------------------------------------------------------------------//

    long T_1=clock();
    double Temp_de_Calcul=(T_1-T_0)/double(CLOCKS_PER_SEC);
    cout<<"\nTemp de calcul = "<<Temp_de_Calcul<<" s."<<endl;
}

//---------------------------------------------------------------------------//

void C_Meshless_3d::Trouve_Ind_Noeud_Tri_Front_Ini_Proche(vector<long>*P_List_Ind_Noeud,vector<long>*P_List_Ind_Noeud_Tri_Front_Ini_Proche)
{
    typedef multimap<long,long>::iterator itmm;
    multimap<long,long> MMap_Ind_Noeud_Ind_Noeud_Voisin;
    long I;
    for(I=0;I<List_Arete_Tri_Front.size();I++)
    {
        S_Arete_Tri_Front Arete_I=List_Arete_Tri_Front[I];
        MMap_Ind_Noeud_Ind_Noeud_Voisin.insert(make_pair(Arete_I.Ind_Noeud[0],Arete_I.Ind_Noeud[1]));
        MMap_Ind_Noeud_Ind_Noeud_Voisin.insert(make_pair(Arete_I.Ind_Noeud[1],Arete_I.Ind_Noeud[0]));
    }

    typedef set<long>::iterator its;
    set<long>* P_Set_Ind_Noeud_Front_Tache_d_Huile[3];

    for(I=0;I<3;I++)
        P_Set_Ind_Noeud_Front_Tache_d_Huile[I]=new set<long>;
    
    for(I=0;I<P_List_Ind_Noeud->size();I++)
    {
        P_Set_Ind_Noeud_Front_Tache_d_Huile[1]->insert(P_List_Ind_Noeud->at(I));

        bool b=1;
        do
        {
            its i;
            for(i=P_Set_Ind_Noeud_Front_Tache_d_Huile[1]->begin();i!=P_Set_Ind_Noeud_Front_Tache_d_Huile[1]->end();i++)
            {
                long Ind_Noeud_i=*i;
                pair<itmm,itmm> pair_i=MMap_Ind_Noeud_Ind_Noeud_Voisin.equal_range(Ind_Noeud_i);
                for(itmm j=pair_i.first;j!=pair_i.second;j++)
                {
                    pair<long,long> pair_j=*j;
                    bool Deja_Teste=0;
                    long k;
                    for(k=0;k<3;k++)
                    {
                        its l=P_Set_Ind_Noeud_Front_Tache_d_Huile[k]->find(pair_j.second);
                        if(l!=P_Set_Ind_Noeud_Front_Tache_d_Huile[k]->end())
                        {
                            Deja_Teste=1;
                            break;
                        }
                    } 

                    if(!Deja_Teste)
                    {
                        its l=Set_Ind_Noeud_Front.find(pair_j.second);
                        if(l!=Set_Ind_Noeud_Front.end())
                        {
                            P_List_Ind_Noeud_Tri_Front_Ini_Proche->push_back(pair_j.second);
                            b=0;
                            break;
                        } 
                        else
                            P_Set_Ind_Noeud_Front_Tache_d_Huile[2]->insert(pair_j.second);
                    } 
                } 
                 if(!b)break;
            } 

            if(b)
            {
                P_Set_Ind_Noeud_Front_Tache_d_Huile[0]->clear();
                set<long>* P_Set_Temp=P_Set_Ind_Noeud_Front_Tache_d_Huile[0];
                P_Set_Ind_Noeud_Front_Tache_d_Huile[0]=P_Set_Ind_Noeud_Front_Tache_d_Huile[1];
                P_Set_Ind_Noeud_Front_Tache_d_Huile[1]=P_Set_Ind_Noeud_Front_Tache_d_Huile[2];
                P_Set_Ind_Noeud_Front_Tache_d_Huile[2]=P_Set_Temp;

                /*vector<double*> List_Pnt_Noeud_Front_Tache_d_Huile_1;
                for(i=P_Set_Ind_Noeud_Front_Tache_d_Huile[1]->begin();i!=P_Set_Ind_Noeud_Front_Tache_d_Huile[1]->end();i++)
                    List_Pnt_Noeud_Front_Tache_d_Huile_1.push_back(&Diag_Vor.Tab_Noeud[3*long(*i)]);
                TopoDS_Wire Wire;TopoDS_Face Face;
                Dessine_Polygone(&List_Pnt_Noeud_Front_Tache_d_Huile_1,NULL,1,0,Wire,Face,1,0,Quantity_NOC_YELLOW,Quantity_NOC_YELLOW,0);*/
            }
     
        }while(b);

        long J;
        for(J=0;J<3;J++)
            P_Set_Ind_Noeud_Front_Tache_d_Huile[J]->clear();
    }

    for(I=0;I<3;I++)
        delete P_Set_Ind_Noeud_Front_Tache_d_Huile[I];
}

//---------------------------------------------------------------------------//

void C_Meshless_3d::Trouve_Ind_Tri_Front_Ini
(vector<long>*P_list_Ind_Noeud,vector<long>*P_List_Ind_Noeud_Tri_Front_Ini_Proche,vector<long>*P_List_Ind_Tri_Front_Ini)
{
    typedef map<long,long>::iterator itm;
    map<long,long> Map_Ind_Noeud_Ind_Arete_Tri_Ini;
    long I;
    for(I=0;I<List_Arete_Tri_Front_Ini.size();I++)
    {
        Map_Ind_Noeud_Ind_Arete_Tri_Ini.insert(make_pair(List_Arete_Tri_Front_Ini[I].Ind_Noeud[0],I));
        Map_Ind_Noeud_Ind_Arete_Tri_Ini.insert(make_pair(List_Arete_Tri_Front_Ini[I].Ind_Noeud[1],I));
    }

    typedef set<long>::iterator its;
    set<long>* P_Set_Ind_Arete_Front_Tache_d_Huile[2];
    P_Set_Ind_Arete_Front_Tache_d_Huile[0]=new set<long>;
    P_Set_Ind_Arete_Front_Tache_d_Huile[1]=new set<long>;

    for(I=0;I<P_list_Ind_Noeud->size();I++)
    {
        itm it_I=Map_Ind_Noeud_Ind_Arete_Tri_Ini.find(P_List_Ind_Noeud_Tri_Front_Ini_Proche->at(I));
        pair<long,long> Paire_I=*it_I;
        long Ind_Arete_Noeud_I=Paire_I.second;

        double Tolerance=PRECISION_6;
        long I_Couche_Max=5;
        bool b=1;
        do
        {
            P_Set_Ind_Arete_Front_Tache_d_Huile[0]->insert(Ind_Arete_Noeud_I+1);
            P_Set_Ind_Arete_Front_Tache_d_Huile[0]->insert(-(Ind_Arete_Noeud_I+1));

            long I_Couche=0;

            do
            {
                /*its K;
                for(K=P_Set_Ind_Arete_Front_Tache_d_Huile[0]->begin();K!=P_Set_Ind_Arete_Front_Tache_d_Huile[0]->end();K++)
                {
                    TopoDS_Edge Edge;
                    Dessine_Arete(&Diag_Vor.Tab_Noeud[3*long(List_Arete_Tri_Front_Ini[labs(long(*K))-1].Ind_Noeud[0])],
                                  &Diag_Vor.Tab_Noeud[3*long(List_Arete_Tri_Front_Ini[labs(long(*K))-1].Ind_Noeud[1])],
                                  Edge,1,Quantity_NOC_YELLOW);
                }
                cout<<P_Set_Ind_Arete_Front_Tache_d_Huile[0]->size()<<endl;*/

                while(!P_Set_Ind_Arete_Front_Tache_d_Huile[0]->empty())
                {
                    its it_beg=P_Set_Ind_Arete_Front_Tache_d_Huile[0]->begin();
                    long Ind_Arete_Signie=*it_beg;
                    P_Set_Ind_Arete_Front_Tache_d_Huile[0]->erase(it_beg);

                    long Ind_Arete=labs(Ind_Arete_Signie)-1;
                    long Ind_Tri;
                     if(Ind_Arete_Signie>0)
                           Ind_Tri=List_Arete_Tri_Front_Ini[Ind_Arete].Ind_Tri[0];
                       else
                        Ind_Tri=List_Arete_Tri_Front_Ini[Ind_Arete].Ind_Tri[1];

                    S_Tri_Front Tri=List_Tri_Front_Ini[Ind_Tri];

                    if(Point_sur_Triangle(P_list_Ind_Noeud->at(I),Ind_Tri,Tolerance))
                    {
                           P_List_Ind_Tri_Front_Ini->push_back(Ind_Tri);
                        b=0;
                           break;
                    }  
                    else    
                    {
                         long i;
                        for(i=0;i<3;i++)
                        {
                             long Ind_Arete_i_Tri=labs(Tri.Ind_Arete[i])-1;
                               if(Ind_Arete_i_Tri==Ind_Arete)
                            {
                                long j;
                                for(j=1;j<3;j++)
                                {
                                       long Ind_Arete_ipj_Tri=Tri.Ind_Arete[(i+j)%3];
                                
                                    bool Deja_Traite=0;
                                    long k;
                                    for(k=0;k<2;k++)
                                    {
                                        its l=P_Set_Ind_Arete_Front_Tache_d_Huile[k]->find(Ind_Arete_ipj_Tri);
                                        if(l!=P_Set_Ind_Arete_Front_Tache_d_Huile[k]->end())
                                        {
                                            P_Set_Ind_Arete_Front_Tache_d_Huile[k]->erase(l);
                                            Deja_Traite=1;
                                            break;
                                        }
                                    }    

                                    if(!Deja_Traite)
                                        P_Set_Ind_Arete_Front_Tache_d_Huile[1]->insert(-Ind_Arete_ipj_Tri);
                                }
                                break;
                            }
                        }
                    }    
                }        
                set<long>* P_Set_Temp=P_Set_Ind_Arete_Front_Tache_d_Huile[0];
                P_Set_Ind_Arete_Front_Tache_d_Huile[0]=P_Set_Ind_Arete_Front_Tache_d_Huile[1];
                P_Set_Ind_Arete_Front_Tache_d_Huile[1]=P_Set_Temp;
                I_Couche++;
            }while(b&&(!P_Set_Ind_Arete_Front_Tache_d_Huile[0]->empty())&&(I_Couche<=I_Couche_Max));
            P_Set_Ind_Arete_Front_Tache_d_Huile[0]->clear();
            P_Set_Ind_Arete_Front_Tache_d_Huile[1]->clear();
            Tolerance*=10.;
        }while(b);
    }
}

bool C_Meshless_3d::Point_sur_Triangle(long In_Noeud,long Ind_Tri,double Tolerance)
{
    C_Vec3d NTri_N[3];
    NTri_N[0]=C_Vec3d(&Diag_Vor.Tab_Noeud[3*Tab_Ind_Noeud_Tri_Front_Ini[3*Ind_Tri]],&Diag_Vor.Tab_Noeud[3*In_Noeud]);
    double PrS=NTri_N[0]*List_Tri_Front_Ini[Ind_Tri].Normale;
    if(fabs(PrS)<Tolerance)
    {
        NTri_N[1]=C_Vec3d(&Diag_Vor.Tab_Noeud[3*Tab_Ind_Noeud_Tri_Front_Ini[3*Ind_Tri+1]],&Diag_Vor.Tab_Noeud[3*In_Noeud]);
        NTri_N[2]=C_Vec3d(&Diag_Vor.Tab_Noeud[3*Tab_Ind_Noeud_Tri_Front_Ini[3*Ind_Tri+2]],&Diag_Vor.Tab_Noeud[3*In_Noeud]);

        long i;
        for(i=0;i<3;i++)
        {
            double PrV=List_Tri_Front_Ini[Ind_Tri].Normale*(NTri_N[i]^
                (C_Vec3d(&Diag_Vor.Tab_Noeud[3*Tab_Ind_Noeud_Tri_Front_Ini[3*Ind_Tri+i]],
                         &Diag_Vor.Tab_Noeud[3*Tab_Ind_Noeud_Tri_Front_Ini[3*Ind_Tri+(i+1)%3]]).Normalized()));
            if(PrV>Tolerance)
                return 0;
        }
        return 1;
    }
    else
        return 0;
}
