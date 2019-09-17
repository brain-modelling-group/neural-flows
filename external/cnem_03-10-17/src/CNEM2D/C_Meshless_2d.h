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

#ifndef C_Meshless_2d_H
#define C_Meshless_2d_H

#include "C_Cellule.h"

struct S_Sommet_Cavite
{
    long Ind_Sommet;
    long Index;
};

struct S_Sommet_Restrain
{
    C_Pnt2d Coord_Sommet;
    double Rayon_Sphere;
    long Ind_Noeud;
    long Ind_Sommet_Externe;
};

struct S_FoFo
{
    long Ind_Voisin;
    double Valeur_FF;
    C_Vec2d Grad_FF;
};

struct S_2_Index
{
    long Index[2];
};

struct S_Pnt_Int
{
    C_Pnt2d Coord_Pnt_Int;
    long Ind_Noeud[2];
    double Landa;
};

struct S_Int_Cel_Front
{
    long Ind_Noeud;
    list<S_Arete>::iterator Iter[2];
    long Type;
    long Ind_Pnt_Int[2];
};

struct S_Som_Cel_Front
{
    long Type;
    long Index;
};

struct S_Cel_Front
{
    long Ind_Noeud;
    vector<S_Som_Cel_Front>* P_List_SSCF;
};

struct S_Contribution_IGsC
{
    long Ind_Voisin;
    C_Vec2d Contribution;
};


struct S_Int_Grad_sur_Cel
{
    double Aire_Cellule;
    C_Pnt2d CdM;
    vector<S_Contribution_IGsC>* P_List_Contribution;
};

struct S_Data_Model_CNEM2D
{
    long Nb_Noeud;
    double* Tab_Noeud;
    long Nb_Front;
    long* Tab_Nb_Noeud_Front;
    long* Tab_Ind_Noeud_Front;
};

struct S_Grad_Stab
{
    vector<size_t> Nb_Voisin;
    vector<size_t> Id_Voisin_0;
    vector<double> Aire_Cellule;
    vector<double> XY_CdM;
    vector<size_t> Ind_Voisin;
    vector<double> Contribution_XY;
    size_t Nb_Contribution_Max;
};

struct comp_arete
{
    bool operator()(const pair<long,long>& lhs, const pair<long,long>& rhs)const
    {
        if(lhs.first<rhs.first)return 1;
        else
        {
            if(lhs.first==rhs.first)
            {
                if(lhs.second<rhs.second)return 1;
                else return 0;
            }
            else return 0;
        }
    }
};

typedef set<pair<long,long>,comp_arete> Set_Arete;

class C_Meshless_2d
{
public:

    double PRECISION_0;
    double PRECISION_1;

    double X_Min,X_Max,Y_Min,Y_Max;
    
    vector<C_Pnt2d> List_Noeud;

    vector<vector<long>*> List_P_Frontiere;
    
    //-----------------------------------------------------------------------//

    //map<const long,S_Sommet>
	vector<S_Sommet>List_Sommet;
    vector<long> List_Index_Dispo;
    
    vector<C_Cellule> List_Cellule;

    vector<S_Pnt_Int> List_Pnt_Int;

    vector<S_Cel_Front> List_S_Cel_Front;

    vector<long> List_Ind_Cel_Interne;

    vector<long> Vec_Ind_Noeud_New_Old;
    
    vector<long> Vec_Ind_Noeud_Old_New;

    //-----------------------------------------------------------------------//

public:

    C_Meshless_2d(long Nb_Noeud,double* P_XY_Noeud,long Nb_Front,size_t* P_Nb_Noeud_Front,size_t* P_Ind_Noeud_Front);

    ~C_Meshless_2d();

    void Voronoi_Non_Contrain();

    long Ajout_Nouveau_Sommet
        (C_Pnt2d Centre,double Rayon,
         long Ind_Noeud_0,long Ind_Noeud_1,long Ind_Noeud_2,
         long Ind_Sommet_0,long Ind_Sommet_1,long Ind_Sommet_2);

    long Ajout_Nouveau_Sommet
        (long Ind_Noeud_0,long Ind_Noeud_1,long Ind_Noeud_2,
         long Ind_Sommet_0,long Ind_Sommet_1,long Ind_Sommet_2);

    long Trouve_Index_Sommet_Dispo();

    void Retire_Sommet(long Ind_Sommet);

    void Permutation_Circulaire_Sommet(long Ind_Sommet,bool Z);

    void Initialisation_Diagramme_Voronoi();
    
    long Descente_Gradiant(long Ind_Sommet_Temp,C_Pnt2d Noeud_a_Inserer);

    long Recherche_Premeier_Sommet_a_Suprimer_dans_Cellule
        (C_Pnt2d Noeud_a_Inserer,C_Pnt2d Noeud_Cellule,C_Cellule Cellule);

    //long Recherche_Premeier_Sommet_a_Suprimer_Aleatoire(C_Pnt2d Noeud_a_Inserer);

    long Descente_Gradiant(long Ind_Sommet_Temp,C_Pnt2d Noeud_a_Inserer,long& Pnt_sur_Arete_Noeud);

    void Recherche_Premeier_Sommet_a_Suprimer_Tache_d_Huile
        (C_Pnt2d Noeud_a_Inserer,long Ind_Sommet_Depart,long& Ind_Pr_S_a_Suprimer,long& Pnt_sur_Arete);

    long Calcul_Nouvelle_Cellule
        (long Ind_Noeud_a_Inserer,C_Pnt2d Noeud_a_Inserer,long Ind_Pr_S_a_Suprimer,
         vector<S_Sommet_Restrain>* P_List_Nouveau_Sommet=NULL);

    void Dispatch_Sommet();
    
    double Fonction_de_Forme_et_Gradiant_de_Fonction_de_Forme
        (C_Pnt2d X,long Ind_Pr_S_a_Suprimer,vector<S_FoFo>* P_List_PSFoFo);
    
    void Voronoi_Contrain();

    //void Renumerotation_Sommet(vector<bool>* P_Vec_Noeud_Valide);

    void Renumerotation_Noeud(vector<bool>* P_Vec_Noeud_Valide);

    void Intersection_Voronoi_Contrain_avec_Frontiere();

    //-----------------------------------------------------------------------//

    static void Calcul_Cercle(C_Pnt2d P1,C_Pnt2d P2,C_Pnt2d P3,C_Pnt2d& Centre,double& Rayon);
    
    static double Calcul_Aire_Polygone(vector<C_Pnt2d>* P_List_Sommet_Polygone);

    static C_Pnt2d Calcul_CdM_Polygone(vector<C_Pnt2d>* P_List_Sommet_Polygone);

    static double Calcul_Aire_Cellule(vector<S_Sommet_Restrain>* P_List_P_Sommet_Cellule);

    //-----------------------------------------------------------------------//

    void Integration_Stabilisee
(vector<size_t>* P_Nb_Voisin,vector<double>* P_Aire_Cellule,vector<double>* P_XY_CdM,
 vector<size_t>* P_Ind_Voisin,vector<double>* P_Contribution_XY);

	void Interpolation_point
(size_t Nb_PntInt,double* P_XY_PntInt,size_t* P_Close_Node,vector<size_t>* P_Vec_Nb_Contrib,vector<size_t>* P_Vec_INV,vector<double>* P_Vec_Phi/*,vector<double>* P_Vec_Gard=NULL*/);
   
    void Sortie_Cellule_VC
        (vector<size_t>* P_Ind_Noeud_Cel,vector<size_t>* P_Nb_S_Cel,vector<double>* P_S_Cel);

    //-----------------------------------------------------------------------//

    void Construction_Base();
    void Integration_Stabilisee(S_Grad_Stab* P_GS);
    void Get_Model_Data(S_Data_Model_CNEM2D* P_Model);
};

#endif
