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

/*-----------------------------------------------------------------------------

                                     \\\|///
                                   \\  - -  //
                                    (  @ @ )
--------------------------------oOOo---O---oOOo-------------------------------*/

#pragma once

#include "C_Diag_Vor.h"
//#include "C_Diag_Vor_1.h"
#include "C_Cellule.h"
#include "Const_Top_Front.h"
#include "tetgen.h"

//----------------------------------------------------------------------------//

struct C_Sommet_Cavite
{
    C_Sommet* P_Sommet;
    long Ind_Face;
    bool Face_Direct;
};

struct S_FoFo
{
    long Ind_Voisin;
    double Valeur_FF;
    C_Vec3d Grad_FF;
};

struct S_Ind_Noeud_Arete_et_Face
{
    long Ind_Noeud_Arete;
    long Ind_Noeud_Face;
};

struct S_Arete_de_Face
{
    long Ind_Face;
    long Ind_Arete;
};

struct S_Data_Face_Tronquee
{
    double Aire;
    vector<long>* P_List_Ind_Arete;
};

struct S_Pnt_Int_FC
{
    C_Sommet* P_Sommet;
    long Ind_Arete;
    long Ind_Face;
    long My_Index;
};

struct S_Pnt_Int_FT
{
    long Ind_Arete;
    long Ind_Face;
    long My_Index;
};

struct S_Ind_Face_Ind_Arete
{
    long Ind_Face;
    long Ind_Arete;
};

struct S_3Double
{
    double D[3];
};

struct S_3Long
{
    long L[3];
};

struct S_2Long
{
    long L[2];
};

struct S_Point_de_Gauss_Tet
{
    double Poids;
    double Poids_Position[4];
};

struct S_Point_de_Gauss_Tri
{
    double Poids;
    double Poids_Position[3];
};

//----------------------------------------------------------------------------//

class C_Meshless_3d
{
public:

    double X_Min,X_Max,Y_Min,Y_Max,Z_Min,Z_Max;

    double X_Centre,Y_Centre,Z_Centre;

    double Arete;

    double PRECISION;
    double PRECISION_0;
    double PRECISION_1;
    double PRECISION_2;
    double PRECISION_3;
    double PRECISION_4;
    double PRECISION_5;
    double PRECISION_6;
    
    C_Diag_Vor Diag_Vor;

    double* Tab_Noeud_Ini;
    long Nb_Noeud_Ini;
    
    long * Tab_Ind_Noeud_Tri_Front_Ini;
    long Nb_Tri_Front_Ini;
    vector<S_Tri_Front> List_Tri_Front_Ini;
    vector<S_Arete_Tri_Front> List_Arete_Tri_Front_Ini;
    double LAMMTF_Ini[3];

    long * Tab_Ind_Noeud_Tri_Front;
    long Nb_Tri_Front;
    vector<S_Tri_Front> List_Tri_Front;
    vector<S_Arete_Tri_Front> List_Arete_Tri_Front;
    double LAMMTF[3];
    
    set<long> Set_Ind_Noeud_Front;

    vector<bool> Tab_Ind_Noeud_Front;

    long* Tab_Flag_Tri_Front;

    vector<S_Point_de_Gauss_Tet> List_SPoint_de_Gauss_Tet[6];
    vector<S_Point_de_Gauss_Tri> List_SPoint_de_Gauss_Tri[8];

    vector<long> New_Ind_Old_Noeud_Ini;
    vector<long> Old_Ind_New_Noeud_Ini;

    long Nb_Cal_FF_Globale;
    long Nb_Cal_FF_Topo_DVC;

    long Rank_In_Group;

    tetgenmesh TGM;

    long Ind_Group_Tet;
    bool Erase_Tet_Out;

    //-----------------------------------------------------------------------//
    
public:

    C_Meshless_3d(
        long nb_noeud,double* tab_noeud,
        long nb_tri_front,long * tab_ind_noeud_tri_front,
        double precision,long rank_in_group,
        vector<long>* P_New_Ind_Old_Noeud_Ini=NULL,vector<long>* P_Old_Ind_New_Noeud_Ini=NULL);

    ~C_Meshless_3d();

    //-----------------------------------------------------------------------//

    void Calcul_Aire_Face(S_Face_V* P_Face);

    double Calcul_Aire_Polygon(vector<double*>*,C_Vec3d* P_Normale_Face);

    bool Calcul_Sphere_4_Point(double** P,double& Rayon);

    void Calcul_Barycentre_Face(S_Face_V* P_Face,double* Barycentre);

    //-----------------------------------------------------------------------//

    void Chargement_Tetra(vector<long>* P_List_Ind_Noeud_Tetra,vector<long>* P_List_Ind_Voisin_Tetra);

    //-----------------------------------------------------------------------//

    void Initialisation_Point_de_Gauss_Tet();
    void Initialisation_Point_de_Gauss_Tri();

    //-----------------------------------------------------------------------//

    C_Sommet* Descente_Gradiant(long Ind_Sommet_Initialisation,double* Noeud_a_Inserer,long* P_Ind_Face=NULL,long* P_Ind_Noeud=NULL);

    C_Sommet* Recherche_Tache_d_Huile
        (long Ind_Sommet_Initialisation,double* Noeud_a_Inserer,long& Ind_Face,bool* Tab_Sommet_Visite);

    bool Calcul_Cellule_Noeud_a_Inserer
        (long Ind_Noeud_a_Inserer,double* Noeud_a_Inserer,C_Sommet* P_Pr_Sommet_a_Suprimer,vector<C_Sommet_1*>* P_List_P_Sommet_Nouvelle_Cellule,vector<C_Sommet*>* P_List_P_Sommet_Cavite,
         bool* Tab_Sommet_Visite);

    double Fonction_de_Forme_NEM_SIBSON
        (double* X,C_Sommet* P_Pr_S_a_Suprimer,bool Gradient,vector<S_FoFo>* P_List_SFoFo,
         bool* Tab_Sommet_Visite,bool* Tab_Voisin_O_N_Tampon,double* Tab_Contrib_Voisin_Tampon,
         long*& Tab_Ind_Voisin,long& Size_Tab_Ind_Voisin);

    double Fonction_de_Forme_NEM_SIBSON_Topo_TDC
        (double* X,vector<C_Sommet*>* P_List_P_Sommet_Cavite,vector<S_FoFo>* P_List_SFoFo,
         bool* Tab_Sommet_Visite,bool* Tab_Voisin_O_N_Tampon,double* Tab_Contrib_Voisin_Tampon,
         long*& Tab_Ind_Voisin,long& Size_Tab_Ind_Voisin);

    double Fonction_de_Forme_NEM_SIBSON_Watson
        (double* X,vector<C_Sommet*>* P_List_P_Sommet_Cavite,vector<S_FoFo>* P_List_SFoFo,
         bool* Tab_Voisin_O_N_Tampon,double* Tab_Contrib_Voisin_Tampon,
         long*& Tab_Ind_Voisin,long& Size_Tab_Ind_Voisin);

    double Fonction_de_Forme_NEM_NON_SIBSON_1
        (double* X,C_Sommet* P_Pr_S_a_Suprimer,vector<S_FoFo>* P_List_SFoFo,
         bool* Tab_Sommet_Visite,bool* Tab_Voisin_O_N_Tampon,double* Tab_Contrib_Voisin_Tampon,
         long*& Tab_Ind_Voisin,long& Size_Tab_Ind_Voisin);

        //-------------------------------------------------------------------//
/*
    void Fonction_de_Forme_NEM_NON_SIBSON_0
        (double* X,C_Sommet* P_Pr_S_a_Suprimer,vector<S_FoFo>* P_List_SFoFo,
         bool* Tab_Sommet_Visite);

    void Fonction_de_Forme_NEM_SIBSON_Topo_DVC
        (double* X,C_Cellule* P_Cellule_NX,vector<S_FoFo>* P_List_SFoFo,long* T=NULL);

    void Fonction_de_Forme_NEM_SIBSON_RLasserre
        (double* X,vector<C_Sommet*>* P_List_P_Sommet_Cavite,vector<S_FoFo>* P_List_SFoFo,
         bool* Tab_Voisin_O_N_Tampon,long* T=NULL);

    bool Calcul_Cellule_Noeud_a_Inserer
        (long Ind_Noeud_a_Inserer,double* Noeud_a_Inserer,C_Sommet* P_Pr_Sommet_a_Suprimer,C_Diag_Vor_1* P_Diag_Vor_Local);

    bool Fonction_de_Forme_NEM_SIBSON_Volume_Complementaire
        (double* X,C_Sommet* P_Pr_S_a_Suprimer,vector<S_FoFo>* P_List_SFoFo,long* T=NULL);
  */  
        //-------------------------------------------------------------------//

    double Fonction_de_Forme_FEM_LINAIRE_sur_Tri(bool Tri_Front_Ini,long Ind_Tri_Front,long Nb_Cal,double X[][3],double FoFo[][3]);
    double Fonction_de_Forme_FEM_LINAIRE_sur_Tri(C_Sommet* P_Sommet,long Ind_Face,long Nb_Cal,double X[][3],double FoFo[][3]);
    double Fonction_de_Forme_FEM_LINAIRE_sur_Tri(double** Coord_Noeud_Tri,long Nb_Cal,double X[][3],double FoFo[][3]);

    double Fonction_de_Forme_FEM_LINAIRE(double* X,C_Sommet* P_Sommet,vector<S_FoFo>* P_List_SFoFo);
    double Fonction_de_Forme_FEM_LINAIRE(double** Coord_Noeud_Tetra,long Nb_Cal,double X[][3],double FoFo[][4]);
    double Fonction_de_Forme_FEM_LINAIRE(double** Coord_Noeud_Tetra,long Nb_Cal,double X[][3],double& Volume_Tetra,double Grad_FoFo[][3],double FoFo[][4]);

    double Fonction_de_Forme(long Type_FoFo,double* X,C_Sommet* P_Sommet,vector<S_FoFo>* P_List_SFoFo,
                             bool* Tab_Sommet_Visite,bool* Tab_Voisin_O_N_Tampon,double* Tab_Contrib_Voisin_Tampon,
                             long*& Tab_Ind_Voisin,long& Size_Tab_Ind_Voisin);

    double Calcul_Erreur_FoFo(double* X,vector<S_FoFo>* P_List_SFoFo);
    double Calcul_Erreur_Grad_FoFo(double* X,vector<S_FoFo>* P_List_SFoFo);

    //-----------------------------------------------------------------------//

    void Randomise_Noeuds(double Random_Dim);

    int Load_Tetgen_TDC(int in_numberofpoints,int out_numberofpoints,int out_numberoftrifaces,int out_numberoftetrahedra,
                        int* in_pointmarkerlist,REAL* out_pointlist,int* out_trifacelist,int* out_trifacemarkerlist,int* out_tetrahedronlist,int* out_neighborlist);

    void Construction_Topologie_Voronoi();

    bool Voronoi_Contrain_TetGen(int Type_Appel,char* Arg_Tet,long ind_group_tet,bool erase_tet_out);

    //-----------------------------------------------------------------------//

    void Calcul_Intersection_Arete_Tri_Front_Face_Cel
        (vector<vector<long>*>* P_List_P_List_Ind_Face_Cel_Intersectee_par_Arete_Tri,vector<vector<long>*>* P_List_P_List_Ind_Arete_Cel_sur_Arete_Tri_Front,
         vector<S_Pnt_Int_FC>* P_List_Pnt_Int_Arete_Tri_Front_Face_Cel);

    bool Arete_Tri_Front_Intersect_Face_Cel
        (long* Ind_Noeud_Arete_Tri,double** Noeud_Arete_Tri,C_Vec3d* P_Vec_Arete_Tri,long Ind_Noeud_Cellule,S_Face_V* P_Face,double* Pnt_Int);

    void Calcul_Intersection_Arete_Cel_Face_Tri_Front
        (vector<vector<long>*>* P_List_P_List_Ind_Face_Cel_Intersectee_par_Arete_Tri,vector<S_Pnt_Int_FC>* P_List_Pnt_Int_Arete_Cel_Face_Tri_Front);

    void Ajout_List_Ind_Face_0_a_List_Ind_Face_1(vector<long>* P_List_Ind_Face_0,list<long>* P_List_Ind_Face_1,long Signe);

    void Trouve_Intersection_Arete_Cel_Face_Tri_Front
        (long Ind_Face,long Ind_Tri,S_Tri_Front* P_Tri_Front,long& Ind_Arete_Int,double* Pnt_Int,list<long>* P_List_Ind_Face_Temp,ofstream& Sortie_TP);

    bool Ajout_Ind_Face_a_List_Ind_Face(long Ind_Face,list<long>* P_List_Ind_Face);

    void Construction_Topolgie_Intersection
        (vector<S_Pnt_Int_FC>* P_List_Pnt_Int_Arete_Tri_Front_Face_Cel,vector<S_Pnt_Int_FC>* P_List_Pnt_Int_Arete_Cel_Face_Tri_Front,
         vector<vector<long>*>* P_List_P_List_Ind_Arete_Cel_sur_Arete_Tri_Front);

    void Ajout_Arete_de_Face_a_List(long Ind_Face,long Ind_Arete,list<S_Arete_de_Face>* P_List_Arete_de_Face);

    void Calcul_Intersection_DiagVor_avec_Frontiere();

    //-----------------------------------------------------------------------//
/*
    void Integration_Stabilisee_A
        (long Type_FF,vector<map<const long,C_Vec3d>*>*& P_List_Gradiant_Stabilisee,vector<double>*& P_List_Volume_Celule);

    void Integration_Stabilisee_B
        (long Type_FF,bool Integration_Fine_Grossiere,vector<map<const long,C_Vec3d>*>*& P_List_Gradiant_Stabilisee,vector<double>*& P_List_Volume_Celule);

    void Integration_Stabilisee_B_FEM
        (vector<map<const long,C_Vec3d>*>*& P_List_Gradiant_Stabilisee,vector<double>*& P_List_Volume_Celule);

    void Integration_Stabilisee_C
        (long Type_FF,vector<map<const long,C_Vec3d>*>*& P_List_Gradiant_Stabilisee,vector<double>*& P_List_Volume_Celule);

    void Integration_Stabilisee_A_B
        (long Type_FF,vector<map<const long,C_Vec3d>*>*& P_List_Gradiant_Stabilisee,vector<double>*& P_List_Volume_Celule);

    void Integration_Stabilisee_D
        (long Type_FF,long Ind_LPG,vector<map<const long,C_Vec3d>*>*& P_List_Gradiant_Stabilisee,vector<double>*& P_List_Volume_Celule);

    void Integration_Stabilisee_E
        (long Type_FF,long Ind_LPG,vector<map<const long,C_Vec3d>*>*& P_List_Gradiant_Stabilisee,vector<double>*& P_List_Volume_Celule);

    void Integration_Stabilisee
        (long Type_Int,long Type_FF,vector<map<const long,C_Vec3d>*>*& P_List_Gradiant_Stabilisee,vector<double>*& P_List_Volume_Celule);

    void Calcul_Erreur_Gradiant_Stabilise(vector<map<const long,C_Vec3d>*>* P_List_Gradiant_Stabilisee);
*/
    //-----------------------------------------------------------------------//

    void Trouve_Ind_Noeud_Tri_Front_Ini_Proche(vector<long>*P_List_Ind_Noeud,vector<long>*P_List_Ind_Noeud_Tri_Front_Ini_Proche);

    void Trouve_Ind_Tri_Front_Ini(vector<long>*P_List_Ind_Noeud,vector<long>*P_List_Ind_Noeud_Tri_Front_Ini_Proche,vector<long>*P_List_Ind_Tri_Front_Ini);

    bool Point_sur_Triangle(long In_Noeud,long Ind_Tri,double Tolerance);

    void Calcul_Interpolation_Noeud_Esclave(vector<long>* P_List_Ind_Noeud_FoFo,vector<double>* P_List_FoFo);

    void Calcul_Interpolation_Noeud_Esclave_Front(vector<long>* P_List_Ind_Noeud_Esclave,vector<long>* P_List_Ind_Noeud_FoFo,vector<double>* P_List_FoFo);

    //-----------------------------------------------------------------------//

    bool Verif_Topo_Tri_Front_et_Initialise_Set_Ind_Noeud_Front_0();

    bool Verif_Topo_Tri_Front_et_Initialise_Tab_Ind_Noeud_Front_1();

    void Remaillage_Tri_Front_Critere_AT_Min(double AT_Max,multimap<long,S_2Long>* P_MMap_Cle_INA_INA=NULL);

    void Remaillage_Tri_Front_Critere_LA_Max(double LA_Max,vector<long>* P_Ind_Voisin_Temp);

    void Remaillage_Tri_Front_Critere_LA_Min(double LA_Min,long Nb_Noeud_avant_RTFCLAMax,
                                                        vector<long>* P_Ind_Voisin_Temp,
                                                        vector<long>* P_Ind_Voisin_0,
                                                        vector<long>* P_Ind_Voisin_1);

    bool Retrait_Arete_Triangulation_Possible
        (long Ind_Arete_a_Sup,vector<set<long >*>* P_Vec_P_Set_Ind_Arete);

    bool Retire_Arete_Triangulation
        (long Ind_Arete_a_Sup,bool Sup_Noeud_A_0,vector<set<long>*>* P_Vec_P_Vec_Ind_Arete,vector<bool>* P_Vec_Arete_a_Suprimer);

    void Remaillage_Tri_Front_Critere_LA_Min
        (double LA_Min,double AT_Min,long Nb_Noeud_avant_RTFCLAMax,vector<long>* P_Ind_Voisin_Temp,
         vector<long>* P_List_CL_Noeud,multimap<long,S_2Long>* P_MMap_Cle_INA_INA,
         vector<long>* P_Ind_Voisin_0,vector<long>* P_Ind_Voisin_1);

    void Remaillage_Tri_Front_Critere_dp
        (vector<long>* P_Ind_Voisin_RI_0,double* Vec_dP_DR,double Seuil_R,double LA_Min_R,double AT_Max,
         multimap<long,S_2Long>* P_MMap_Cle_INA_INA,set<long>* P_Set_Ind_Neoud_Arete_Vive,vector<long>* P_Ind_Voisin_Temp);

    void Verif_ATGD_Arete_Vive(vector<long>* P_List_CL_Noeud,multimap<long,S_2Long>* P_MMap_Cle_INA_INA,double ATGD_Min);

    void Remaillage_Tri_Front(vector<long>* P_Ind_Voisin_0,vector<long>* P_Ind_Voisin_1);

    void Raffinement_Interne
    (double* Vec_dP_DR,double Seuil_R,double Dist_Noeud_Min_Raf,double Dist_Noeud_Max_Sup,
     vector<long>* P_Ind_Voisin_0,vector<long>* P_Ind_Voisin_1,
     vector<long>* P_List_CL_Noeud,multimap<long,S_2Long>* P_MMap_Cle_INA_INA);

    void Raffinement_Externe
    (double* Vec_dP_DR,double Seuil_R,double Dist_Noeud_Min_Raf,double Dist_Noeud_Max_Sup,
     vector<long>* P_Ind_Voisin_0,vector<long>* P_Ind_Voisin_1,
     vector<long>* P_List_CL_Noeud,multimap<long,S_2Long>* P_MMap_Cle_INA_INA);

    bool Check_Dist_Noeud_Interne(double Dist_Noeud_Max_Sup,vector<bool>* P_Vec_Noeud_a_Supprimer);

    void Sup_Noeud_Interne_et_Menage(vector<bool>* P_Vec_Noeud_a_Supprimer);
    
    //-----------------------------------------------------------------------//
/*
    void Sortie_Tecplot_Noeud(ofstream& Sortie_TP);

    void Sortie_Tecplot_Noeud(long Index,ofstream& Sortie_TP,double t,long Iteration);

    void Sortie_Tecplot_Triangulation(ofstream& Sortie_TP);

    void Sortie_Tecplot_Triangulation_Ini(ofstream& Sortie_TP,double t,long Iteration);

    void Sortie_Tecplot_Triangle(long Ind_Tri,ofstream& Sortie_TP);

    void Sortie_Tecplot_Cel_Vor_Domaine(ofstream& Sortie_TP);

    void Sortie_Tecplot_Cel_Vor(S_Cellule_V* P_Cellule,long Index,double Couleur,ofstream& Sortie_TP);

    void Sortie_Tecplot_Face_Vor(S_Face_V* P_Face,double Couleur,ofstream& Sortie_TP);

    void Sortie_Tecplot_Cel_Vor(C_Cellule* P_Cellule,double Couleur,ofstream& Sortie_TP);

    void Sortie_Tecplot_Polygone(vector<double*>* P_List_Pnt_Face,double Couleur,ofstream& Sortie_TP);

    void Sortie_Tecplot_Tetraedrisation(ofstream& Sortie_TP,double t,long Iteration);

    void Sortie_Tecplot_Tetraedre(C_Sommet* P_Sommet,bool Arete_Aussi,double Couleur,ofstream& Sortie_TP);

    void Sortie_Tecplot_Tetraedre(C_Sommet* P_Sommet,double Couleur,string Nom,ofstream& Sortie_TP);

    void Sortie_Tecplot_Cel_Vor_Discretisation_Quart_Tetra(ofstream& Sortie_TP);

    void Sortie_Tecplot_Cel_Vor_Discretisation_Quart_Tetra(S_Cellule_V* P_Cellule,long Ind_Noeud,bool Exterieur,double Couleur,ofstream& Sortie_TP);

    void Sortie_Tecplot_Cel_Vor_Discretisation_Arete(S_Cellule_V* P_Cellule,long Index,ofstream& Sortie_TP);

    void Sortie_Tecplot_Cel_Vor_Noeud(S_Cellule_V* P_Cellule,long Index,ofstream& Sortie_TP);
*/
    //-----------------------------------------------------------------------//
};
