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
// Utilitaire

#include "C_Meshless_3d.h"

//---------------------------------------------------------------------------//

void C_Meshless_3d::Calcul_Barycentre_Face(S_Face_V* P_Face,double* Barycentre)
{
    double Aire_Face=0.;
    vector<double*> List_Coord_Sommet_Face;
    Diag_Vor.Trouve_Coord_Sommet_Face(P_Face,&List_Coord_Sommet_Face);
    long Nb_Sommet_Face=List_Coord_Sommet_Face.size();
    C_Vec3d S0Si(List_Coord_Sommet_Face[0],List_Coord_Sommet_Face[1]);
    long i;
    for(i=1;i<Nb_Sommet_Face-1;i++)
    {
        C_Vec3d S0Sip1(List_Coord_Sommet_Face[0],List_Coord_Sommet_Face[i+1]);
        double Barycentre_Tri_S0SiSip1x3[3]={List_Coord_Sommet_Face[0][0],List_Coord_Sommet_Face[0][1],List_Coord_Sommet_Face[0][2]};
        long j=0;
        for(j=0;j<2;j++)
        {
            long k;
            for(k=0;k<3;k++)
                Barycentre_Tri_S0SiSip1x3[k]+=List_Coord_Sommet_Face[i+j][k];
        }

        double Aire_Tri_S0SiSip1=(P_Face->Normale.Normalized())*(S0Si^S0Sip1)/2.;

        for(j=0;j<3;j++)
            Barycentre[j]+=Barycentre_Tri_S0SiSip1x3[j]*Aire_Tri_S0SiSip1/3.;
    
        S0Si=S0Sip1;
        Aire_Face+=Aire_Tri_S0SiSip1;
    }

    for(i=0;i<3;i++)
        Barycentre[i]/=Aire_Face;
}

//---------------------------------------------------------------------------//

void C_Meshless_3d::Calcul_Aire_Face(S_Face_V* P_Face)
{
    vector<double*> List_Pnt_Face;
    
    if(P_Face->Type<2)
    {
        C_Vec3d Normale_Face=P_Face->Normale.Normalized();
        
        if(P_Face->Fermee)
        {
            Diag_Vor.Trouve_Coord_Sommet_Face(P_Face,&List_Pnt_Face);
            P_Face->Aire=Calcul_Aire_Polygon(&List_Pnt_Face,&Normale_Face);
        }
        else
        {
            
            /*C_Vec3d Dir_Inf[2];
            Diag_Vor.Trouve_Coord_Sommet_Face(P_Face,&List_Pnt_Face,Dir_Inf);
            double* Sommet_FB[2]={List_Pnt_Face.front(),List_Pnt_Face.back()};
            double Pnt_sur_Arete_Infinie[2][3]={
                {Sommet_FB[0][0]+Dir_Inf[0][0],Sommet_FB[0][1]+Dir_Inf[0][1],Sommet_FB[0][2]+Dir_Inf[0][2]},
                {Sommet_FB[1][0]+Dir_Inf[1][0],Sommet_FB[1][1]+Dir_Inf[1][1],Sommet_FB[1][2]+Dir_Inf[1][2]}};
            List_Pnt_Face.push_back(Pnt_sur_Arete_Infinie[1],Pnt_sur_Arete_Infinie[0]);
            P_Face->Aire=Calcul_Aire_Polygon(&List_Pnt_Face,&Normale_Face);*/
        }
    }
    else
    {
        Diag_Vor.Trouve_Coord_Sommet_Face(P_Face,&List_Pnt_Face);
        P_Face->Aire=Calcul_Aire_Polygon(&List_Pnt_Face,&List_Tri_Front[P_Face->Ind_Noeud[1]].Normale);
    }
}

//---------------------------------------------------------------------------//

bool C_Meshless_3d::Calcul_Sphere_4_Point(double** P,double& Rayon)
{
    double M[3][3];
    double V[3];
    long i;
    for(i=0;i<3;i++)
    {
        C_Vec3d Normale=C_Vec3d(P[i],P[i+1]);
        C_Vec3d Oo((P[i][0]+P[i+1][0])/2.,
                   (P[i][1]+P[i+1][1])/2.,
                   (P[i][2]+P[i+1][2])/2.);
        
        M[i][0]=Normale.X();
        M[i][1]=Normale.Y();
        M[i][2]=Normale.Z();
        
        V[i]=Normale*Oo;
    }

    double delta[4];

    delta[3]=M[0][0]*(M[1][1]*M[2][2]-M[1][2]*M[2][1])-
             M[0][1]*(M[1][0]*M[2][2]-M[1][2]*M[2][0])+
             M[0][2]*(M[1][0]*M[2][1]-M[1][1]*M[2][0]);

    //if(fabs(delta[3])<) return 0;

    for(i=0;i<3;i++)
    {
        double N[3][3];
        long j;
        for(j=0;j<3;j++)
        {
            if(j==i)
            {
                for(long k=0;k<3;k++)
                    N[k][j]=V[k];

            }
            else
            {
                for(long k=0;k<3;k++)
                    N[k][j]=M[k][j];
            }
        }

        delta[i]=N[0][0]*(N[1][1]*N[2][2]-N[1][2]*N[2][1])-
                 N[0][1]*(N[1][0]*N[2][2]-N[1][2]*N[2][0])+
                 N[0][2]*(N[1][0]*N[2][1]-N[1][1]*N[2][0]);
    }

    P[4][0]=delta[0]/delta[3];
    P[4][1]=delta[1]/delta[3];
    P[4][2]=delta[2]/delta[3];

    Rayon=C_Vec3d(P[4],P[0]).Magnitude();

    // juste pour verifier!!!------------------------------------------------//
    /*double D1=C_Vec3d(P[4],P[1]).Magnitude();
    double D2=C_Vec3d(P[4],P[2]).Magnitude();
    double D3=C_Vec3d(P[4],P[3]).Magnitude();*/
    //-----------------------------------------------------------------------//

    return 1;
}

//---------------------------------------------------------------------------//

double C_Meshless_3d::Calcul_Aire_Polygon(vector<double*>* P_List_Pnt_Face,C_Vec3d* P_Normale_Face)
{
    double Aire=0.;
    
    C_Vec3d P0_PA(P_List_Pnt_Face->at(0),P_List_Pnt_Face->at(1));

    long Nb_Pnt=P_List_Pnt_Face->size();
    long i;
    for(i=2;i<Nb_Pnt;i++)
    {

        C_Vec3d P0_PB(P_List_Pnt_Face->at(0),P_List_Pnt_Face->at(i));
        
        Aire+=P_Normale_Face->Dot(P0_PA^P0_PB);
    
        P0_PA=P0_PB;
    }

    return (Aire/2.);
}

//---------------------------------------------------------------------------//
