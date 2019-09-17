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

#include "C_Cellule.h"

//---------------------------------------------------------------------------//

C_Cellule::~C_Cellule()
{
    long Nb_Sommet=List_P_Sommet.size();
    long i;
    for(i=0;i<Nb_Sommet;i++)
        delete List_P_Sommet[i];
    
    long Nb_Face=List_P_Face.size();
    for(i=0;i<Nb_Face;i++)
    {
        S_Face_V_1* P_Face=List_P_Face[i];
        long Nb_Arete=P_Face->P_List_P_Arete->size();
        long j;
        for(j=0;j<Nb_Arete;j++)
            delete P_Face->P_List_P_Arete->at(j);
        delete P_Face->P_List_P_Arete;
        delete P_Face;
    }
}

//---------------------------------------------------------------------------//

void C_Cellule::Build_Topologie()
{
    vector<long> List_Ind_Noeud_Voisin;
    vector<C_Sommet_1*>::iterator iter;
    for(iter=List_P_Sommet.begin();iter!=List_P_Sommet.end();iter++)
    {
        C_Sommet_1* P_Sommet_Ini=(*iter);
        long i;
        for(i=0;i<3;i++)
        {
            long Nb_Noeud_Voisin=List_Ind_Noeud_Voisin.size();
            bool b=1;
            long j;
               for(j=0;j<Nb_Noeud_Voisin;j++)
            {
                 if(P_Sommet_Ini->Ind_Noeud[i]==List_Ind_Noeud_Voisin[j])
                {
                    b=0;
                       break;
                }
            }
            
            if(b)
            {
                List_Ind_Noeud_Voisin.push_back(P_Sommet_Ini->Ind_Noeud[i]);

                S_Face_V_1* P_Face_Temp = new S_Face_V_1;
                P_Face_Temp->P_List_P_Arete = new vector<S_Arete_V_1*>;

                 P_Face_Temp->Ind_Noeud=P_Sommet_Ini->Ind_Noeud[i];
                List_P_Face.push_back(P_Face_Temp);
                
                  C_Sommet_1* P_Sommet_Temp=P_Sommet_Ini;
                 
                do
                {
                    for(j=0;j<3;j++)
                        if(P_Sommet_Temp->Ind_Noeud[j]==P_Sommet_Ini->Ind_Noeud[i])
                            break;

                    long k=(j+2)%3;
                    
                    S_Arete_V_1* P_Arete_Temp = new S_Arete_V_1;
                    P_Arete_Temp->Ind_Noeud=P_Sommet_Temp->Ind_Noeud[k];
                    P_Arete_Temp->P_Sommet[0]=P_Sommet_Temp;
                    P_Arete_Temp->P_Sommet[1]=P_Sommet_Temp->P_Sommet[k];
                    P_Face_Temp->P_List_P_Arete->push_back(P_Arete_Temp);

                    P_Sommet_Temp=P_Sommet_Temp->P_Sommet[k];

                }while(P_Sommet_Temp!=P_Sommet_Ini);
            }
        }
    }
}

//---------------------------------------------------------------------------//
