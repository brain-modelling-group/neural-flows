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

//----------------------------------------------------------------------------//

#include "Const_Top_Front.h"

bool Construction_Topologie_Frontiere
(long Nb_Noeud, double* Tab_Noeud,long Nb_Tri_Front,long* Tab_Ind_Noeud_Tri_Front,
 vector<S_Tri_Front>* P_List_Tri_Front,vector<S_Arete_Tri_Front>* P_List_Arete_Tri_Front,double* LAMMTF)
{
    //cout<<"\nConstruction topologie frontiere-----------------------------------------------\n"<<endl;
        
    //-----------------------------------------------------------------------//

    P_List_Tri_Front->clear();
    P_List_Arete_Tri_Front->clear();

    //-----------------------------------------------------------------------//
    
    //cout<<"Nb triangle = "<<Nb_Tri_Front<<endl;

    multimap<long ,long> MMap_SommeIndNA_IndA;
    typedef multimap<long ,long>::iterator mmit;

    double Aire_Triangulation=0.;
    double Volume_Triangulation=0.;
    double P_000[3]={0.,0.,0.};

    LAMMTF[2]=0.;
    bool LAMMTF_Initialisee=0;
    double Min_Aire_Face=0.;

    long i;
    for(i=0;i<Nb_Tri_Front;i++)
    {
        if(Tab_Ind_Noeud_Tri_Front[i*3]==Tab_Ind_Noeud_Tri_Front[i*3+1]||
           Tab_Ind_Noeud_Tri_Front[i*3]==Tab_Ind_Noeud_Tri_Front[i*3+2]||
           Tab_Ind_Noeud_Tri_Front[i*3+1]==Tab_Ind_Noeud_Tri_Front[i*3+2])
        {
            cout<<"Probleme avec triangulation frontiere : noeud double dans triangle "<<i<<" !"<<endl;
            return 0;
        }

        S_Tri_Front Tri_Front_i;
        
        bool b[3]={1,1,1};
        long j;
        for(j=0;j<3;j++)
        {
            long Somme=Tab_Ind_Noeud_Tri_Front[i*3+j]+Tab_Ind_Noeud_Tri_Front[i*3+(j+1)%3];
            pair<mmit,mmit> k=MMap_SommeIndNA_IndA.equal_range(Somme);
            
            for(mmit l=k.first;l!=k.second;l++)
            {
                pair<long ,long> paire_l=*l;
                long Ind_Arete=paire_l.second;
                S_Arete_Tri_Front& Ref_Arete=P_List_Arete_Tri_Front->at(Ind_Arete);

                if(Tab_Ind_Noeud_Tri_Front[i*3+j]==Ref_Arete.Ind_Noeud[1]&&
                   Tab_Ind_Noeud_Tri_Front[i*3+(j+1)%3]==Ref_Arete.Ind_Noeud[0])
                {
                    if(Ref_Arete.Ind_Tri[1]==-1)
                    {
                        Ref_Arete.Ind_Tri[1]=i;
                        Tri_Front_i.Ind_Arete[j]=-(Ind_Arete+1);
                        b[j]=0;
                        break;
                    }
                    else
                    {
                        cout<<"Probleme avec triangulation frontiere : arete partagee entre plus de 2 triangle, "
                            <<Ref_Arete.Ind_Tri[0]<<" , "<<Ref_Arete.Ind_Tri[1]<<" , "<<i<<" !"<<endl;
                        return 0;
                    }
                }
                else
                {
                    if(Tab_Ind_Noeud_Tri_Front[i*3+j]==Ref_Arete.Ind_Noeud[0]&&
                       Tab_Ind_Noeud_Tri_Front[i*3+(j+1)%3]==Ref_Arete.Ind_Noeud[1])
                    {
                        if(Ref_Arete.Ind_Tri[1]==-1)
                        {
                            Ref_Arete.Ind_Tri[1]=i;
                            Tri_Front_i.Ind_Arete[j]=Ind_Arete+1;
                            b[j]=0;
                            break;
                        }
                        else
                        {    cout<<"Probleme avec triangulation frontiere : arete partagee entre plus de 2 triangle, "<<Ref_Arete.Ind_Tri[0]<<' '<<Ref_Arete.Ind_Tri[1]<<' '<<i<<" !"<<endl;
                            return 0;
                        }
                    }
                }
            }
        }

        for(j=0;j<3;j++)
        {
            if(b[j])
            {
                long Somme=Tab_Ind_Noeud_Tri_Front[i*3+j]+Tab_Ind_Noeud_Tri_Front[i*3+(j+1)%3];
                long Ind_Nouvelle_Arete=P_List_Arete_Tri_Front->size();
                MMap_SommeIndNA_IndA.insert(make_pair(Somme,Ind_Nouvelle_Arete));
                
                S_Arete_Tri_Front Nouvelle_Arete;
                Nouvelle_Arete.Ind_Noeud[0]=Tab_Ind_Noeud_Tri_Front[i*3+j];
                Nouvelle_Arete.Ind_Noeud[1]=Tab_Ind_Noeud_Tri_Front[i*3+(j+1)%3];
                Nouvelle_Arete.Ind_Tri[0]=i;
                Nouvelle_Arete.Ind_Tri[1]=-1;
                P_List_Arete_Tri_Front->push_back(Nouvelle_Arete);
                Tri_Front_i.Ind_Arete[j]=P_List_Arete_Tri_Front->size();

                double Longuer_Arete=(C_Vec3d(&Tab_Noeud[Tab_Ind_Noeud_Tri_Front[i*3+j]*3],&Tab_Noeud[Tab_Ind_Noeud_Tri_Front[i*3+(j+1)%3]*3])).Magnitude();

                LAMMTF[2]+=Longuer_Arete;

                if(LAMMTF_Initialisee)
                {
                    if(Longuer_Arete<LAMMTF[0])
                        LAMMTF[0]=Longuer_Arete;
                    else
                    {
                        if(Longuer_Arete>LAMMTF[1])
                            LAMMTF[1]=Longuer_Arete;
                    }
                }
                else
                {
                    LAMMTF[0]=Longuer_Arete;
                    LAMMTF[1]=Longuer_Arete;
                    LAMMTF_Initialisee=1;
                }
            }
        }
        
        Tri_Front_i.Normale=(C_Vec3d(&Tab_Noeud[Tab_Ind_Noeud_Tri_Front[i*3]*3],&Tab_Noeud[Tab_Ind_Noeud_Tri_Front[i*3+1]*3])^
                             C_Vec3d(&Tab_Noeud[Tab_Ind_Noeud_Tri_Front[i*3]*3],&Tab_Noeud[Tab_Ind_Noeud_Tri_Front[i*3+2]*3]));

        P_List_Tri_Front->push_back(Tri_Front_i);
    }

    if((P_List_Arete_Tri_Front->size()*2)!=(Nb_Tri_Front*3))
    {
        cout<<"Probleme avec triangulation frontiere : trinagultion non fermee (trou) !"<<endl;
        return 0;
    }

    LAMMTF[2]/=P_List_Arete_Tri_Front->size();

    //-----------------------------------------------------------------------//

    long* Tab_Ind_Groupe_Tri=(long*)malloc(Nb_Tri_Front*sizeof(long));
    for(i=0;i<Nb_Tri_Front;i++)Tab_Ind_Groupe_Tri[i]=-1;

    long Ind_Groupe_Temp=0;
    long Ind_Tri_Ini=0;

    vector<long> List_Ind_Tri_Front_Tache_d_Huile[2];
    long Ind_List=0;

    while(Ind_Tri_Ini!=-1)
    {
        S_Tri_Front Tri_Ini=P_List_Tri_Front->at(Ind_Tri_Ini);
        for(i=0;i<3;i++)
        {
            S_Arete_Tri_Front& Ref_Arete_i=P_List_Arete_Tri_Front->at(labs(Tri_Ini.Ind_Arete[i])-1);

            if(((Tri_Ini.Ind_Arete[i]>0)&&(Ref_Arete_i.Ind_Tri[0]!=Ind_Tri_Ini))||
               ((Tri_Ini.Ind_Arete[i]<0)&&(Ref_Arete_i.Ind_Tri[1]!=Ind_Tri_Ini)))
            {
                long Ind_Temp=Ref_Arete_i.Ind_Tri[0];
                Ref_Arete_i.Ind_Tri[0]=Ref_Arete_i.Ind_Tri[1];
                Ref_Arete_i.Ind_Tri[1]=Ind_Temp;
            }
        }

        Tab_Ind_Groupe_Tri[Ind_Tri_Ini]=Ind_Groupe_Temp;
        List_Ind_Tri_Front_Tache_d_Huile[Ind_List].push_back(Ind_Tri_Ini);
        Ind_Tri_Ini=-1;

        while(!List_Ind_Tri_Front_Tache_d_Huile[Ind_List].empty())
        {
            while(!List_Ind_Tri_Front_Tache_d_Huile[Ind_List].empty())
            {
                long Ind_Tri_Temp=List_Ind_Tri_Front_Tache_d_Huile[Ind_List].back();
                List_Ind_Tri_Front_Tache_d_Huile[Ind_List].pop_back();
                S_Tri_Front Tri_Temp=P_List_Tri_Front->at(Ind_Tri_Temp);
        
                for(i=0;i<3;i++)
                {        
                    S_Arete_Tri_Front Arete_i=P_List_Arete_Tri_Front->at(labs(Tri_Temp.Ind_Arete[i])-1);
                    long Ind_Tri_Voisin;
                    if(Tri_Temp.Ind_Arete[i]>0)Ind_Tri_Voisin=Arete_i.Ind_Tri[1];
                    else Ind_Tri_Voisin=Arete_i.Ind_Tri[0];

                    if(Tab_Ind_Groupe_Tri[Ind_Tri_Voisin]==-1)
                    {
                        S_Tri_Front& Ref_Tri_Voisin=P_List_Tri_Front->at(Ind_Tri_Voisin);
                        
                        long j;
                        for(j=0;j<3;j++)
                        {
                            if(Ref_Tri_Voisin.Ind_Arete[j]==Tri_Temp.Ind_Arete[i])
                            {
                                Ref_Tri_Voisin.Ind_Arete[0]=-Ref_Tri_Voisin.Ind_Arete[0];
                                long Ind_Arete_Temp=Ref_Tri_Voisin.Ind_Arete[1];
                                Ref_Tri_Voisin.Ind_Arete[1]=-Ref_Tri_Voisin.Ind_Arete[2];
                                Ref_Tri_Voisin.Ind_Arete[2]=-Ind_Arete_Temp;
                                
                                long Ind_Noeud_Temp=Tab_Ind_Noeud_Tri_Front[3*Ind_Tri_Voisin];
                                Tab_Ind_Noeud_Tri_Front[3*Ind_Tri_Voisin]=Tab_Ind_Noeud_Tri_Front[3*Ind_Tri_Voisin+1];
                                Tab_Ind_Noeud_Tri_Front[3*Ind_Tri_Voisin+1]=Ind_Noeud_Temp;

                                Ref_Tri_Voisin.Normale*=-1.;
                                
                                break;
                            }
                        }

                        for(j=0;j<3;j++)
                        {
                            S_Arete_Tri_Front& Ref_Arete_j=P_List_Arete_Tri_Front->at(labs(Ref_Tri_Voisin.Ind_Arete[j])-1);

                            if(((Ref_Tri_Voisin.Ind_Arete[j]>0)&&(Ref_Arete_j.Ind_Tri[0]!=Ind_Tri_Voisin))||
                               ((Ref_Tri_Voisin.Ind_Arete[j]<0)&&(Ref_Arete_j.Ind_Tri[1]!=Ind_Tri_Voisin)))
                            {
                                long Ind_Temp=Ref_Arete_j.Ind_Tri[0];
                                Ref_Arete_j.Ind_Tri[0]=Ref_Arete_j.Ind_Tri[1];
                                Ref_Arete_j.Ind_Tri[1]=Ind_Temp;
                            }
                        }

                        Tab_Ind_Groupe_Tri[Ind_Tri_Voisin]=Ind_Groupe_Temp;
                        List_Ind_Tri_Front_Tache_d_Huile[(Ind_List+1)%2].push_back(Ind_Tri_Voisin);
                    }
                }
            }
            Ind_List=(Ind_List+1)%2;
        }

        for(i=0;i<Nb_Tri_Front;i++)
        {
            if(Tab_Ind_Groupe_Tri[i]==-1){Ind_Tri_Ini=i;break;}
        }

        Ind_Groupe_Temp++;
    }

    //cout<<"nb groupe tri : "<<Ind_Groupe_Temp<<endl;

    //-----------------------------------------------------------------------//

    double* Tab_Vol_Tri=(double*)malloc(sizeof(double)*Ind_Groupe_Temp);
    for(i=0;i<Ind_Groupe_Temp;i++)Tab_Vol_Tri[i]=0.;
    
    for(i=0;i<Nb_Tri_Front;i++)
    {
        S_Tri_Front& Tri_Front_i=P_List_Tri_Front->at(i);
        double Aire_Tri=Tri_Front_i.Normale.Magnitude()/2.;
        
        if(i)
            if(Aire_Tri<Min_Aire_Face)
                Min_Aire_Face=Aire_Tri;
        else
            Min_Aire_Face=Aire_Tri;

        Aire_Triangulation+=Aire_Tri;

        Tri_Front_i.Normale.Normalize();

        double h=C_Vec3d(P_000,&Tab_Noeud[Tab_Ind_Noeud_Tri_Front[i*3]*3])*(Tri_Front_i.Normale);
        Tab_Vol_Tri[Tab_Ind_Groupe_Tri[i]]+=Aire_Tri*h/3.;
    }

    long* Tab_Ind_Groupe=(long*)malloc(sizeof(long)*Ind_Groupe_Temp);
    for(i=0;i<Ind_Groupe_Temp;i++)Tab_Ind_Groupe[i]=i;
    
    for(i=0;i<Ind_Groupe_Temp;i++)
    {
        long j;
        for(j=i+1;j<Ind_Groupe_Temp;j++)
        {
            if(fabs(Tab_Vol_Tri[j])>fabs(Tab_Vol_Tri[i]))
            {
                double Vol_Temp=Tab_Vol_Tri[i];
                Tab_Vol_Tri[i]=Tab_Vol_Tri[j];
                Tab_Vol_Tri[j]=Vol_Temp;

                long Ind_Temp=Tab_Ind_Groupe[i];
                Tab_Ind_Groupe[i]=Tab_Ind_Groupe[j];
                Tab_Ind_Groupe[j]=Ind_Temp;
            }
        }
    }

    cout<<"Tab vol tri : ";
    for(i=0;i<Ind_Groupe_Temp;i++)cout<<'('<<Tab_Ind_Groupe[i]<<") : "<<Tab_Vol_Tri[i]<<" | ";
    cout<<endl;

    long Nb_Arete_Tri_Front=P_List_Arete_Tri_Front->size();
    bool* Tab_Rev_Arete_01=(bool*)malloc(Nb_Arete_Tri_Front*sizeof(bool));
    for(i=0;i<Nb_Arete_Tri_Front;i++)Tab_Rev_Arete_01[i]=0;
    
    double signe=-1.;
    for(i=0;i<Ind_Groupe_Temp;i++)
    {
        if((Tab_Vol_Tri[i]*signe)>0.)
        {
            long j;
            for(j=0;j<Nb_Tri_Front;j++)
            {
                if(Tab_Ind_Groupe_Tri[j]==Tab_Ind_Groupe[i])
                {
                    S_Tri_Front& Ref_Tri_Front_j=P_List_Tri_Front->at(j);
                    Ref_Tri_Front_j.Ind_Arete[0]=-Ref_Tri_Front_j.Ind_Arete[0];
                    long Ind_Arete_Temp=Ref_Tri_Front_j.Ind_Arete[1];
                    Ref_Tri_Front_j.Ind_Arete[1]=-Ref_Tri_Front_j.Ind_Arete[2];
                    Ref_Tri_Front_j.Ind_Arete[2]=-Ind_Arete_Temp;
                            
                    long Ind_Noeud_Temp=Tab_Ind_Noeud_Tri_Front[3*j];
                    Tab_Ind_Noeud_Tri_Front[3*j]=Tab_Ind_Noeud_Tri_Front[3*j+1];
                    Tab_Ind_Noeud_Tri_Front[3*j+1]=Ind_Noeud_Temp;

                    Ref_Tri_Front_j.Normale*=-1.;

                    long k;for(k=0;k<3;k++)Tab_Rev_Arete_01[labs(Ref_Tri_Front_j.Ind_Arete[k])-1]=1;
                }
            }
            Tab_Vol_Tri[i]*=-1.;
        }
        signe*=-1.;
        Volume_Triangulation+=Tab_Vol_Tri[i];
    }

    for(i=0;i<Nb_Arete_Tri_Front;i++)
    {
        if(Tab_Rev_Arete_01[i])
        {
            S_Arete_Tri_Front& Ref_Arete_i=P_List_Arete_Tri_Front->at(i);
            long Ind_Tri_Temp=Ref_Arete_i.Ind_Tri[0];
            Ref_Arete_i.Ind_Tri[0]=Ref_Arete_i.Ind_Tri[1];
            Ref_Arete_i.Ind_Tri[1]=Ind_Tri_Temp;
        }
    }

    //cout<<"Triangulation correct.\nAire triangulation = "<<Aire_Triangulation<<"\nVolume triangulation = "<<Volume_Triangulation<<endl;
    //cout<<"Longuer Arete: Min = "<<LAMMTF[0]<<", Max = "<<LAMMTF[1]<<endl; 
    
    //-----------------------------------------------------------------------//

    free(Tab_Ind_Groupe_Tri);
    free(Tab_Vol_Tri);
    free(Tab_Ind_Groupe);
    free(Tab_Rev_Arete_01);

    //-----------------------------------------------------------------------//

    return 1;
}
