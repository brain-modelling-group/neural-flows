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

#include "C_Sommet.h"

struct S_Arete_V
{
    long Type;
    long My_Index;
    long Ind_Face[3];
    long Ind_dans_Sommet_0;
    long Ind_Sommet[2];
};

struct S_Face_V
{
    long Type;
    long My_Index;
    long Ind_Noeud[2];
    bool Fermee;
    long Ind_Face_Tronquee;
    list<long>* P_list_Ind_Arete;
    double Aire;
    C_Vec3d Normale;

    bool b;
};

struct S_Cellule_V
{
    long Ind_Cellule_Tronquee;
    vector<long>* P_List_Ind_Face;
    vector<long>* P_List_Ind_Sommet;
    vector<long>* P_List_Ind_Arete;
    double Volume;
};

class C_Diag_Vor{

public:

    //-----------------------------------------------------------------------//

    double* Tab_Noeud;
    long Nb_Noeud;
        
    //-----------------------------------------------------------------------//
    
    vector<C_Sommet*> List_Sommet;
    vector<long> Table_Aloc_List_Sommet;
    
    void Ajout_Sommet(C_Sommet* P_Sommet);
    void Retire_Sommet(long Ind_Sommet);
    C_Sommet* Trouve_Sommet_non_Infini();

    //-----------------------------------------------------------------------//

    vector<S_Arete_V*> List_Arete;
    vector<long> Table_Aloc_List_Arete;

    void Ajout_Arete(S_Arete_V* P_Arete);
    void Retire_Arete(long Ind_Arete);
    
    //-----------------------------------------------------------------------//

    vector<S_Face_V*> List_Face;
    vector<long> Table_Aloc_List_Face;

    void Ajout_Face(S_Face_V* P_Face);
    void Retire_Face(long Ind_Face);
    
    //-----------------------------------------------------------------------//

    vector<S_Cellule_V*> List_Cellule;
        
    //-----------------------------------------------------------------------//

    C_Diag_Vor();
    ~C_Diag_Vor();

    //-----------------------------------------------------------------------//

    void Build_Topologie();
    void Creation_Arete_et_face(C_Sommet* P_Sommet);
    
    //-----------------------------------------------------------------------//

    void Range_Arete_dans_Face(S_Face_V* P_Face);

    //-----------------------------------------------------------------------//

    long Trouve_Ind_Noeud_Arete_dans_Face(S_Arete_V* P_Arete,long* Ind_Noeud_Face);
    
    double* Trouve_Point_sur_Face(S_Face_V* P_Face);

    void Trouve_Coord_Sommet_Face(S_Face_V* P_Face,vector<double*>* P_List_Coord_Sommet_Face);
    void Trouve_Coord_Sommet_Face(S_Face_V* P_Face,vector<double*>* P_List_Coord_Sommet_Face,C_Vec3d* Dir_Inf);

    C_Vec3d Dir_Inf(C_Sommet* P_Sommet_Inf);

    C_Vec3d Calcul_Normale_Face(S_Face_V* P_Face);

    //-----------------------------------------------------------------------//

    void Trouve_Face_Cel_Libre(long Ind_Noeud,S_Cellule_V* P_Cellule,vector<long>* P_List_Ind_Face_Libre);

    //-----------------------------------------------------------------------//

    double Calcul_Aire_Polygon(vector<double*>* P_List_Pnt_Face,C_Vec3d* P_Normale_Face);

    void Calcul_Normale_et_Aire_Face(S_Face_V* P_Face);

    void Calcul_Normale_et_Aire_Faces();

    void Calcul_Volume_Cellule(S_Cellule_V* P_Cellule);

    void Calcul_Volume_Cellules();
};
