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

#include "C_Vec3d.h"

class C_Sommet
{
public:

    long Type;
    long My_Index;
    bool Sommet_Infinie;
    long Ind_Noeud[4];
    long Ind_Sommet[4];
    long Ind_Arete[4];
    double Sommet[3];
    double Orthocentre[3];
    double Rayon_Sphere;
    long Ind_Sommet_Out;
    bool Valide;
    bool Ghost;
    double Volume;
    long Ind_Group;

public:

    C_Sommet();
    void operator =(const C_Sommet Other); 
    long Face_qui_ne_contient_pas_le_Noeud(long Index);
    void Face_G_D_B_H(long* Ind_Noeud_B_H,long* Ind_Face_B_H_G_D,long* Ind_Noeud_G_D);
    void Face_qui_Contient_les_2_Noeud(long Ind_Noeud_B,long Ind_Noeud_H,long* Ind_Noeud_GD,long* Ind_Sommet_GD);
    long Ind_Noeud_Externe_a_Face(C_Sommet* P_Sommet,long Ind_Face);
};
