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

#pragma once

#include"C_Sommet.h"

    
struct C_Sommet_1
{
    long Ind_Noeud[3];

    long Ind_Sommet_Externe;

    C_Sommet_1* P_Sommet[3];
    
    double Sommet[3];
    double Rayon_Sphere;
};

struct S_Arete_V_1
{
    long Ind_Noeud;
    C_Sommet_1* P_Sommet[2];
};

struct S_Face_V_1
{
    long Ind_Noeud;
    vector<S_Arete_V_1*>* P_List_P_Arete;
};

class C_Cellule
{
public:

    vector<C_Sommet_1*> List_P_Sommet;
    vector<S_Face_V_1*> List_P_Face;

    void Build_Topologie();
    ~C_Cellule();
};
