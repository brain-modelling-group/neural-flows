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

#include "C_Sommet.h"

//---------------------------------------------------------------------------//

C_Sommet::C_Sommet():Type(0),Sommet_Infinie(0),Valide(1),Ind_Group(-1),Ghost(0),Ind_Sommet_Out(-1){}

//---------------------------------------------------------------------------//

void C_Sommet::operator =(const C_Sommet Other)
{
    Type=Other.Type;
    My_Index=Other.My_Index;
    Sommet_Infinie=Other.Sommet_Infinie;
    long i;
    for(i=0;i<4;i++)
    {
        Ind_Noeud[i]=Other.Ind_Noeud[i];
        Ind_Sommet[i]=Other.Ind_Sommet[i];
        Ind_Arete[i]=Other.Ind_Arete[i];
    }

    for(i=0;i<3;i++)
    {
        Sommet[i]=Other.Sommet[i];
        Orthocentre[i]=Other.Orthocentre[i];
    }
    
    Rayon_Sphere=Other.Rayon_Sphere;
    Valide=Other.Valide;
    Ind_Group=Other.Ind_Group;
}

//---------------------------------------------------------------------------//

long C_Sommet::Face_qui_ne_contient_pas_le_Noeud(long Index)
{
    long i;
    for(i=0;i<4;i++)
    {
        if(Ind_Noeud[i]==Index)
            return (i+1)%4;
    }
    return -1;
}

//---------------------------------------------------------------------------//

void C_Sommet::Face_G_D_B_H(long* Ind_Noeud_B_H,long* Ind_Face_B_H_G_D,long* Ind_Noeud_G_D)
{
    Ind_Noeud_G_D[0]=-1;
    Ind_Noeud_G_D[1]=-1;

    long i;
    for(i=0;i<4;i++)
        Ind_Face_B_H_G_D[i]=-1;

    for(i=0;i<4;i++)
    {
        long Ind_Noeud_Face[3];
        Ind_Noeud_Face[0]=Ind_Noeud[i];
        if(i%2)
        {
            Ind_Noeud_Face[1]=Ind_Noeud[(i+2)%4];
            Ind_Noeud_Face[2]=Ind_Noeud[(i+1)%4];
        }
        else
        {
            Ind_Noeud_Face[1]=Ind_Noeud[(i+1)%4];
            Ind_Noeud_Face[2]=Ind_Noeud[(i+2)%4];
        }

        long j;
        for(j=0;j<3;j++)
        {
            if(Ind_Noeud_Face[j]==Ind_Noeud_B_H[0])
            {
                if(Ind_Noeud_Face[(j+1)%3]==Ind_Noeud_B_H[1])
                {
                    Ind_Noeud_G_D[1]=Ind_Noeud_Face[(j+2)%3];
                    Ind_Face_B_H_G_D[3]=i;
                }
                else
                {
                    if(Ind_Noeud_Face[(j+2)%3]==Ind_Noeud_B_H[1])
                    {
                        Ind_Noeud_G_D[0]=Ind_Noeud_Face[(j+1)%3];
                        Ind_Face_B_H_G_D[2]=i;
                    }
                    else
                        Ind_Face_B_H_G_D[0]=i;
                }
                break;
            }
            if(j==2)
                Ind_Face_B_H_G_D[1]=i;
        }
    }
}

//---------------------------------------------------------------------------//

void C_Sommet::Face_qui_Contient_les_2_Noeud
(long Ind_Noeud_B,long Ind_Noeud_H,long* Ind_Noeud_GD,long* Ind_Sommet_GD)
{
    bool b_0=0;
    bool b_1=0;

    for(int i=0;i<4;i++)
    {
        long Ind_Noeud_Face[3];
        Ind_Noeud_Face[0]=Ind_Noeud[i];
        if(i%2)
        {
            Ind_Noeud_Face[1]=Ind_Noeud[(i+2)%4];
            Ind_Noeud_Face[2]=Ind_Noeud[(i+1)%4];
        }
        else
        {
            Ind_Noeud_Face[1]=Ind_Noeud[(i+1)%4];
            Ind_Noeud_Face[2]=Ind_Noeud[(i+2)%4];
        }

        for(int j=0;j<3;j++)
        {
            if(Ind_Noeud_Face[j]==Ind_Noeud_B)
            {
                if(Ind_Noeud_Face[(j+1)%3]==Ind_Noeud_H)
                {
                    b_1=1;
                    Ind_Noeud_GD[1]=Ind_Noeud_Face[(j+2)%3];
                    Ind_Sommet_GD[1]=Ind_Sommet[i];
                }
                else
                {
                    if(Ind_Noeud_Face[(j+2)%3]==Ind_Noeud_H)
                    {
                        b_0=1;
                        Ind_Noeud_GD[0]=Ind_Noeud_Face[(j+1)%3];
                        Ind_Sommet_GD[0]=Ind_Sommet[i];
                    }
                }

                break;
            }
        }

        if(b_0 && b_1)
            break;
    }
}

//---------------------------------------------------------------------------//

long C_Sommet::Ind_Noeud_Externe_a_Face(C_Sommet* P_Sommet,long Ind_Face)
{
    long i;
    for(i=0;i<4;i++)
    {
        bool b=1;
        long j;
        for(j=0;j<3;j++)
        {
            if(Ind_Noeud[i]==P_Sommet->Ind_Noeud[(Ind_Face+j)%4])
            {
                b=0;
                break;
            }
        }
        if(b)
            break;
    }

    return i;
}
