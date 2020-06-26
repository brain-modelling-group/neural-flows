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
// Constructeur - destructeur

#include "C_Meshless_3d.h"

//---------------------------------------------------------------------------//

C_Meshless_3d::C_Meshless_3d
(long nb_noeud,double* tab_noeud,
 long nb_tri_front,long* tab_ind_noeud_tri_front,
 double precision,long rank_in_group,
 vector<long>* P_New_Ind_Old_Noeud_Ini,vector<long>* P_Old_Ind_New_Noeud_Ini)
{
    long i;

    Nb_Noeud_Ini=nb_noeud;
    Diag_Vor.Nb_Noeud=nb_noeud;
        
    Tab_Noeud_Ini=tab_noeud;
    Diag_Vor.Tab_Noeud=(double*)malloc(3*nb_noeud*sizeof(double));
    memcpy(Diag_Vor.Tab_Noeud,tab_noeud,3*nb_noeud*sizeof(double));

    Nb_Tri_Front_Ini=nb_tri_front;
    Nb_Tri_Front=nb_tri_front;

    if(tab_ind_noeud_tri_front!=NULL)
    {
        Tab_Ind_Noeud_Tri_Front_Ini=tab_ind_noeud_tri_front;
        Tab_Ind_Noeud_Tri_Front=(long*)malloc(3*nb_tri_front*sizeof(long));
        memcpy(Tab_Ind_Noeud_Tri_Front,tab_ind_noeud_tri_front,3*nb_tri_front*sizeof(long));

        Tab_Flag_Tri_Front=(long*)malloc(nb_tri_front*sizeof(long));
        for(i=0;i<nb_tri_front;i++)Tab_Flag_Tri_Front[i]=1;
    }
    else
    {
        Tab_Ind_Noeud_Tri_Front_Ini=NULL;
        Tab_Ind_Noeud_Tri_Front=NULL;
        Tab_Flag_Tri_Front=NULL;
    }

    PRECISION=precision;

    Rank_In_Group=rank_in_group;
    
    if(P_New_Ind_Old_Noeud_Ini!=NULL)
    {
        New_Ind_Old_Noeud_Ini.resize(P_New_Ind_Old_Noeud_Ini->size());
        copy(P_New_Ind_Old_Noeud_Ini->begin(),P_New_Ind_Old_Noeud_Ini->end(),New_Ind_Old_Noeud_Ini.begin());
    }
    else for(i=0;i<Nb_Noeud_Ini;i++)New_Ind_Old_Noeud_Ini.push_back(i);
    
    if(P_Old_Ind_New_Noeud_Ini!=NULL)
    {
        Old_Ind_New_Noeud_Ini.resize(P_Old_Ind_New_Noeud_Ini->size());
        copy(P_Old_Ind_New_Noeud_Ini->begin(),P_Old_Ind_New_Noeud_Ini->end(),Old_Ind_New_Noeud_Ini.begin());
    }
    else for(i=0;i<Nb_Noeud_Ini;i++)Old_Ind_New_Noeud_Ini.push_back(i);
    
    Initialisation_Point_de_Gauss_Tet();
    Initialisation_Point_de_Gauss_Tri();
    
    //-----------------------------------------------------------------------//
    
    for(i=0;i<Diag_Vor.Nb_Noeud;i++)
    {
        if(i==0)
        {
            X_Min=Diag_Vor.Tab_Noeud[3*i];
            X_Max=Diag_Vor.Tab_Noeud[3*i];

             Y_Min=Diag_Vor.Tab_Noeud[3*i+1];
            Y_Max=Diag_Vor.Tab_Noeud[3*i+1];

            Z_Min=Diag_Vor.Tab_Noeud[3*i+2];
            Z_Max=Diag_Vor.Tab_Noeud[3*i+2];
        }
        else
        {
            if(Diag_Vor.Tab_Noeud[3*i]<X_Min)
                X_Min=Diag_Vor.Tab_Noeud[3*i];
               else
            {
                if(Diag_Vor.Tab_Noeud[3*i]>X_Max)
                    X_Max=Diag_Vor.Tab_Noeud[3*i];
            }

            if(Diag_Vor.Tab_Noeud[3*i+1]<Y_Min)
                   Y_Min=Diag_Vor.Tab_Noeud[3*i+1];
            else
            {
                if(Diag_Vor.Tab_Noeud[3*i+1]>Y_Max)
                    Y_Max=Diag_Vor.Tab_Noeud[3*i+1];
            }

            if(Diag_Vor.Tab_Noeud[3*i+2]<Z_Min)
                Z_Min=Diag_Vor.Tab_Noeud[3*i+2];
               else
            {
                if(Diag_Vor.Tab_Noeud[3*i+2]>Z_Max)
                      Z_Max=Diag_Vor.Tab_Noeud[3*i+2];
            }
        }
    }
    
    X_Centre=(X_Min+X_Max)/2.;
    Y_Centre=(Y_Min+Y_Max)/2.;
    Z_Centre=(Z_Min+Z_Max)/2.;

    double Arete_X=X_Max-X_Min;
    double Arete_Y=Y_Max-Y_Min;
    double Arete_Z=Z_Max-Z_Min;

    if(Arete_X>Arete_Y)
        Arete=Arete_X;
    else
        Arete=Arete_Y;
    if(Arete<Arete_Z)
        Arete=Arete_Z;
    double R=(sqrt(3.)/2.)*Arete;
    double l=2.*sqrt(6.)*R;
    double h=4.*R;
    double b=l/(2.*sqrt(3.));
    double c=2.*b;

    double Racine_Cube_Nb_Noeud=pow((double)nb_noeud,1./3.);

    PRECISION_0=PRECISION*2*R/Racine_Cube_Nb_Noeud;              // Teste sphere 
    PRECISION_1=PRECISION_0;                                     // Teste dessente en gradiant
    PRECISION_2=PRECISION_0;                                     // Teste intersection tri face Voronoi
    PRECISION_3=PRECISION_0;                                     // Longeur min arete Voronoi
    PRECISION_4=PRECISION_3*PRECISION_3;                         // Aire min face Voronoi

    PRECISION_5=1.e-6;                                           // Teste d'angle

    PRECISION_6=0.;

    //-----------------------------------------------------------------------//

    //cout<<"\nData in------------------------------------------------------------------------\n"<<endl;

    //cout<<"Nombre noeud = "<<Diag_Vor.Nb_Noeud<<endl;
    //cout<<"Nombre triangle = "<<Nb_Tri_Front<<endl;
    //cout<<"x min = "<<X_Min<<" , x max = "<<X_Max<<" , dx = "<<Arete_X<<endl;
    //cout<<"y min = "<<Y_Min<<" , y max = "<<Y_Max<<" , dy = "<<Arete_Y<<endl;
    //cout<<"z min = "<<Z_Min<<" , z max = "<<Z_Max<<" , dz = "<<Arete_Z<<endl;

    //-----------------------------------------------------------------------//
}

//---------------------------------------------------------------------------//

C_Meshless_3d::~C_Meshless_3d()
{
    if(Tab_Ind_Noeud_Tri_Front!=NULL)free(Tab_Ind_Noeud_Tri_Front);
    if(Tab_Flag_Tri_Front!=NULL)free(Tab_Flag_Tri_Front);
}

//---------------------------------------------------------------------------//
