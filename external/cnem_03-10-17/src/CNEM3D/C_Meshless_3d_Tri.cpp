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
// Utilitaire triangulation

#include "C_Meshless_3d.h"

//---------------------------------------------------------------------------//

bool C_Meshless_3d::Verif_Topo_Tri_Front_et_Initialise_Set_Ind_Noeud_Front_0()
{
    if(Construction_Topologie_Frontiere(Nb_Noeud_Ini,Tab_Noeud_Ini,Nb_Tri_Front_Ini,Tab_Ind_Noeud_Tri_Front_Ini,
                                        &List_Tri_Front_Ini,&List_Arete_Tri_Front_Ini,LAMMTF_Ini))
    {
        Set_Ind_Noeud_Front.clear();
        
        long i;
        for(i=0;i<List_Arete_Tri_Front_Ini.size();i++)
        {
            Set_Ind_Noeud_Front.insert(List_Arete_Tri_Front_Ini[i].Ind_Noeud[0]);
            Set_Ind_Noeud_Front.insert(List_Arete_Tri_Front_Ini[i].Ind_Noeud[1]);
        } 
        
        PRECISION_6=LAMMTF_Ini[2]*1.e-6;

        return 1;
    }
    else
        return 0;
}

bool C_Meshless_3d::Verif_Topo_Tri_Front_et_Initialise_Tab_Ind_Noeud_Front_1()
{
    if(Construction_Topologie_Frontiere(Diag_Vor.Nb_Noeud,Diag_Vor.Tab_Noeud,Nb_Tri_Front,Tab_Ind_Noeud_Tri_Front,
                                        &List_Tri_Front,&List_Arete_Tri_Front,LAMMTF))
    {
        Tab_Ind_Noeud_Front.resize(Diag_Vor.Nb_Noeud,0);

        long i;
        for(i=0;i<List_Arete_Tri_Front.size();i++)
        {
            Tab_Ind_Noeud_Front[List_Arete_Tri_Front[i].Ind_Noeud[0]]=1;
            Tab_Ind_Noeud_Front[List_Arete_Tri_Front[i].Ind_Noeud[1]]=1;
         } 
        
        return 1;
    }
    else
        return 0;
}

//---------------------------------------------------------------------------//
