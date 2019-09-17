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

C_Cellule::C_Cellule():Fermee(1){}

void C_Cellule::Build_Topologie()
{
    if(P_List_Arete->empty())return;

    S_Arete Arete_Temp=P_List_Arete->back();
    P_List_Arete->pop_back();

    list<S_Arete> List_Arete_Rangee;
    List_Arete_Rangee.push_back(Arete_Temp);

    long Ind_Sommet_0=Arete_Temp.Ind_Sommet[0];
    long Ind_Sommet_1=Arete_Temp.Ind_Sommet[1];

    while(!P_List_Arete->empty())
    {
        for(list<S_Arete>::iterator i=P_List_Arete->begin();i!=P_List_Arete->end();i++)
        {
            Arete_Temp=(*i);
            if(Arete_Temp.Ind_Sommet[0]==Ind_Sommet_1)
            {
                List_Arete_Rangee.push_back(Arete_Temp);
                Ind_Sommet_1=Arete_Temp.Ind_Sommet[1];
                P_List_Arete->erase(i);
                break;
            }
            else
            {
                if(Arete_Temp.Ind_Sommet[1]==Ind_Sommet_0)
                {
                    List_Arete_Rangee.push_front(Arete_Temp);
                    Ind_Sommet_0=Arete_Temp.Ind_Sommet[0];
                    P_List_Arete->erase(i);
                    break;
                }
            }
        }
    }

    while(!List_Arete_Rangee.empty())
    {
        P_List_Arete->push_back(List_Arete_Rangee.front());
        List_Arete_Rangee.pop_front();
    }

    if(P_List_Arete->front().Ind_Sommet[0]!=P_List_Arete->back().Ind_Sommet[1])Fermee=0;
}
