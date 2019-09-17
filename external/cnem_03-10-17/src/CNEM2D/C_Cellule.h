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

#ifndef C_Cellule_H
#define C_Cellule_H

#include "C_Vec2d.h"

struct S_Sommet
{
    bool Valide;
    bool Sommet_Infini;

    long Ind_MExt;
    long Ind_SExt;
    
    C_Pnt2d Coord_Sommet;
    double Rayon_Cercle;

    long Ind_Noeud[3];
    long Ind_Sommet[3];
};

struct S_Arete
{
    long Ind_Noeud;
    long Ind_Sommet[2];
};

class C_Cellule
{
public:

    bool Fermee;
    list<S_Arete>* P_List_Arete;
    
    C_Cellule();
    void Build_Topologie();
};

#endif
