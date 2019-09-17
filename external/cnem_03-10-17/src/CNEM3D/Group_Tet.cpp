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

#include "Groupe_Tet.h"

void Group_Tet
(int Nb_Tri_Front,int* Tab_Ind_Noeud_Tri_Front,int Nb_Tet,int* Tab_Ind_Noeud_Tet,int* Tab_Ind_V_Tet,int* Tab_Ind_Group_Tet,
 bool break_group)
{
    typedef multimap<int,int>::iterator it_mmap_int_int;
    multimap<int,int> MMap_Cle_Tri_Ind_Tri;
    
    int i;
    for(i=0;i<Nb_Tri_Front;i++)
    {
        int Cle_i=Tab_Ind_Noeud_Tri_Front[3*i]+Tab_Ind_Noeud_Tri_Front[3*i+1]+Tab_Ind_Noeud_Tri_Front[3*i+2]+
                  Tab_Ind_Noeud_Tri_Front[3*i]*Tab_Ind_Noeud_Tri_Front[3*i+1]*Tab_Ind_Noeud_Tri_Front[3*i+2];

        MMap_Cle_Tri_Ind_Tri.insert(make_pair(Cle_i,i));
    }
    
    for(i=0;i<Nb_Tet;i++)Tab_Ind_Group_Tet[i]=-1;
    
    int Ind_Tet_Ini=-1;
    
    for(i=0;i<Nb_Tet;i++)
    {    
        int j;for(j=0;j<4;j++){if(Tab_Ind_V_Tet[4*i+j]==-1){Ind_Tet_Ini=i;break;}}
    }

    int Ind_Groupe_Temp=0;
    vector<int> List_Ind_Tet_Front_Tache_d_Huile[2];
    int Ind_List=0;

    while(Ind_Tet_Ini!=-1)
    {
        Tab_Ind_Group_Tet[Ind_Tet_Ini]=Ind_Groupe_Temp;
        List_Ind_Tet_Front_Tache_d_Huile[Ind_List].push_back(Ind_Tet_Ini);

        Ind_Tet_Ini=-1;

        while(!List_Ind_Tet_Front_Tache_d_Huile[Ind_List].empty())
        {
            while(!List_Ind_Tet_Front_Tache_d_Huile[Ind_List].empty())
            {
                int Ind_Tet_Temp=List_Ind_Tet_Front_Tache_d_Huile[Ind_List].back();
                List_Ind_Tet_Front_Tache_d_Huile[Ind_List].pop_back();
                
                int* Ind_Noeud_Tet_Temp=&Tab_Ind_Noeud_Tet[4*Ind_Tet_Temp];
                int* Ind_V_Tet_Temp=&Tab_Ind_V_Tet[4*Ind_Tet_Temp];

                for(i=0;i<4;i++)
                {
                    if(Ind_V_Tet_Temp[i]>=0)
                    {
                        if(Tab_Ind_Group_Tet[Ind_V_Tet_Temp[i]]==-1)
                        {
                            int Ind_Noeud_Face_i[3]={Ind_Noeud_Tet_Temp[(i+1)%4],Ind_Noeud_Tet_Temp[(i+2)%4],Ind_Noeud_Tet_Temp[(i+3)%4]};
                            int Cle_i=Ind_Noeud_Face_i[0]+Ind_Noeud_Face_i[1]+Ind_Noeud_Face_i[2]+Ind_Noeud_Face_i[0]*Ind_Noeud_Face_i[1]*Ind_Noeud_Face_i[2];
                            
                            bool Ok=1;

                            pair<it_mmap_int_int,it_mmap_int_int> Paire_i=MMap_Cle_Tri_Ind_Tri.equal_range(Cle_i);
                            it_mmap_int_int j;
                            for(j=Paire_i.first;j!=Paire_i.second;j++)
                            {
                                pair<int,int> Paire_j=*j;
                                int Ind_Tri_j=Paire_j.second;
                                int* Ind_Noeud_Tri_j=&Tab_Ind_Noeud_Tri_Front[3*Ind_Tri_j];
                                int k;
                                for(k=0;k<3;k++)
                                {
                                    if(Ind_Noeud_Face_i[k]==Ind_Noeud_Tri_j[0])
                                    {
                                        if(((Ind_Noeud_Face_i[(k+1)%3]==Ind_Noeud_Tri_j[1])&&(Ind_Noeud_Face_i[(k+2)%3]==Ind_Noeud_Tri_j[2]))||
                                           ((Ind_Noeud_Face_i[(k+1)%3]==Ind_Noeud_Tri_j[2])&&(Ind_Noeud_Face_i[(k+2)%3]==Ind_Noeud_Tri_j[1])))
                                        {
                                            Ind_Tet_Ini=Ind_V_Tet_Temp[i];
                                            if(break_group)
                                            {
                                                int l;
                                                for(l=0;l<4;l++)
                                                {
                                                    if(Tab_Ind_V_Tet[4*Ind_V_Tet_Temp[i]+l]==Ind_Tet_Temp)
                                                    {
                                                        Tab_Ind_V_Tet[4*Ind_V_Tet_Temp[i]+l]=-Ind_Tet_Temp-2;
                                                        break;
                                                    }
                                                }
                                                Ind_V_Tet_Temp[i]=-Ind_V_Tet_Temp[i]-2;
                                            }
                                            Ok=0;
                                        }
                                        break;
                                    }
                                }
                                if(!Ok)break;
                            }

                            if(Ok)
                            {
                                Tab_Ind_Group_Tet[Ind_V_Tet_Temp[i]]=Ind_Groupe_Temp;
                                List_Ind_Tet_Front_Tache_d_Huile[(Ind_List+1)%2].push_back(Ind_V_Tet_Temp[i]);
                            }
                        }
                    }
                }
            }
            Ind_List=(Ind_List+1)%2;
        }
        Ind_Groupe_Temp++;
    }

    //-----------------------------------------------------------------------//
}
