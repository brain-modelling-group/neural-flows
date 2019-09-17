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

#include "C_Meshless_2d.h"

C_Meshless_2d::C_Meshless_2d
(long Nb_Noeud,double* P_XY_Noeud,long Nb_Front,size_t* P_Nb_Noeud_Front,size_t* P_Ind_Noeud_Front)
{
    long i;
    for(i=0;i<Nb_Noeud;i++)
    {
        double X=P_XY_Noeud[2*i];double Y=P_XY_Noeud[2*i+1];
        C_Pnt2d Point(X,Y);List_Noeud.push_back(Point);
        if(!i){X_Min=X;X_Max=X;Y_Min=Y;Y_Max=Y;}
        else{if(X<X_Min)X_Min=X;else{if(X>X_Max)X_Max=X;}
             if(Y<Y_Min)Y_Min=Y;else{if(Y>Y_Max)Y_Max=Y;}}
    }

    long k=0;
    for(i=0;i<Nb_Front;i++)
    {
        List_P_Frontiere.push_back(new vector<long>);
        long j;
        for(j=0;j<P_Nb_Noeud_Front[i];j++)
        {
            List_P_Frontiere[i]->push_back(P_Ind_Noeud_Front[k]);
            k++;
        }
    }
 
    PRECISION_0=1.e-10*((X_Max-X_Min)+(Y_Max-Y_Min))/2.;//DG 5.0082881118304249e-010;//
    PRECISION_1=PRECISION_0/2.;//TS
}

//===========================================================================//

C_Meshless_2d::~C_Meshless_2d()
{
    long Nb_Frontiere=List_P_Frontiere.size();
    long i;
    for(i=0;i<Nb_Frontiere;i++)
        delete List_P_Frontiere[i];

    long Nb_Cellule=List_Cellule.size();
    for(i=0;i<Nb_Cellule;i++)
        delete List_Cellule[i].P_List_Arete;
    
    long Nb_Cellule_Frontiere=List_S_Cel_Front.size();
    for(i=0;i<Nb_Cellule_Frontiere;i++)
        delete List_S_Cel_Front[i].P_List_SSCF;
}

//===========================================================================//

void C_Meshless_2d::Permutation_Circulaire_Sommet(long Ind_Sommet,bool Z)
{
    S_Sommet& Ref_Sommet=List_Sommet[Ind_Sommet];

    long Ind_Temp;
    if(Z)
    {
        Ind_Temp=Ref_Sommet.Ind_Sommet[2];
        Ref_Sommet.Ind_Sommet[2]=Ref_Sommet.Ind_Sommet[1];
        Ref_Sommet.Ind_Sommet[1]=Ref_Sommet.Ind_Sommet[0];
        Ref_Sommet.Ind_Sommet[0]=Ind_Temp;
        
        Ind_Temp=Ref_Sommet.Ind_Noeud[2];
        Ref_Sommet.Ind_Noeud[2]=Ref_Sommet.Ind_Noeud[1];
        Ref_Sommet.Ind_Noeud[1]=Ref_Sommet.Ind_Noeud[0];
        Ref_Sommet.Ind_Noeud[0]=Ind_Temp;
    }
    else
    {
        Ind_Temp=Ref_Sommet.Ind_Sommet[0];
        Ref_Sommet.Ind_Sommet[0]=Ref_Sommet.Ind_Sommet[1];
        Ref_Sommet.Ind_Sommet[1]=Ref_Sommet.Ind_Sommet[2];
        Ref_Sommet.Ind_Sommet[2]=Ind_Temp;
        
        Ind_Temp=Ref_Sommet.Ind_Noeud[0];
        Ref_Sommet.Ind_Noeud[0]=Ref_Sommet.Ind_Noeud[1];
        Ref_Sommet.Ind_Noeud[1]=Ref_Sommet.Ind_Noeud[2];
        Ref_Sommet.Ind_Noeud[2]=Ind_Temp;
    }
}

//===========================================================================//

void C_Meshless_2d::Initialisation_Diagramme_Voronoi()
{
    double X_Centre=(X_Min+X_Max)/2.;
    double Y_Centre=(Y_Min+Y_Max)/2.;
    double Arete;
    double Arete_X=X_Max-X_Min;
    double Arete_Y=Y_Max-Y_Min;
    if(Arete_X>Arete_Y)
        Arete=Arete_X;
    else
        Arete=Arete_Y;

	double Coef=2.;
    double a=Coef*Arete/sqrt(2.);
    double b=a*sqrt(3.)/2.;
    
    C_Pnt2d Coor_Sommet_Ini(X_Centre,Y_Centre); 
    C_Pnt2d Noeud0(X_Centre+b,Y_Centre-a/2.);
    C_Pnt2d Noeud1(X_Centre,Y_Centre+a);
    C_Pnt2d Noeud2(X_Centre-b,Y_Centre-a/2.);
    
    long Ind_N0=List_Noeud.size();
    long Ind_N1=Ind_N0+1;
    long Ind_N2=Ind_N0+2;

    List_Noeud.push_back(Noeud0);
    List_Noeud.push_back(Noeud1);
    List_Noeud.push_back(Noeud2);

    long Ind_Sommet_Inf0=Ajout_Nouveau_Sommet(Ind_N2,-1,Ind_N0,-1,-1,-1);
    long Ind_Sommet_Inf1=Ajout_Nouveau_Sommet(Ind_N0,-1,Ind_N1,-1,-1,-1);
    long Ind_Sommet_Inf2=Ajout_Nouveau_Sommet(Ind_N1,-1,Ind_N2,-1,-1,-1);

    long Ind_Sommet_Ini=Ajout_Nouveau_Sommet(Coor_Sommet_Ini,a,Ind_N0,Ind_N1,Ind_N2,Ind_Sommet_Inf0,Ind_Sommet_Inf1,Ind_Sommet_Inf2);
    
    List_Sommet[Ind_Sommet_Inf0].Ind_Sommet[0]=Ind_Sommet_Ini;
    List_Sommet[Ind_Sommet_Inf1].Ind_Sommet[0]=Ind_Sommet_Ini;
    List_Sommet[Ind_Sommet_Inf2].Ind_Sommet[0]=Ind_Sommet_Ini;
}

//===========================================================================//

void C_Meshless_2d::Voronoi_Non_Contrain()
{
    Initialisation_Diagramme_Voronoi();
    
    long Nb_Noeud=List_Noeud.size()-3;
    
	long* Vec_Noeud_bord=(long*)calloc(Nb_Noeud,sizeof(long));
    
	long i;
	for(i=0;i<List_P_Frontiere.size();i++)
	{
		long j;
		for(j=0;j<List_P_Frontiere[i]->size();j++)Vec_Noeud_bord[List_P_Frontiere[i]->at(j)]=1;
	}
    
    for(i=0;i<Nb_Noeud;i++)
    {
        if(Vec_Noeud_bord[i])
        {
			bool b=1;
			long Ind_Pr_S_a_Suprimer=Descente_Gradiant(-1,List_Noeud[i]);
			if(Ind_Pr_S_a_Suprimer>=0){if(Calcul_Nouvelle_Cellule(i,List_Noeud[i],Ind_Pr_S_a_Suprimer)==0)b=0;}
			if(b)exit(1);
        }
    }

    for(i=0;i<Nb_Noeud;i++)
    {
        if(!Vec_Noeud_bord[i])
        {
            long Ind_Pr_S_a_Suprimer=Descente_Gradiant(-1,List_Noeud[i]);
            if(Ind_Pr_S_a_Suprimer>0)Calcul_Nouvelle_Cellule(i,List_Noeud[i],Ind_Pr_S_a_Suprimer);
        }
    }

	free(Vec_Noeud_bord);

	Dispatch_Sommet();
}

//===========================================================================//

long C_Meshless_2d::Descente_Gradiant(long Ind_Sommet_Temp,C_Pnt2d Noeud_a_Inserer)
{
    S_Sommet Sommet_Temp;
    if(Ind_Sommet_Temp==-1)
    {
        //map<const long,S_Sommet>::iterator i;
        Ind_Sommet_Temp=0;
		vector<S_Sommet>::iterator i;
        for(i=List_Sommet.begin();i!=List_Sommet.end();i++)
        {
            //pair<const long,S_Sommet> Paire=(*i);
            S_Sommet S_i=(*i);
			//if(!Paire.second.Sommet_Infini)
			if(S_i.Valide&&(!S_i.Sommet_Infini))
            {
                //Ind_Sommet_Temp=Paire.first;
				//Sommet_Temp=Paire.second;
				Sommet_Temp=S_i;
                break;
            }
			Ind_Sommet_Temp++;
        } 
    }
    else
        Sommet_Temp=List_Sommet[Ind_Sommet_Temp];
    do
    {
        long Index=-1;
        double PrV_Max=0.;
		bool b=1;
        
        long i;
        for(i=0;i<3;i++)
        {
            C_Vec2d N_Tri_N_a_Inserer=C_Vec2d(List_Noeud[Sommet_Temp.Ind_Noeud[i]],Noeud_a_Inserer);
            double Dist_N_Tri_N_a_Inserer=N_Tri_N_a_Inserer.Magnitude();

            if(Dist_N_Tri_N_a_Inserer<PRECISION_0)return -2;

            C_Vec2d Arete_Tri=C_Vec2d(List_Noeud[Sommet_Temp.Ind_Noeud[i]],
                                      List_Noeud[Sommet_Temp.Ind_Noeud[(i+1)%3]]).Normalized();
        
            double PrV=N_Tri_N_a_Inserer^Arete_Tri;

            if(PrV>PRECISION_0)b=0; 
            
			PrV/=Dist_N_Tri_N_a_Inserer;
            if((PrV>PrV_Max)||(i==0))
            {
                PrV_Max=PrV;
                Index=i;
            }
        }

        if(b)
		{
			if(Noeud_a_Inserer.Distance(Sommet_Temp.Coord_Sommet)<Sommet_Temp.Rayon_Cercle)
				break;
		}

        Ind_Sommet_Temp=Sommet_Temp.Ind_Sommet[(Index+1)%3];
        Sommet_Temp=List_Sommet[Ind_Sommet_Temp];

    }while(1);
    
    return Ind_Sommet_Temp;
}

//===========================================================================//

long C_Meshless_2d::Recherche_Premeier_Sommet_a_Suprimer_dans_Cellule
(C_Pnt2d Noeud_a_Inserer,C_Pnt2d Noeud_Cellule,C_Cellule Cellule)
{
    long Ind_Pr_S_a_Suprimer=-1;
    
    C_Vec2d NC_NaI(Noeud_Cellule,Noeud_a_Inserer);
        
    list<S_Arete>::iterator i_Ini=Cellule.P_List_Arete->begin();
    
    S_Arete Arete_Temp;

    if(Cellule.Fermee)
        Arete_Temp=Cellule.P_List_Arete->back();
    else
    {
        Arete_Temp=(*i_Ini);
        i_Ini++;
    }
        
    C_Vec2d NC_NV0=C_Vec2d(Noeud_Cellule,List_Noeud[Arete_Temp.Ind_Noeud]).Normalized();

    list<S_Arete>::iterator i;
    for(i=i_Ini;i!=Cellule.P_List_Arete->end();i++)
    {
        Arete_Temp=(*i);
        C_Vec2d NC_NV1=C_Vec2d(Noeud_Cellule,List_Noeud[Arete_Temp.Ind_Noeud]).Normalized();

        if(((NC_NV0^NC_NaI)>=-PRECISION_0)&&((NC_NV1^NC_NaI)<=PRECISION_0))
        {
            Ind_Pr_S_a_Suprimer=Arete_Temp.Ind_Sommet[0];
            break;
        }
        
        NC_NV0=NC_NV1;
    }
    return Ind_Pr_S_a_Suprimer;
}

//===========================================================================//

long C_Meshless_2d::Calcul_Nouvelle_Cellule
(long Ind_Noeud_a_Inserer,C_Pnt2d Noeud_a_Inserer,long Ind_Pr_S_a_Suprimer,
 vector<S_Sommet_Restrain>* P_List_Nouveau_Sommet) 
{
    vector<long> List_Ind_Sommet_a_Suprimer;
    vector<S_Sommet_Cavite> List_Sommet_Cavite_Temp;
	Set_Arete Set_Arete_Cavite;
    vector<S_Sommet_Cavite> List_Sommet_Cavite;
       
    //------------------------------------------------------------------------------------//
    
    List_Ind_Sommet_a_Suprimer.push_back(Ind_Pr_S_a_Suprimer);

    long i;
    for(i=0;i<3;i++)
    {
        S_Sommet_Cavite S_C_Temp;
        S_C_Temp.Ind_Sommet=List_Sommet[Ind_Pr_S_a_Suprimer].Ind_Sommet[i];

        long j;
        for(j=0;j<3;j++)
        {
            if(List_Sommet[S_C_Temp.Ind_Sommet].Ind_Noeud[j]==List_Sommet[Ind_Pr_S_a_Suprimer].Ind_Noeud[(i+2)%3])
            {
                S_C_Temp.Index=j;
                break;
            }
        }
        List_Sommet_Cavite_Temp.push_back(S_C_Temp);

		Set_Arete_Cavite.insert(make_pair(List_Sommet[S_C_Temp.Ind_Sommet].Ind_Noeud[j],List_Sommet[S_C_Temp.Ind_Sommet].Ind_Noeud[(j+2)%3]));
    }
    
    //-----------------------------------------------------------------------//
    
    while(!List_Sommet_Cavite_Temp.empty())
    {
        S_Sommet_Cavite S_C_Temp_0=List_Sommet_Cavite_Temp.back();
        List_Sommet_Cavite_Temp.pop_back();
        
        if(List_Sommet[S_C_Temp_0.Ind_Sommet].Sommet_Infini)
            List_Sommet_Cavite.push_back(S_C_Temp_0);
        else
        {
			if((Noeud_a_Inserer.Distance(List_Sommet[S_C_Temp_0.Ind_Sommet].Coord_Sommet)-List_Sommet[S_C_Temp_0.Ind_Sommet].Rayon_Cercle)<0.)//PRECISION_1)
            {
                List_Ind_Sommet_a_Suprimer.push_back(S_C_Temp_0.Ind_Sommet);
                
                i=S_C_Temp_0.Index;
                long j;
                for(j=1;j<3;j++)
                {
                    S_Sommet_Cavite S_C_Temp_1;
                    S_C_Temp_1.Ind_Sommet=List_Sommet[S_C_Temp_0.Ind_Sommet].Ind_Sommet[(i+j)%3];
                        
                    long k;
                    for(k=0;k<3;k++)
                    {
                        if(List_Sommet[S_C_Temp_1.Ind_Sommet].Ind_Noeud[k]==List_Sommet[S_C_Temp_0.Ind_Sommet].Ind_Noeud[(i+j+2)%3])
                        {
                            S_C_Temp_1.Index=k;
                             break;
                        }
                    }
                    
                    List_Sommet_Cavite_Temp.push_back(S_C_Temp_1);

					if(Set_Arete_Cavite.find(make_pair(List_Sommet[S_C_Temp_1.Ind_Sommet].Ind_Noeud[(k+2)%3],List_Sommet[S_C_Temp_1.Ind_Sommet].Ind_Noeud[k]))==Set_Arete_Cavite.end())
						Set_Arete_Cavite.insert(make_pair(List_Sommet[S_C_Temp_1.Ind_Sommet].Ind_Noeud[k],List_Sommet[S_C_Temp_1.Ind_Sommet].Ind_Noeud[(k+2)%3]));
					else return 1;
                }
            }
            else
                List_Sommet_Cavite.push_back(S_C_Temp_0);
        }
    }
    
    //-----------------------------------------------------------------------//

    if(Ind_Noeud_a_Inserer+1)
    {
        for(i=0;i<List_Ind_Sommet_a_Suprimer.size();i++)
		{
			long Ind_SS_i=List_Ind_Sommet_a_Suprimer[i];
			List_Sommet[Ind_SS_i].Valide=0;
            Retire_Sommet(Ind_SS_i);
		}

        //-------------------------------------------------------------------//
    
        vector<long> List_Ind_Nouveau_Sommet;

        while(!List_Sommet_Cavite.empty())
        {
            S_Sommet_Cavite S_C_Temp=List_Sommet_Cavite.back();
            List_Sommet_Cavite.pop_back();
        
            double Rayon;
            C_Pnt2d Centre;
            Calcul_Cercle(List_Noeud[List_Sommet[S_C_Temp.Ind_Sommet].Ind_Noeud[S_C_Temp.Index]],
                          List_Noeud[List_Sommet[S_C_Temp.Ind_Sommet].Ind_Noeud[(S_C_Temp.Index+2)%3]],
                          Noeud_a_Inserer,
                          Centre,Rayon);
    
            
            long Ind_Nouveau_Sommet=Ajout_Nouveau_Sommet(Centre,Rayon,
                List_Sommet[S_C_Temp.Ind_Sommet].Ind_Noeud[(S_C_Temp.Index+2)%3],
                Ind_Noeud_a_Inserer,
                List_Sommet[S_C_Temp.Ind_Sommet].Ind_Noeud[S_C_Temp.Index],
                S_C_Temp.Ind_Sommet,
                -1,-1);
            
            List_Ind_Nouveau_Sommet.push_back(Ind_Nouveau_Sommet);
            List_Sommet[S_C_Temp.Ind_Sommet].Ind_Sommet[S_C_Temp.Index]=Ind_Nouveau_Sommet;
        }

        //-------------------------------------------------------------------//
    
        long Nb_N_S=List_Ind_Nouveau_Sommet.size();
        for(i=0;i<Nb_N_S;i++)
        {
            List_Sommet[List_Ind_Nouveau_Sommet[i]].Ind_Sommet[1]=List_Ind_Nouveau_Sommet[(i+1)%Nb_N_S];
             List_Sommet[List_Ind_Nouveau_Sommet[i]].Ind_Sommet[2]=List_Ind_Nouveau_Sommet[(i-1+Nb_N_S)%Nb_N_S];
        }
    
        //-------------------------------------------------------------------//
    }
    else
    {
        while(!List_Sommet_Cavite.empty())
        {
            S_Sommet_Cavite S_C_Temp=List_Sommet_Cavite.back();
            List_Sommet_Cavite.pop_back();

            S_Sommet_Restrain Nouveau_Sommet;
            Nouveau_Sommet.Ind_Noeud=List_Sommet[S_C_Temp.Ind_Sommet].Ind_Noeud[(S_C_Temp.Index+2)%3];
            Nouveau_Sommet.Ind_Sommet_Externe=S_C_Temp.Ind_Sommet;
            
            Calcul_Cercle(List_Noeud[List_Sommet[S_C_Temp.Ind_Sommet].Ind_Noeud[S_C_Temp.Index]],
                          List_Noeud[List_Sommet[S_C_Temp.Ind_Sommet].Ind_Noeud[(S_C_Temp.Index+2)%3]],
                          Noeud_a_Inserer,
                          Nouveau_Sommet.Coord_Sommet,
                          Nouveau_Sommet.Rayon_Sphere);

            P_List_Nouveau_Sommet->push_back(Nouveau_Sommet);
        }
    }

	return 0;
}

//===========================================================================//

long C_Meshless_2d::Descente_Gradiant(long Ind_Sommet_Temp,C_Pnt2d Noeud_a_Inserer,long& Pnt_sur_Arete_Noeud)
{
    S_Sommet Sommet_Temp;
    if(Ind_Sommet_Temp==-1)
    {
        //map<const long,S_Sommet>::iterator i;
        Ind_Sommet_Temp=0;
		vector<S_Sommet>::iterator i;
        for(i=List_Sommet.begin();i!=List_Sommet.end();i++)
        {
            //pair<const long,S_Sommet> Paire=(*i);
            S_Sommet S_i=(*i);
			//if(!Paire.second.Sommet_Infini)
			if(S_i.Valide&&(!S_i.Sommet_Infini))
            {
                //Ind_Sommet_Temp=Paire.first;
				//Sommet_Temp=Paire.second;
				Sommet_Temp=S_i;
                break;
            }
			Ind_Sommet_Temp++;
        } 
    }
    else
        Sommet_Temp=List_Sommet[Ind_Sommet_Temp];

    do
    {
        long Index=-1;
        double PrV_Max=0.;
        Pnt_sur_Arete_Noeud=0;

        long i;
        for(i=0;i<3;i++)
        {
            C_Vec2d N_Tri_N_a_Inserer=C_Vec2d(List_Noeud[Sommet_Temp.Ind_Noeud[i]],Noeud_a_Inserer);
            double Dist_N_Tri_N_a_Inserer=N_Tri_N_a_Inserer.Magnitude();

            if(Dist_N_Tri_N_a_Inserer<PRECISION_0)
            {
                Pnt_sur_Arete_Noeud=-(Sommet_Temp.Ind_Noeud[i]+1);
                return Ind_Sommet_Temp;
            }

            C_Vec2d Arete_Tri=C_Vec2d(List_Noeud[Sommet_Temp.Ind_Noeud[i]],
                                      List_Noeud[Sommet_Temp.Ind_Noeud[(i+1)%3]]).Normalized();
        
            double PrV=N_Tri_N_a_Inserer^Arete_Tri;

            if(PrV>PRECISION_0) 
            {
                PrV/=Dist_N_Tri_N_a_Inserer;

                if(PrV>PrV_Max)
                {
                    PrV_Max=PrV;
                     Index=i;
                }
            }
            else
            {
                if(PrV>-PRECISION_0)
                    Pnt_sur_Arete_Noeud=i+1;
            }
        }

        if(Index+1)
        {
            Ind_Sommet_Temp=Sommet_Temp.Ind_Sommet[(Index+1)%3];
            Sommet_Temp=List_Sommet[Ind_Sommet_Temp];
            if(Sommet_Temp.Sommet_Infini)break;
        }
        else break;

    }while(1);

    if(Pnt_sur_Arete_Noeud!=0)
    {
        if(!List_Sommet[Sommet_Temp.Ind_Sommet[(Pnt_sur_Arete_Noeud-1+1)%3]].Sommet_Infini)
            Pnt_sur_Arete_Noeud=0;
    }

    return Ind_Sommet_Temp;
}

//===========================================================================//

void C_Meshless_2d::Recherche_Premeier_Sommet_a_Suprimer_Tache_d_Huile
(C_Pnt2d Noeud_a_Inserer,long Ind_Sommet_Depart,long& Ind_Pr_S_a_Suprimer,long& Pnt_sur_Arete)
{
    Ind_Pr_S_a_Suprimer=-1;

    vector<long> Vec[2];
    vector<long>* Tache_d_Huile[2];
    Tache_d_Huile[0]=&Vec[0];
    Tache_d_Huile[1]=&Vec[1];

    Tache_d_Huile[1]->push_back(Ind_Sommet_Depart);

    //vector<bool> Triangle_Visite((pair<long,S_Sommet>(*(--List_Sommet.end()))).first+1,0);
	vector<bool> Triangle_Visite(List_Sommet.size(),0);
    Triangle_Visite[Ind_Sommet_Depart]=1;

    do
    {
        vector<long>::iterator i;
        for(i=Tache_d_Huile[1]->begin();i!=Tache_d_Huile[1]->end();i++)
        {
            Pnt_sur_Arete=-1;

            long Ind_Sommet_i=*i;

            S_Sommet Sommet_i=List_Sommet[Ind_Sommet_i];

            bool b=1;
            long j;
            for(j=0;j<3;j++)
            {
                C_Vec2d N_Tri_N_a_Inserer=C_Vec2d(List_Noeud[Sommet_i.Ind_Noeud[j]],Noeud_a_Inserer);
                 C_Vec2d Arete_Tri=C_Vec2d(List_Noeud[Sommet_i.Ind_Noeud[j]],
                                          List_Noeud[Sommet_i.Ind_Noeud[(j+1)%3]]).Normalized();
        
                double PrV=N_Tri_N_a_Inserer^Arete_Tri;

                if(PrV>PRECISION_0) 
                {
                    b=0;
                    break;
                }
                else
                {
                    if(PrV>-PRECISION_0)
                        Pnt_sur_Arete=j;
                }
            }

            if(b)
            {
                Ind_Pr_S_a_Suprimer=Ind_Sommet_i;
                break;
            }
        }

        if(Ind_Pr_S_a_Suprimer+1)
            break;
        else
        {
            for(i=Tache_d_Huile[1]->begin();i!=Tache_d_Huile[1]->end();i++)
            {
                long Ind_Sommet_i=*i;
                S_Sommet Sommet_i=List_Sommet[Ind_Sommet_i];

                long j;
                for(j=0;j<3;j++)
                {
                    long Sommet_ij=Sommet_i.Ind_Sommet[j];
                    if(!List_Sommet[Sommet_ij].Sommet_Infini)
                    {
                        if(!Triangle_Visite[Sommet_ij])
                        {
                           Tache_d_Huile[0]->push_back(Sommet_ij);
                           Triangle_Visite[Sommet_ij]=1;
                        }
                    }
                }
            }

            vector<long>* P_Vector_Temp;
            P_Vector_Temp=Tache_d_Huile[1];
            Tache_d_Huile[1]=Tache_d_Huile[0];
            Tache_d_Huile[0]=P_Vector_Temp;
            Tache_d_Huile[0]->clear();
        }

        if(Tache_d_Huile[1]->empty())
            break;
    }while(1);
}

//===========================================================================//

double _Calcul_Cercle(C_Pnt2d P1,C_Pnt2d P2,C_Pnt2d P3,C_Pnt2d& Centre,double& Rayon)
{
	C_Vec2d P1P2(P1,P2);
	C_Vec2d P2P3(P2,P3);

	C_Pnt2d A((P1.X()+P2.X())/2.,(P1.Y()+P2.Y())/2.);
	C_Pnt2d B((P2.X()+P3.X())/2.,(P2.Y()+P3.Y())/2.);

	C_Vec2d BA(B,A);
	C_Vec2d NP1P2(-P1P2.Y(),P1P2.X());
	NP1P2.Normalize();

	double Landa=-(P2P3*BA)/(P2P3*NP1P2);
    
	Centre.SetCoord(A.X()+Landa*NP1P2.X(),A.Y()+Landa*NP1P2.Y());

	double Rayon_1=P1.Distance(Centre);
	double Rayon_2=P2.Distance(Centre);
	double Rayon_3=P3.Distance(Centre);

	Rayon=(Rayon_1+Rayon_2+Rayon_3)/3;

	return (fabs(Rayon-Rayon_1)+fabs(Rayon-Rayon_2)+fabs(Rayon-Rayon_3))/3.;
}

void C_Meshless_2d::Calcul_Cercle(C_Pnt2d P1,C_Pnt2d P2,C_Pnt2d P3,C_Pnt2d& Centre,double& Rayon)
{
	C_Pnt2d Centre_0;
	double Rayon_0;
	double Err_0=_Calcul_Cercle(P1,P2,P3,Centre_0,Rayon_0);

	C_Pnt2d Centre_1;
	double Rayon_1;
	double Err_1=_Calcul_Cercle(P2,P3,P1,Centre_1,Rayon_1);

	C_Pnt2d Centre_2;
	double Rayon_2;
	double Err_2=_Calcul_Cercle(P3,P1,P2,Centre_2,Rayon_2);

	if(Err_0<Err_1)
	{
		if(Err_0<Err_2){Centre.SetCoord(Centre_0.X(),Centre_0.Y());Rayon=Rayon_0;}
		else{Centre.SetCoord(Centre_2.X(),Centre_2.Y());Rayon=Rayon_2;}
	}
	else
	{
		if(Err_1<Err_2){Centre.SetCoord(Centre_1.X(),Centre_1.Y());Rayon=Rayon_1;}
		else{Centre.SetCoord(Centre_2.X(),Centre_2.Y());Rayon=Rayon_2;}
	}
}

//===========================================================================//

double C_Meshless_2d::Fonction_de_Forme_et_Gradiant_de_Fonction_de_Forme
(C_Pnt2d X,long Ind_Pr_S_a_Suprimer,vector<S_FoFo>* P_List_PSFoFo) 
{
	//-----------------------------------------------------------------------//

/*	long Pnt_sur_Arete_Noeud;
	Ind_Pr_S_a_Suprimer=Descente_Gradiant(Ind_Pr_S_a_Suprimer,X,Pnt_sur_Arete_Noeud);
	S_Sommet S=List_Sommet[Ind_Pr_S_a_Suprimer];

	long i;
	for(i=0;i<3;i++)
	{
		C_Vec2d base=C_Vec2d(List_Noeud[S.Ind_Noeud[(i+1)%3]],List_Noeud[S.Ind_Noeud[(i+2)%3]]);
		C_Vec2d h=C_Vec2d(List_Noeud[S.Ind_Noeud[(i+1)%3]],List_Noeud[S.Ind_Noeud[i]]);
		C_Vec2d v=C_Vec2d(List_Noeud[S.Ind_Noeud[(i+1)%3]],X);

		double base_v_h=base^h;

		S_FoFo Nouveau_SFoFo;
		Nouveau_SFoFo.Ind_Voisin=S.Ind_Noeud[i];
		Nouveau_SFoFo.Valeur_FF=fabs((base^v)/base_v_h);
		Nouveau_SFoFo.Grad_FF=C_Vec2d(base.Y()/base_v_h,-base.X()/base_v_h);
		P_List_PSFoFo->push_back(Nouveau_SFoFo);
	}

	return 0.;*/

    //-----------------------------------------------------------------------//

	Ind_Pr_S_a_Suprimer=Descente_Gradiant(Ind_Pr_S_a_Suprimer,X);

    vector<S_Sommet_Restrain> List_Sommet_Cellule_X;
    if(Calcul_Nouvelle_Cellule(-1,X,Ind_Pr_S_a_Suprimer,&List_Sommet_Cellule_X))return 0; 
    
    double Aire_Cellule=Calcul_Aire_Cellule(&List_Sommet_Cellule_X);

    //-----------------------------------------------------------------------//

    double Somme_Aire_Contribution=0.;
    C_Vec2d Somme_Grad_Aire_Contribution(0.,0.);

    long Nb_SCX=List_Sommet_Cellule_X.size();
    long i;
    for(i=0;i<Nb_SCX;i++)
    {
        long i_m_1=(i-1+Nb_SCX)%Nb_SCX;
        long i_p_1=(i+1)%Nb_SCX;
        
        vector<C_Pnt2d> List_Sommet_Polygone;
        List_Sommet_Polygone.push_back(List_Sommet_Cellule_X[i].Coord_Sommet);
        List_Sommet_Polygone.push_back(List_Sommet_Cellule_X[i_p_1].Coord_Sommet);
        
        C_Cellule Cellule_Temp=List_Cellule[List_Sommet_Cellule_X[i].Ind_Noeud];

        list<S_Arete>::iterator j;
        for(j=Cellule_Temp.P_List_Arete->begin();j!=Cellule_Temp.P_List_Arete->end();j++)
        {
            S_Arete Arete_Temp=(*j);
            if(Arete_Temp.Ind_Noeud==List_Sommet_Cellule_X[i_p_1].Ind_Noeud)
            {
                do
                {
                    List_Sommet_Polygone.push_back(List_Sommet[Arete_Temp.Ind_Sommet[1]].Coord_Sommet);

                    j++;
                    if(j==Cellule_Temp.P_List_Arete->end())
                        j=Cellule_Temp.P_List_Arete->begin();
                    
                    Arete_Temp=(*j);
                
                }while(Arete_Temp.Ind_Noeud!=List_Sommet_Cellule_X[i_m_1].Ind_Noeud);
                break;
            }
        }
        
        //-------------------------------------------------------------------//
        
        double Aire_Contribution=Calcul_Aire_Polygone(&List_Sommet_Polygone);
        C_Vec2d Grad_Aire_Contribution=(C_Vec2d(X,List_Sommet_Cellule_X[i].Coord_Sommet)+C_Vec2d(X,List_Sommet_Cellule_X[i_p_1].Coord_Sommet))*
                                        List_Sommet_Cellule_X[i].Coord_Sommet.Distance(List_Sommet_Cellule_X[i_p_1].Coord_Sommet)/
                                        (2*X.Distance(List_Noeud[List_Sommet_Cellule_X[i].Ind_Noeud]));
        
        S_FoFo Nouveau_SFoFo;
        Nouveau_SFoFo.Ind_Voisin=List_Sommet_Cellule_X[i].Ind_Noeud;
        Nouveau_SFoFo.Valeur_FF=Aire_Contribution;
        Nouveau_SFoFo.Grad_FF=Grad_Aire_Contribution;

        P_List_PSFoFo->push_back(Nouveau_SFoFo);

        Somme_Aire_Contribution+=Aire_Contribution;
        Somme_Grad_Aire_Contribution+=Grad_Aire_Contribution;

        //-------------------------------------------------------------------//
    }

    //-----------------------------------------------------------------------//
    
    for(i=0;i<Nb_SCX;i++)
    {
        P_List_PSFoFo->at(i).Valeur_FF/=Somme_Aire_Contribution;
        P_List_PSFoFo->at(i).Grad_FF=(P_List_PSFoFo->at(i).Grad_FF-Somme_Grad_Aire_Contribution*P_List_PSFoFo->at(i).Valeur_FF)/Somme_Aire_Contribution;
    }
    
    //-----------------------------------------------------------------------//

    return fabs(Aire_Cellule-Somme_Aire_Contribution)/Aire_Cellule;
}

//===========================================================================//

double C_Meshless_2d::Calcul_Aire_Cellule(vector<S_Sommet_Restrain>* P_List_P_Sommet_Cellule)
{
    double Aire=0.;
    C_Vec2d V1(P_List_P_Sommet_Cellule->at(0).Coord_Sommet,P_List_P_Sommet_Cellule->at(1).Coord_Sommet);
    long Nb_Pnt=P_List_P_Sommet_Cellule->size();
    long i;
    for(i=2;i<Nb_Pnt;i++)
    {
        C_Vec2d V2(P_List_P_Sommet_Cellule->at(0).Coord_Sommet,P_List_P_Sommet_Cellule->at(i).Coord_Sommet);
        Aire+=V1^V2;
        V1=V2;
    }
    return (Aire/2.);
}

//===========================================================================//

double C_Meshless_2d::Calcul_Aire_Polygone(vector<C_Pnt2d>* P_List_Sommet_Polygone)
{
    double Aire=0.;
    C_Vec2d V1(P_List_Sommet_Polygone->at(0),P_List_Sommet_Polygone->at(1));
    long Nb_Pnt=P_List_Sommet_Polygone->size();
    long i;
    for(i=2;i<Nb_Pnt;i++)
    {
        C_Vec2d V2(P_List_Sommet_Polygone->at(0),P_List_Sommet_Polygone->at(i));
        Aire+=V1^V2;
        V1=V2;
    }
    return (Aire/2.);
}

//===========================================================================//

C_Pnt2d C_Meshless_2d::Calcul_CdM_Polygone(vector<C_Pnt2d>* P_List_Sommet_Polygone)
{
    C_Pnt2d P0=P_List_Sommet_Polygone->at(0);
    C_Pnt2d P1=P_List_Sommet_Polygone->at(1);
    C_Vec2d V1(P0,P1);
    
    double CdM_X=0.;
    double CdM_Y=0.;
    double Aire=0.;

    long Nb_Pnt=P_List_Sommet_Polygone->size();
    long i;
    for(i=2;i<Nb_Pnt;i++)
    {
        C_Pnt2d P2=P_List_Sommet_Polygone->at(i);
        C_Vec2d V2(P0,P2);

        double Aire_i=V1^V2;
        Aire+=Aire_i;

        CdM_X+=(P0.X()+P1.X()+P2.X())*Aire_i;
        CdM_Y+=(P0.Y()+P1.Y()+P2.Y())*Aire_i;

        P1=P2;
        V1=V2;
    }

    return C_Pnt2d(CdM_X/(3.*Aire),CdM_Y/(3.*Aire));
}

//===========================================================================//

long C_Meshless_2d::Trouve_Index_Sommet_Dispo()
{
    long Index_Dispo;
    if(List_Index_Dispo.empty())
    {
		Index_Dispo=List_Sommet.size();
		S_Sommet S_tmp;
		List_Sommet.push_back(S_tmp);
	}
    else
    {
        Index_Dispo=List_Index_Dispo.back();
        List_Index_Dispo.pop_back();
    }
    
    return Index_Dispo;
}

//===========================================================================//

void C_Meshless_2d::Retire_Sommet(long Ind_Sommet)
{
    //List_Sommet.erase(Ind_Sommet);
    List_Index_Dispo.push_back(Ind_Sommet);
}

//===========================================================================//

long C_Meshless_2d::Ajout_Nouveau_Sommet
(C_Pnt2d Centre,double Rayon,
 long Ind_Noeud_0,long Ind_Noeud_1,long Ind_Noeud_2,
 long Ind_Sommet_0,long Ind_Sommet_1,long Ind_Sommet_2)
{
    S_Sommet Nouveau_Sommet;
    Nouveau_Sommet.Sommet_Infini=0;
    Nouveau_Sommet.Ind_MExt=-1;
    Nouveau_Sommet.Ind_SExt=-1;
    Nouveau_Sommet.Coord_Sommet=Centre;
    Nouveau_Sommet.Rayon_Cercle=Rayon;
	Nouveau_Sommet.Valide=1;
    Nouveau_Sommet.Ind_Noeud[0]=Ind_Noeud_0;
    Nouveau_Sommet.Ind_Noeud[1]=Ind_Noeud_1;
    Nouveau_Sommet.Ind_Noeud[2]=Ind_Noeud_2;
    Nouveau_Sommet.Ind_Sommet[0]=Ind_Sommet_0;
    Nouveau_Sommet.Ind_Sommet[1]=Ind_Sommet_1;
    Nouveau_Sommet.Ind_Sommet[2]=Ind_Sommet_2;
    
    long Index=Trouve_Index_Sommet_Dispo();
    List_Sommet[Index]=Nouveau_Sommet;
    return Index;
}

//===========================================================================//

long C_Meshless_2d::Ajout_Nouveau_Sommet
(long Ind_Noeud_0,long Ind_Noeud_1,long Ind_Noeud_2,
 long Ind_Sommet_0,long Ind_Sommet_1,long Ind_Sommet_2)
{
    S_Sommet Nouveau_Sommet;
    Nouveau_Sommet.Sommet_Infini=1;
    Nouveau_Sommet.Ind_MExt=-1;
    Nouveau_Sommet.Ind_SExt=-1;
	Nouveau_Sommet.Valide=1;
    Nouveau_Sommet.Ind_Noeud[0]=Ind_Noeud_0;
    Nouveau_Sommet.Ind_Noeud[1]=Ind_Noeud_1;
    Nouveau_Sommet.Ind_Noeud[2]=Ind_Noeud_2;
    Nouveau_Sommet.Ind_Sommet[0]=Ind_Sommet_0;
    Nouveau_Sommet.Ind_Sommet[1]=Ind_Sommet_1;
    Nouveau_Sommet.Ind_Sommet[2]=Ind_Sommet_2;

    long Index=Trouve_Index_Sommet_Dispo();
    List_Sommet[Index]=Nouveau_Sommet;
    return Index;
}

//===========================================================================//

void C_Meshless_2d::Dispatch_Sommet() 
{
    long Nb_Noeud=List_Noeud.size();
    long i;
    for(i=0;i<Nb_Noeud;i++)
    {
        C_Cellule Cellule_Temp;
        Cellule_Temp.P_List_Arete = new list<S_Arete>; 
        List_Cellule.push_back(Cellule_Temp);
    }

    //map<const long,S_Sommet>::iterator j;
	vector<S_Sommet>::iterator j;
	long Ind_S_j=0;
	for(j=List_Sommet.begin();j!=List_Sommet.end();j++)
    {
        /*pair<const long,S_Sommet> Paire=(*j);
        if(!Paire.second.Sommet_Infini)
        {
            S_Arete Arete_Temp;
            Arete_Temp.Ind_Sommet[0]=Paire.first;
            for(i=0;i<3;i++)
            {
                Arete_Temp.Ind_Sommet[1]=Paire.second.Ind_Sommet[i];
                Arete_Temp.Ind_Noeud=Paire.second.Ind_Noeud[(i+2)%3];
                List_Cellule[Paire.second.Ind_Noeud[i]].P_List_Arete->push_back(Arete_Temp);
            }
        }*/
		S_Sommet S_j=(*j);
		if(S_j.Valide)
        if(!S_j.Sommet_Infini)
        {
            S_Arete Arete_Temp;
            Arete_Temp.Ind_Sommet[0]=Ind_S_j;
            for(i=0;i<3;i++)
            {
                Arete_Temp.Ind_Sommet[1]=S_j.Ind_Sommet[i];
                Arete_Temp.Ind_Noeud=S_j.Ind_Noeud[(i+2)%3];
                List_Cellule[S_j.Ind_Noeud[i]].P_List_Arete->push_back(Arete_Temp);
            }
        }
		Ind_S_j++;
    }

    for(i=0;i<Nb_Noeud;i++)
        List_Cellule[i].Build_Topologie();
}

//===========================================================================//

void C_Meshless_2d::Voronoi_Contrain()
{
    long Nb_Frontiere=List_P_Frontiere.size(); 
    long i;
    for(i=0;i<Nb_Frontiere;i++)
    {
        long Nb_Noeud_Frontiere=List_P_Frontiere[i]->size();
        
        long Ind_Noeud_F_j=List_P_Frontiere[i]->at(0);
        C_Pnt2d Noeud_F_j=List_Noeud[Ind_Noeud_F_j];
        long j;
        for(j=0;j<Nb_Noeud_Frontiere;j++)
        {
            long Ind_Noeud_F_jp1=List_P_Frontiere[i]->at((j+1)%Nb_Noeud_Frontiere);
            C_Pnt2d Noeud_F_jp1=List_Noeud[Ind_Noeud_F_jp1];
            
            C_Cellule& Ref_Cellule_F_j=List_Cellule[Ind_Noeud_F_j];
            if(j==0)
                Ref_Cellule_F_j.Fermee=0;

            C_Cellule& Ref_Cellule_F_jp1=List_Cellule[Ind_Noeud_F_jp1];
            Ref_Cellule_F_jp1.Fermee=0;


            bool NFj_NFjp1_Voisin=0;
            S_Arete Arete_Commune;
            list<S_Arete>::iterator k;
            for(k=Ref_Cellule_F_j.P_List_Arete->begin();k!=Ref_Cellule_F_j.P_List_Arete->end();k++)
            {
                Arete_Commune=(*k);
                if(Arete_Commune.Ind_Noeud==Ind_Noeud_F_jp1)
                {
                    NFj_NFjp1_Voisin=1;
                    break;
                }
            }

            if(NFj_NFjp1_Voisin)
            {
                long Ind_Sommet_Inf=Ajout_Nouveau_Sommet(Ind_Noeud_F_j,Ind_Noeud_F_jp1,-1,-1,Arete_Commune.Ind_Sommet[0],-1);

                if(List_Sommet[Arete_Commune.Ind_Sommet[0]].Ind_Noeud[0]==Ind_Noeud_F_j)
                    List_Sommet[Arete_Commune.Ind_Sommet[0]].Ind_Sommet[0]=Ind_Sommet_Inf;
                else
                {
                    if(List_Sommet[Arete_Commune.Ind_Sommet[0]].Ind_Noeud[1]==Ind_Noeud_F_j)
                        List_Sommet[Arete_Commune.Ind_Sommet[0]].Ind_Sommet[1]=Ind_Sommet_Inf;
                    else
                        List_Sommet[Arete_Commune.Ind_Sommet[0]].Ind_Sommet[2]=Ind_Sommet_Inf;
                }
    
                if(j==0)
                {
                    while(Ref_Cellule_F_j.P_List_Arete->back().Ind_Noeud!=Ind_Noeud_F_jp1)
                    {
                        Ref_Cellule_F_j.P_List_Arete->push_front(Ref_Cellule_F_j.P_List_Arete->back());
                        Ref_Cellule_F_j.P_List_Arete->pop_back();
                    }
                }
                else
                {
                    while(Ref_Cellule_F_j.P_List_Arete->back().Ind_Noeud!=Ind_Noeud_F_jp1)
                        Ref_Cellule_F_j.P_List_Arete->pop_back();
                }

                  if(j==(Nb_Noeud_Frontiere-1))
                {
                    while(Ref_Cellule_F_jp1.P_List_Arete->front().Ind_Noeud!=Ind_Noeud_F_j)
                        Ref_Cellule_F_jp1.P_List_Arete->pop_front();
                }
                else
                {
                    while(Ref_Cellule_F_jp1.P_List_Arete->front().Ind_Noeud!=Ind_Noeud_F_j)
                    {
                        Ref_Cellule_F_jp1.P_List_Arete->push_back(Ref_Cellule_F_jp1.P_List_Arete->front());
                        Ref_Cellule_F_jp1.P_List_Arete->pop_front();
                    }
                }
                
                S_Arete& Ref_Arete_Cel_NF_j=Ref_Cellule_F_j.P_List_Arete->back();
                Ref_Arete_Cel_NF_j.Ind_Sommet[1]=Ind_Sommet_Inf;
                
                S_Arete& Ref_Arete_Cel_NF_jp1=Ref_Cellule_F_jp1.P_List_Arete->front();
                Ref_Arete_Cel_NF_jp1.Ind_Sommet[0]=Ind_Sommet_Inf;
            }
            else
            {
                vector<long> List_Ind_Noeud_Cavite;
                List_Ind_Noeud_Cavite.push_back(Ind_Noeud_F_j);

                list<S_Arete>::iterator k_ini=Ref_Cellule_F_j.P_List_Arete->begin();
                long Ind_Noeud_0;
                if(j==0)
                    Ind_Noeud_0=Ref_Cellule_F_j.P_List_Arete->back().Ind_Noeud;
                else
                {
                    k_ini++;
                    Ind_Noeud_0=Ref_Cellule_F_j.P_List_Arete->front().Ind_Noeud;
                }
                
                C_Vec2d Nj_Njp1=C_Vec2d(Noeud_F_j,Noeud_F_jp1).Normalized();
                double PrV_0=Nj_Njp1^C_Vec2d(Noeud_F_j,List_Noeud[Ind_Noeud_0]);

                list<S_Arete>::iterator k_fin=Ref_Cellule_F_j.P_List_Arete->end();
                list<S_Arete>::iterator k_fin_m_1=k_fin;
                k_fin_m_1--;

                for(k=k_ini;k!=k_fin;k++)
                {
                    S_Arete Arete_Temp=(*k);
                    long Ind_Noeud_1=Arete_Temp.Ind_Noeud;
                    double PrV_1=Nj_Njp1^C_Vec2d(Noeud_F_j,List_Noeud[Ind_Noeud_1]);
                
                    bool b=0;
                    long Ind_Sommet_Temp;
                    long l;

					if(PrV_1>-PRECISION_0)
                    {
                        if(PrV_0<0.)
                        {
                            List_Ind_Noeud_Cavite.push_back(Ind_Noeud_0);

                            if(List_Sommet[Arete_Temp.Ind_Sommet[0]].Ind_Noeud[0]==Ind_Noeud_1)
                                Ind_Sommet_Temp=List_Sommet[Arete_Temp.Ind_Sommet[0]].Ind_Sommet[0];
                            else
                            {
                                if(List_Sommet[Arete_Temp.Ind_Sommet[0]].Ind_Noeud[1]==Ind_Noeud_1)
                                    Ind_Sommet_Temp=List_Sommet[Arete_Temp.Ind_Sommet[0]].Ind_Sommet[1];
                                else
                                    Ind_Sommet_Temp=List_Sommet[Arete_Temp.Ind_Sommet[0]].Ind_Sommet[2];
                            }
                    
                            for(l=0;l<3;l++)
                            {
                                if(List_Sommet[Ind_Sommet_Temp].Ind_Noeud[l]==Ind_Noeud_0)
                                    break;
                            }

                            b=1;
                        }
					}
					else
                    {
                        if(k==k_fin_m_1)
                        {
                            List_Ind_Noeud_Cavite.push_back(Ind_Noeud_1);

                            if(List_Sommet[Arete_Temp.Ind_Sommet[1]].Ind_Noeud[0]==Ind_Noeud_1)
                                Ind_Sommet_Temp=List_Sommet[Arete_Temp.Ind_Sommet[1]].Ind_Sommet[1];
                            else
                            {
                                    if(List_Sommet[Arete_Temp.Ind_Sommet[1]].Ind_Noeud[1]==Ind_Noeud_1)
                                    Ind_Sommet_Temp=List_Sommet[Arete_Temp.Ind_Sommet[1]].Ind_Sommet[2];
                                else
                                    Ind_Sommet_Temp=List_Sommet[Arete_Temp.Ind_Sommet[1]].Ind_Sommet[0];
                            }

                            for(l=0;l<3;l++)
                            {
                                if(List_Sommet[Ind_Sommet_Temp].Ind_Noeud[l]==Ind_Noeud_1)
                                        break;
                            } 

                            b=1;
                        }
                    }

                    if(b)
                    {
                        while(List_Sommet[Ind_Sommet_Temp].Ind_Noeud[(l+1)%3]!=Ind_Noeud_F_jp1)
                        {
                            double PrV=Nj_Njp1^C_Vec2d(Noeud_F_j,List_Noeud[List_Sommet[Ind_Sommet_Temp].Ind_Noeud[(l+1)%3]]);
                               
                            long Ind_Prev_Sommet=Ind_Sommet_Temp;

                            if(PrV<0.)
                            {
                                List_Ind_Noeud_Cavite.push_back(List_Sommet[Ind_Sommet_Temp].Ind_Noeud[(l+1)%3]);
                                Ind_Sommet_Temp=List_Sommet[Ind_Sommet_Temp].Ind_Sommet[(l+2)%3];
                            }
                             else
                                Ind_Sommet_Temp=List_Sommet[Ind_Sommet_Temp].Ind_Sommet[(l+1)%3];
                            
                            for(l=0;l<3;l++)
                            {
                                if(List_Sommet[Ind_Sommet_Temp].Ind_Sommet[l]==Ind_Prev_Sommet)
                                    break;
                            }
                        }

                        break;
                    }
                    
                    Ind_Noeud_0=Ind_Noeud_1;
                    PrV_0=PrV_1;
                }

                List_Ind_Noeud_Cavite.push_back(Ind_Noeud_F_jp1);

                //-----------------------------------------------------------//

                long Nb_Noeud_Cavite=List_Ind_Noeud_Cavite.size();

                vector<long> List_Ind_Nouveaux_Sommet;
                vector<S_2_Index> List_Arete_Tri_Temp;
    
                S_2_Index Arete_Tri_Ini;
                Arete_Tri_Ini.Index[0]=0;
                Arete_Tri_Ini.Index[1]=Nb_Noeud_Cavite-1;
                List_Arete_Tri_Temp.push_back(Arete_Tri_Ini);

                bool Premiere_Fois=1;
                while(!List_Arete_Tri_Temp.empty())
                {
                    S_2_Index Arete_Tri_Temp=List_Arete_Tri_Temp.back();
                    List_Arete_Tri_Temp.pop_back();
                    
                    long l;
                    for(l=Arete_Tri_Temp.Index[0]+1;l<Arete_Tri_Temp.Index[1];l++)
                    {
                        C_Pnt2d Centre;
                        double Rayon;
                     
                        Calcul_Cercle(List_Noeud[List_Ind_Noeud_Cavite[Arete_Tri_Temp.Index[0]]],
                                      List_Noeud[List_Ind_Noeud_Cavite[Arete_Tri_Temp.Index[1]]],
                                      List_Noeud[List_Ind_Noeud_Cavite[l]],
                                      Centre,
                                      Rayon);
                        
                        bool Triangle_Valide=1;
                        long m;
                        for(m=Arete_Tri_Temp.Index[0]+1;m<Arete_Tri_Temp.Index[1];m++)
                        {
                            if(m!=l)
                            {
                                if((List_Noeud[List_Ind_Noeud_Cavite[m]].Distance(Centre)-Rayon)<-PRECISION_1)
                                {
                                    Triangle_Valide=0;
                                    break;
                                }
                            }
                        }

                        if(Triangle_Valide)
                        {
                            long Ind_Nouveau_Sommet=Ajout_Nouveau_Sommet
                                (Centre,Rayon,
                                 List_Ind_Noeud_Cavite[Arete_Tri_Temp.Index[1]],List_Ind_Noeud_Cavite[Arete_Tri_Temp.Index[0]],List_Ind_Noeud_Cavite[l],
                                 -1,-1,-1);
                        
                            List_Ind_Nouveaux_Sommet.push_back(Ind_Nouveau_Sommet);

                            if(Premiere_Fois)
                            {
                                Premiere_Fois=0;
 
                                 long Ind_Sommet_Inf=Ajout_Nouveau_Sommet
                                    (Ind_Noeud_F_j,Ind_Noeud_F_jp1,-1,
                                     -1,Ind_Nouveau_Sommet,-1);

                                List_Ind_Nouveaux_Sommet.push_back(Ind_Sommet_Inf);
                            }
                              
                            if((l-1)!=Arete_Tri_Temp.Index[0])
                            {
                                S_2_Index Arete_Tri_a_Traiter;
                                Arete_Tri_a_Traiter.Index[0]=Arete_Tri_Temp.Index[0];
                                Arete_Tri_a_Traiter.Index[1]=l;
                                List_Arete_Tri_Temp.push_back(Arete_Tri_a_Traiter);
                            }
                            
                            if((l+1)!=Arete_Tri_Temp.Index[1])
                            {
                                S_2_Index Arete_Tri_a_Traiter;
                                Arete_Tri_a_Traiter.Index[0]=l;
                                Arete_Tri_a_Traiter.Index[1]=Arete_Tri_Temp.Index[1];
                                List_Arete_Tri_Temp.push_back(Arete_Tri_a_Traiter);
                            }
                        
                            break;
                        }
                    }
                }

				//-----------------------------------------------------------//
				
				/*if(j==)
				{
					ofstream data("List_Ind_Noeud_Cavite.dat");
					size_t ii;
					for(size_t ii=0;ii<List_Ind_Noeud_Cavite.size();ii++)
					{
						data<<List_Ind_Noeud_Cavite[ii]+1<<endl;
					}

					data.close();

					ofstream data1("List_Nouveaux_Sommet.dat");
					for(ii=0;ii<List_Ind_Nouveaux_Sommet.size();ii++)
					{
						S_Sommet s=List_Sommet[List_Ind_Nouveaux_Sommet[ii]];
						data1<<s.Ind_Noeud[0]+1<<' '<<s.Ind_Noeud[1]+1<<' '<<s.Ind_Noeud[2]+1<<endl;
					}

					data1.close();
				}*/

                //-----------------------------------------------------------//

                long Nb_Nouveau_Sommet=List_Ind_Nouveaux_Sommet.size();

                long l;
                for(l=0;l<Nb_Noeud_Cavite;l++)
                {
                    C_Cellule& Ref_Cellule_Temp=List_Cellule[List_Ind_Noeud_Cavite[l]];
                    list<long> List_Ind_Nouveau_Sommet_Cellule_Temp_Oriente;
                    
                    long m;
                    for(m=0;m<Nb_Nouveau_Sommet;m++)
                    {
                        if(List_Sommet[List_Ind_Nouveaux_Sommet[m]].Ind_Noeud[0]==List_Ind_Noeud_Cavite[l])
                            List_Ind_Nouveau_Sommet_Cellule_Temp_Oriente.push_back(List_Ind_Nouveaux_Sommet[m]);
                        else
                        {
                            if(List_Sommet[List_Ind_Nouveaux_Sommet[m]].Ind_Noeud[1]==List_Ind_Noeud_Cavite[l])
                            {
                                List_Ind_Nouveau_Sommet_Cellule_Temp_Oriente.push_back(List_Ind_Nouveaux_Sommet[m]);
                                Permutation_Circulaire_Sommet(List_Ind_Nouveaux_Sommet[m],0);
                            }
                            else
                            {
                                if(List_Sommet[List_Ind_Nouveaux_Sommet[m]].Ind_Noeud[2]==List_Ind_Noeud_Cavite[l])
                                {
                                    List_Ind_Nouveau_Sommet_Cellule_Temp_Oriente.push_back(List_Ind_Nouveaux_Sommet[m]);
                                    Permutation_Circulaire_Sommet(List_Ind_Nouveaux_Sommet[m],1);
                                }
                            }
                        }
                    }
                
                    //-------------------------------------------------------//
                    
					while(!List_Ind_Nouveau_Sommet_Cellule_Temp_Oriente.empty())
					{
						list<long> List_Ind_Nouveau_Sommet_Cellule_Temp_Oriente_Rangee;
						long Ind_Sommet_Ini=List_Ind_Nouveau_Sommet_Cellule_Temp_Oriente.back();
						List_Ind_Nouveau_Sommet_Cellule_Temp_Oriente.pop_back();
						List_Ind_Nouveau_Sommet_Cellule_Temp_Oriente_Rangee.push_back(Ind_Sommet_Ini);
                    
						long Ind_Noeud_Ini=List_Sommet[Ind_Sommet_Ini].Ind_Noeud[1];
						long Ind_Noeud_Fin=List_Sommet[Ind_Sommet_Ini].Ind_Noeud[2];

						bool b;
						do
						{
							b=0;

							list<long>::iterator n;
							for(n=List_Ind_Nouveau_Sommet_Cellule_Temp_Oriente.begin();n!=List_Ind_Nouveau_Sommet_Cellule_Temp_Oriente.end();n++)
							{
								long Ind_Sommet_Temp=(*n);
								if(List_Sommet[Ind_Sommet_Temp].Ind_Noeud[2]==Ind_Noeud_Ini)
								{
									List_Ind_Nouveau_Sommet_Cellule_Temp_Oriente_Rangee.push_front(Ind_Sommet_Temp);
									Ind_Noeud_Ini=List_Sommet[Ind_Sommet_Temp].Ind_Noeud[1];
									List_Ind_Nouveau_Sommet_Cellule_Temp_Oriente.erase(n);
									b=1;
									break;
								}
								else
								{
									if(List_Sommet[Ind_Sommet_Temp].Ind_Noeud[1]==Ind_Noeud_Fin)
									{
										List_Ind_Nouveau_Sommet_Cellule_Temp_Oriente_Rangee.push_back(Ind_Sommet_Temp);
										Ind_Noeud_Fin=List_Sommet[Ind_Sommet_Temp].Ind_Noeud[2];
										List_Ind_Nouveau_Sommet_Cellule_Temp_Oriente.erase(n);
										b=1;
										break;
									}
								}
							}

						}while(b);

						if(Ind_Noeud_Ini==Ind_Noeud_Fin)
							List_Ind_Nouveau_Sommet_Cellule_Temp_Oriente_Rangee.push_back(List_Ind_Nouveau_Sommet_Cellule_Temp_Oriente_Rangee.front());

						//-------------------------------------------------------//
                    
						vector<S_Arete> List_Nouvelle_Arete_Cellule_Temp;

						list<long>::iterator n_Ini=List_Ind_Nouveau_Sommet_Cellule_Temp_Oriente_Rangee.begin();
						long Ind_Sommet_m_m=(*n_Ini);
						n_Ini++;
						list<long>::iterator n;
						for(n=n_Ini;n!=List_Ind_Nouveau_Sommet_Cellule_Temp_Oriente_Rangee.end();n++)
						{
							long Ind_Sommet_Actu=(*n);
							List_Sommet[Ind_Sommet_Actu].Ind_Sommet[1]=Ind_Sommet_m_m;
							List_Sommet[Ind_Sommet_m_m].Ind_Sommet[0]=Ind_Sommet_Actu;
                                        
							S_Arete Nouvelle_Arete;
							Nouvelle_Arete.Ind_Sommet[0]=Ind_Sommet_m_m;
							Nouvelle_Arete.Ind_Sommet[1]=Ind_Sommet_Actu;
							Nouvelle_Arete.Ind_Noeud=List_Sommet[Ind_Sommet_Actu].Ind_Noeud[1];
							List_Nouvelle_Arete_Cellule_Temp.push_back(Nouvelle_Arete);
                    
							Ind_Sommet_m_m=Ind_Sommet_Actu;
						}
                    
						//-------------------------------------------------------//
                    
						long Nb_Nouvelle_Arete=List_Nouvelle_Arete_Cellule_Temp.size();

						if((Ind_Noeud_Fin==-1)||(Ind_Noeud_Ini==-1))
						{
							if(l==0)
							{
								if(j==0)
								{
									while(Ref_Cellule_Temp.P_List_Arete->back().Ind_Noeud!=Ind_Noeud_Ini)
									{
										Ref_Cellule_Temp.P_List_Arete->push_front(Ref_Cellule_Temp.P_List_Arete->back());
										Ref_Cellule_Temp.P_List_Arete->pop_back();
									}
								}
								else
								{
									while(Ref_Cellule_Temp.P_List_Arete->back().Ind_Noeud!=Ind_Noeud_Ini)
										Ref_Cellule_Temp.P_List_Arete->pop_back();
								}
                    
								S_Arete& Ref_Arete_Liaison=Ref_Cellule_Temp.P_List_Arete->back();
								Ref_Arete_Liaison.Ind_Sommet[1]=List_Ind_Nouveau_Sommet_Cellule_Temp_Oriente_Rangee.front();

								List_Sommet[Ref_Arete_Liaison.Ind_Sommet[1]].Ind_Sommet[1]=Ref_Arete_Liaison.Ind_Sommet[0];

								if(List_Sommet[Ref_Arete_Liaison.Ind_Sommet[0]].Ind_Noeud[0]==List_Ind_Noeud_Cavite[l])
									List_Sommet[Ref_Arete_Liaison.Ind_Sommet[0]].Ind_Sommet[0]=Ref_Arete_Liaison.Ind_Sommet[1];
								else
								{
									if(List_Sommet[Ref_Arete_Liaison.Ind_Sommet[0]].Ind_Noeud[1]==List_Ind_Noeud_Cavite[l])
										List_Sommet[Ref_Arete_Liaison.Ind_Sommet[0]].Ind_Sommet[1]=Ref_Arete_Liaison.Ind_Sommet[1];
									else
										List_Sommet[Ref_Arete_Liaison.Ind_Sommet[0]].Ind_Sommet[2]=Ref_Arete_Liaison.Ind_Sommet[1];
								}

								long o;
								for(o=0;o<Nb_Nouvelle_Arete;o++)
									Ref_Cellule_Temp.P_List_Arete->push_back(List_Nouvelle_Arete_Cellule_Temp[o]);
							}
							else
							{
								if(l==(Nb_Noeud_Cavite-1))
								{
									if(j==(Nb_Noeud_Frontiere-1))
									{
										while(Ref_Cellule_Temp.P_List_Arete->front().Ind_Noeud!=Ind_Noeud_Fin)
											Ref_Cellule_Temp.P_List_Arete->pop_front();
									}
									else
									{
										while(Ref_Cellule_Temp.P_List_Arete->front().Ind_Noeud!=Ind_Noeud_Fin)
										{
											Ref_Cellule_Temp.P_List_Arete->push_back(Ref_Cellule_Temp.P_List_Arete->front());
											Ref_Cellule_Temp.P_List_Arete->pop_front();
										}
									}
                        
									S_Arete& Ref_Arete_Liaison=Ref_Cellule_Temp.P_List_Arete->front();
									Ref_Arete_Liaison.Ind_Sommet[0]=List_Ind_Nouveau_Sommet_Cellule_Temp_Oriente_Rangee.back();
                            
									long o;
									for(o=Nb_Nouvelle_Arete-1;o>=0;o--)
										Ref_Cellule_Temp.P_List_Arete->push_front(List_Nouvelle_Arete_Cellule_Temp[o]);
								}
							}
						}
						else
						{
							if(Ref_Cellule_Temp.Fermee)
							{
								if(Ind_Noeud_Ini!=Ind_Noeud_Fin)
								{
									while(Ref_Cellule_Temp.P_List_Arete->front().Ind_Noeud!=Ind_Noeud_Fin)
									{
										Ref_Cellule_Temp.P_List_Arete->push_back(Ref_Cellule_Temp.P_List_Arete->front());
										Ref_Cellule_Temp.P_List_Arete->pop_front();
									}

									while(Ref_Cellule_Temp.P_List_Arete->back().Ind_Noeud!=Ind_Noeud_Ini)
										Ref_Cellule_Temp.P_List_Arete->pop_back();
                                    
									S_Arete& Ref_Arete_Liaison_Fin=Ref_Cellule_Temp.P_List_Arete->front();
									Ref_Arete_Liaison_Fin.Ind_Sommet[0]=List_Ind_Nouveau_Sommet_Cellule_Temp_Oriente_Rangee.back();
                                    
									S_Arete& Ref_Arete_Liaison_Ini=Ref_Cellule_Temp.P_List_Arete->back();
									Ref_Arete_Liaison_Ini.Ind_Sommet[1]=List_Ind_Nouveau_Sommet_Cellule_Temp_Oriente_Rangee.front();
                
									List_Sommet[Ref_Arete_Liaison_Ini.Ind_Sommet[1]].Ind_Sommet[1]=Ref_Arete_Liaison_Ini.Ind_Sommet[0];
                                    
									if(List_Sommet[Ref_Arete_Liaison_Ini.Ind_Sommet[0]].Ind_Noeud[0]==List_Ind_Noeud_Cavite[l])
										List_Sommet[Ref_Arete_Liaison_Ini.Ind_Sommet[0]].Ind_Sommet[0]=Ref_Arete_Liaison_Ini.Ind_Sommet[1];
									else
									{
										if(List_Sommet[Ref_Arete_Liaison_Ini.Ind_Sommet[0]].Ind_Noeud[1]==List_Ind_Noeud_Cavite[l])
											List_Sommet[Ref_Arete_Liaison_Ini.Ind_Sommet[0]].Ind_Sommet[1]=Ref_Arete_Liaison_Ini.Ind_Sommet[1];
										else
											List_Sommet[Ref_Arete_Liaison_Ini.Ind_Sommet[0]].Ind_Sommet[2]=Ref_Arete_Liaison_Ini.Ind_Sommet[1];
									}
								}
								else 
									Ref_Cellule_Temp.P_List_Arete->clear();
                                
								long o;
								for(o=0;o<Nb_Nouvelle_Arete;o++)
										Ref_Cellule_Temp.P_List_Arete->push_back(List_Nouvelle_Arete_Cellule_Temp[o]);
							}
							else
							{
								list<S_Arete> List_Arete_Temp;

								while(Ref_Cellule_Temp.P_List_Arete->front().Ind_Noeud!=Ind_Noeud_Fin)
								{
									List_Arete_Temp.push_back(Ref_Cellule_Temp.P_List_Arete->front());
									Ref_Cellule_Temp.P_List_Arete->pop_front();
								}

								S_Arete& Ref_Arete_Liaison_Fin=Ref_Cellule_Temp.P_List_Arete->front();
								Ref_Arete_Liaison_Fin.Ind_Sommet[0]=List_Ind_Nouveau_Sommet_Cellule_Temp_Oriente_Rangee.back();

								long o;
								for(o=Nb_Nouvelle_Arete-1;o>=0;o--)
										Ref_Cellule_Temp.P_List_Arete->push_front(List_Nouvelle_Arete_Cellule_Temp[o]);

								while(List_Arete_Temp.back().Ind_Noeud!=Ind_Noeud_Ini)
									List_Arete_Temp.pop_back();

								S_Arete& Ref_Arete_Liaison_Ini=List_Arete_Temp.back();
								Ref_Arete_Liaison_Ini.Ind_Sommet[1]=List_Ind_Nouveau_Sommet_Cellule_Temp_Oriente_Rangee.front();

								List_Sommet[Ref_Arete_Liaison_Ini.Ind_Sommet[1]].Ind_Sommet[1]=Ref_Arete_Liaison_Ini.Ind_Sommet[0];                                                                
                                
								if(List_Sommet[Ref_Arete_Liaison_Ini.Ind_Sommet[0]].Ind_Noeud[0]==List_Ind_Noeud_Cavite[l])
									List_Sommet[Ref_Arete_Liaison_Ini.Ind_Sommet[0]].Ind_Sommet[0]=Ref_Arete_Liaison_Ini.Ind_Sommet[1];
								else
								{
									if(List_Sommet[Ref_Arete_Liaison_Ini.Ind_Sommet[0]].Ind_Noeud[1]==List_Ind_Noeud_Cavite[l])
										List_Sommet[Ref_Arete_Liaison_Ini.Ind_Sommet[0]].Ind_Sommet[1]=Ref_Arete_Liaison_Ini.Ind_Sommet[1];
									else
										List_Sommet[Ref_Arete_Liaison_Ini.Ind_Sommet[0]].Ind_Sommet[2]=Ref_Arete_Liaison_Ini.Ind_Sommet[1];
								}

								while(!List_Arete_Temp.empty())
								{
									Ref_Cellule_Temp.P_List_Arete->push_front(List_Arete_Temp.back());
									List_Arete_Temp.pop_back();
								}
							}
						}
					}
					
                    //-------------------------------------------------------//
                }
            }

            Ind_Noeud_F_j=Ind_Noeud_F_jp1;
            Noeud_F_j=Noeud_F_jp1;
        }

        //-------------------------------------------------------------------//
    }
    
    //-----------------------------------------------------------------------//

    vector<bool> Vec_Noeud_Valide(List_Noeud.size(),0);

    for(i=0;i<List_Cellule.size();i++)if(!List_Cellule[i].Fermee)break;
    Vec_Noeud_Valide[i]=1;
    list<long> List_Ind_Noeud_Front;List_Ind_Noeud_Front.push_back(i);
    
    while(!List_Ind_Noeud_Front.empty())
    {
        i=List_Ind_Noeud_Front.back();List_Ind_Noeud_Front.pop_back();

        list<S_Arete>::iterator k;
        for(k=List_Cellule[i].P_List_Arete->begin();k!=List_Cellule[i].P_List_Arete->end();k++)
        {
            S_Arete Arete_k=(*k);
            if(!Vec_Noeud_Valide[Arete_k.Ind_Noeud])
            {
                Vec_Noeud_Valide[Arete_k.Ind_Noeud]=1;
                List_Ind_Noeud_Front.push_front(Arete_k.Ind_Noeud);
            }
        }
    }

    //-----------------------------------------------------------------------//

    /*map<const long,S_Sommet>::iterator j;
    for(j=List_Sommet.begin();j!=List_Sommet.end();j++)
    {
        pair<const long,S_Sommet>& Ref_Paire=(*j);
        Ref_Paire.second.Valide=0;
    }*/
	
	vector<S_Sommet>::iterator j;
    for(j=List_Sommet.begin();j!=List_Sommet.end();j++)
    {
        S_Sommet& S_j=(*j);
        S_j.Valide=0;
    }

    long Nb_Cellule=List_Cellule.size();
    for(i=0;i<Nb_Cellule;i++)
    {
        if(Vec_Noeud_Valide[i])
        {
            if(!List_Cellule[i].Fermee)
                List_Sommet[List_Cellule[i].P_List_Arete->back().Ind_Sommet[1]].Valide=1;

            list<S_Arete>::iterator k;
            for(k=List_Cellule[i].P_List_Arete->begin();k!=List_Cellule[i].P_List_Arete->end();k++)
            {
                S_Arete Arete_Temp=(*k);
                List_Sommet[Arete_Temp.Ind_Sommet[0]].Valide=1;
            }
        }
    }

    /*for(j=List_Sommet.begin();j!=List_Sommet.end();)
    {
        pair<const long,S_Sommet> Paire=(*j);
        j++;
        if(!Paire.second.Valide)
            Retire_Sommet(Paire.first);
    }*/

	long Ind_S_j=0;
	for(j=List_Sommet.begin();j!=List_Sommet.end();j++)
    {
        S_Sommet S_j=(*j);
        if(!S_j.Valide)
            Retire_Sommet(Ind_S_j);
		Ind_S_j++;
    }

    //-----------------------------------------------------------------------//

    //Renumerotation_Sommet(&Vec_Noeud_Valide);

    Renumerotation_Noeud(&Vec_Noeud_Valide);

    //-----------------------------------------------------------------------//
}

//===========================================================================//

void C_Meshless_2d::Renumerotation_Noeud(vector<bool>* P_Vec_Noeud_Valide)
{
    long Nb_Noeud=List_Noeud.size();

    vector<C_Pnt2d> New_List_Noeud;
    vector<C_Cellule> New_List_Cellule;

    Vec_Ind_Noeud_New_Old.resize(Nb_Noeud);
    long i;for(i=0;i<Nb_Noeud;i++)Vec_Ind_Noeud_New_Old[i]=-1;

    long I=0;
    for(i=0;i<Nb_Noeud;i++)
    {
        if(P_Vec_Noeud_Valide->at(i))
        {
            New_List_Noeud.push_back(List_Noeud[i]);
            New_List_Cellule.push_back(List_Cellule[i]);
            Vec_Ind_Noeud_New_Old[i]=I;
            Vec_Ind_Noeud_Old_New.push_back(i);
            I++;
        }
        else delete List_Cellule[i].P_List_Arete;
    }

    List_Noeud.clear();List_Noeud.resize(New_List_Noeud.size());
    copy(New_List_Noeud.begin(),New_List_Noeud.end(),List_Noeud.begin());
    
    List_Cellule.clear();List_Cellule.resize(New_List_Cellule.size());
    copy(New_List_Cellule.begin(),New_List_Cellule.end(),List_Cellule.begin());

    //-----------------------------------------------------------------------//

    /*map<long const,S_Sommet>::iterator j;
    for(j=List_Sommet.begin();j!=List_Sommet.end();j++)
    {
        pair<long const,S_Sommet>& Paire_j=*j;
        long k;
        for(k=0;k<3;k++)if(Paire_j.second.Ind_Noeud[k]!=-1)Paire_j.second.Ind_Noeud[k]=Vec_Ind_Noeud_New_Old[Paire_j.second.Ind_Noeud[k]];
    }*/

	vector<S_Sommet>::iterator j;
    for(j=List_Sommet.begin();j!=List_Sommet.end();j++)
    {
        S_Sommet& S_j=*j;
		if(S_j.Valide)
        {
			long k;
			for(k=0;k<3;k++)if(S_j.Ind_Noeud[k]!=-1)S_j.Ind_Noeud[k]=Vec_Ind_Noeud_New_Old[S_j.Ind_Noeud[k]];
		}
    }

    for(i=0;i<List_Cellule.size();i++)
    {
        list<S_Arete>::iterator k;
        for(k=List_Cellule[i].P_List_Arete->begin();k!=List_Cellule[i].P_List_Arete->end();k++)
        {
            S_Arete& Arete_k=(*k);
            Arete_k.Ind_Noeud=Vec_Ind_Noeud_New_Old[Arete_k.Ind_Noeud];
        }
    }

    for(i=0;i<List_P_Frontiere.size();i++)
    {
        long k;for(k=0;k<List_P_Frontiere[i]->size();k++)List_P_Frontiere[i]->at(k)=Vec_Ind_Noeud_New_Old[List_P_Frontiere[i]->at(k)];
    }
    
    //-----------------------------------------------------------------------//
}

/*
void C_Meshless_2d::Renumerotation_Sommet(vector<bool>* P_Vec_Noeud_Valide)
{
    vector<long> Nouveau_Index((pair<long,S_Sommet>(*(--List_Sommet.end()))).first+1,-1);

    long j=0;
    map<long const,S_Sommet>::iterator i;
    map<long const,S_Sommet>::iterator imm;
    for(i=List_Sommet.begin();i!=List_Sommet.end();)
    {
        pair<long,S_Sommet> Paire_i=*i;
        Nouveau_Index[Paire_i.first]=j;
        imm=i;i++;
        List_Sommet.erase(imm);
        List_Sommet.insert(make_pair(j,Paire_i.second));
        j++;
    }

    List_Index_Dispo.clear();

    for(i=List_Sommet.begin();i!=List_Sommet.end();i++)
    {
        pair<long const,S_Sommet>& Paire_i=*i;

        for(j=0;j<3;j++)
        {
            if(Paire_i.second.Ind_Sommet[j]+1)
                Paire_i.second.Ind_Sommet[j]=Nouveau_Index[Paire_i.second.Ind_Sommet[j]];
        }
    }

    long Nb_Cellule=List_Cellule.size();
    for(j=0;j<Nb_Cellule;j++)
    {
        if(P_Vec_Noeud_Valide->at(j))
        {
            list<S_Arete>::iterator k;
            for(k=List_Cellule[j].P_List_Arete->begin();k!=List_Cellule[j].P_List_Arete->end();k++)
            {
                S_Arete& Arete_Temp=(*k);
                Arete_Temp.Ind_Sommet[0]=Nouveau_Index[Arete_Temp.Ind_Sommet[0]];
                Arete_Temp.Ind_Sommet[1]=Nouveau_Index[Arete_Temp.Ind_Sommet[1]];
            }
        }
    }
}
*/

//===========================================================================//

void C_Meshless_2d::Intersection_Voronoi_Contrain_avec_Frontiere()
{
    list<S_Int_Cel_Front> List_SICF;
    
    long Nb_Frontiere=List_P_Frontiere.size();
    long i;
    for(i=0;i<Nb_Frontiere;i++)
    {
        long Nb_Noeud_Frontiere=List_P_Frontiere[i]->size();
        
        long Ind_Noeud_F_j=List_P_Frontiere[i]->at(0);
        C_Pnt2d Noeud_F_j=List_Noeud[Ind_Noeud_F_j];
        C_Cellule Cellule_F_j=List_Cellule[Ind_Noeud_F_j];

        S_Int_Cel_Front SICF_Ini;
        SICF_Ini.Ind_Noeud=Ind_Noeud_F_j;
        SICF_Ini.Type=0;

        S_Int_Cel_Front SICF_Temp;
        
        long j;
        for(j=0;j<Nb_Noeud_Frontiere;j++)
        {
            long Ind_Noeud_F_jp1=List_P_Frontiere[i]->at((j+1)%Nb_Noeud_Frontiere);
            C_Pnt2d Noeud_F_jp1=List_Noeud[Ind_Noeud_F_jp1];
            C_Cellule Cellule_F_jp1=List_Cellule[Ind_Noeud_F_jp1];

            C_Vec2d Nj_Njp1=C_Vec2d(Noeud_F_j,Noeud_F_jp1);
            double Dist_Nj_Njp1=Nj_Njp1.Magnitude();
            Nj_Njp1/=Dist_Nj_Njp1;
        
            long Ind_Noeud_Cellule_Temp=Ind_Noeud_F_j;
            C_Cellule Cellule_Temp=Cellule_F_j;
            list<S_Arete>::iterator k=Cellule_Temp.P_List_Arete->end();
            k--;
            S_Arete Arete_Temp=(*k);
        
            double PrV_1=Nj_Njp1^C_Vec2d(Noeud_F_j,List_Sommet[Arete_Temp.Ind_Sommet[0]].Coord_Sommet);
            
            if(PrV_1<=0.)
            {
                S_Pnt_Int Nouveau_Pnt_Int;
                Nouveau_Pnt_Int.Ind_Noeud[0]=Ind_Noeud_F_j;
                Nouveau_Pnt_Int.Ind_Noeud[1]=Ind_Noeud_F_jp1;
                Nouveau_Pnt_Int.Landa=0.5;
                Nouveau_Pnt_Int.Coord_Pnt_Int.SetCoord((Noeud_F_j.X()+Noeud_F_jp1.X())/2.,(Noeud_F_j.Y()+Noeud_F_jp1.Y())/2.);
                List_Pnt_Int.push_back(Nouveau_Pnt_Int);
                long Ind_Pnt_Int=List_Pnt_Int.size()-1;

                if(j==0)
                {
                    SICF_Ini.Ind_Pnt_Int[1]=Ind_Pnt_Int;
                    SICF_Ini.Iter[1]=k;
                }
                else
                {
                    SICF_Temp.Ind_Pnt_Int[1]=Ind_Pnt_Int;
                    SICF_Temp.Iter[1]=k;
                                
                    List_SICF.push_back(SICF_Temp);
                }

                if(j==(Nb_Noeud_Frontiere-1))
                {
                    SICF_Ini.Ind_Pnt_Int[0]=Ind_Pnt_Int;
                    SICF_Ini.Iter[0]=Cellule_F_jp1.P_List_Arete->begin();
                    
                    List_SICF.push_back(SICF_Ini);
                }
                else
                {
                    SICF_Temp.Ind_Noeud=Ind_Noeud_F_jp1;
                    SICF_Temp.Type=0;
                    SICF_Temp.Ind_Pnt_Int[0]=Ind_Pnt_Int;
                    SICF_Temp.Iter[0]=Cellule_F_jp1.P_List_Arete->begin();
                }
            }
            else
            {
                bool b_0=1;
                do
                {
                    bool b_1=1;
                    do
                    {
                        bool Intersect=0;
                        double Landa;

                        if(k==Cellule_Temp.P_List_Arete->begin())
                            k=Cellule_Temp.P_List_Arete->end();
                        k--;
                         Arete_Temp=(*k);
                                            
                        if(List_Sommet[Arete_Temp.Ind_Sommet[0]].Sommet_Infini)
                        {
                            Intersect=1;
                            
                            C_Vec2d Per_Dir_Inf;
                            if(List_Sommet[Arete_Temp.Ind_Sommet[0]].Ind_Noeud[0]==-1)
                                Per_Dir_Inf=C_Vec2d(List_Noeud[List_Sommet[Arete_Temp.Ind_Sommet[0]].Ind_Noeud[1]],List_Noeud[List_Sommet[Arete_Temp.Ind_Sommet[0]].Ind_Noeud[2]]);
                            else
                            {
                                if(List_Sommet[Arete_Temp.Ind_Sommet[0]].Ind_Noeud[1]==-1)
                                    Per_Dir_Inf=C_Vec2d(List_Noeud[List_Sommet[Arete_Temp.Ind_Sommet[0]].Ind_Noeud[2]],List_Noeud[List_Sommet[Arete_Temp.Ind_Sommet[0]].Ind_Noeud[0]]);
                                else
                                    Per_Dir_Inf=C_Vec2d(List_Noeud[List_Sommet[Arete_Temp.Ind_Sommet[0]].Ind_Noeud[0]],List_Noeud[List_Sommet[Arete_Temp.Ind_Sommet[0]].Ind_Noeud[1]]);
                            }

                            Landa=(C_Vec2d(Noeud_F_j,List_Sommet[Arete_Temp.Ind_Sommet[1]].Coord_Sommet)*Per_Dir_Inf)/((Nj_Njp1*Per_Dir_Inf)*Dist_Nj_Njp1);
                        }
                        else
                        {
                            C_Vec2d Nj_S0(Noeud_F_j,List_Sommet[Arete_Temp.Ind_Sommet[0]].Coord_Sommet);
                            double PrV_0=Nj_Njp1^Nj_S0;
                            if(PrV_0<=0.)
                            {
                                Intersect=1;
                                 Landa=(Nj_S0^C_Vec2d(List_Sommet[Arete_Temp.Ind_Sommet[0]].Coord_Sommet,List_Sommet[Arete_Temp.Ind_Sommet[1]].Coord_Sommet))/(Dist_Nj_Njp1*(PrV_1-PrV_0));
                            }
                            else
                                PrV_1=PrV_0;
                        }

                        if(Intersect)
                        {
                            S_Pnt_Int Nouveau_Pnt_Int;
                            Nouveau_Pnt_Int.Ind_Noeud[0]=Ind_Noeud_F_j;
                             Nouveau_Pnt_Int.Ind_Noeud[1]=Ind_Noeud_F_jp1;
                            Nouveau_Pnt_Int.Landa=Landa;
                              Nouveau_Pnt_Int.Coord_Pnt_Int.SetCoord(Noeud_F_j.X()+Landa*Dist_Nj_Njp1*Nj_Njp1.X(),Noeud_F_j.Y()+Landa*Dist_Nj_Njp1*Nj_Njp1.Y());
                             List_Pnt_Int.push_back(Nouveau_Pnt_Int);
                            long Ind_Pnt_Int=List_Pnt_Int.size()-1;


                            if((j==0)&&(Ind_Noeud_Cellule_Temp==Ind_Noeud_F_j))
                            {
                                SICF_Ini.Ind_Pnt_Int[1]=Ind_Pnt_Int;
                                 SICF_Ini.Iter[1]=k;
                            }
                            else
                            {
                                SICF_Temp.Ind_Pnt_Int[1]=Ind_Pnt_Int;
                                  SICF_Temp.Iter[1]=k;
                                
                                  List_SICF.push_back(SICF_Temp);
                            }

                            long Prev_Ind_Noeud_Cellule_Temp=Ind_Noeud_Cellule_Temp;
                            Ind_Noeud_Cellule_Temp=Arete_Temp.Ind_Noeud;
                            Cellule_Temp=List_Cellule[Ind_Noeud_Cellule_Temp];
                            for(k=Cellule_Temp.P_List_Arete->begin();k!=Cellule_Temp.P_List_Arete->end();k++)
                            {
                                Arete_Temp=(*k);
                                if(Arete_Temp.Ind_Noeud==Prev_Ind_Noeud_Cellule_Temp)
                                       break;
                            }

                            if(j==(Nb_Noeud_Frontiere-1))
                            {
                                if(Ind_Noeud_Cellule_Temp==Ind_Noeud_F_jp1)
                                {
                                    SICF_Ini.Ind_Pnt_Int[0]=Ind_Pnt_Int;
                                     SICF_Ini.Iter[0]=k;
                                    
                                    List_SICF.push_back(SICF_Ini);
                                    
                                    b_0=0;
                                }
                                else
                                {
                                    SICF_Temp.Ind_Noeud=Ind_Noeud_Cellule_Temp;
                                    SICF_Temp.Type=1;
                                    SICF_Temp.Ind_Pnt_Int[0]=Ind_Pnt_Int;
                                    SICF_Temp.Iter[0]=k;
                                }
                            }
                            else
                            {
                                if(Ind_Noeud_Cellule_Temp==Ind_Noeud_F_jp1)
                                {
                                    SICF_Temp.Type=0;
                                    b_0=0;
                                }
                                else
                                    SICF_Temp.Type=1;

                                 SICF_Temp.Ind_Noeud=Ind_Noeud_Cellule_Temp;
                                SICF_Temp.Ind_Pnt_Int[0]=Ind_Pnt_Int;
                                SICF_Temp.Iter[0]=k;
                            }
                                                    
                            b_1=0;
                        }
                     }while(b_1);
                }while(b_0);
            }

             Ind_Noeud_F_j=Ind_Noeud_F_jp1;
            Noeud_F_j=Noeud_F_jp1;
            Cellule_F_j=Cellule_F_jp1;
        }
    }

    //-----------------------------------------------------------------------//

    while(!List_SICF.empty())
    {
        list<S_Int_Cel_Front> List_SICF_Temp;
        S_Int_Cel_Front SICF_Temp=List_SICF.back();
        List_SICF.pop_back();
        List_SICF_Temp.push_back(SICF_Temp);

        long Ind_Noeud=SICF_Temp.Ind_Noeud;
        
        list<S_Int_Cel_Front>::iterator j;
        for(j=List_SICF.begin();j!=List_SICF.end();)
        {
            SICF_Temp=(*j);
            if(SICF_Temp.Ind_Noeud==Ind_Noeud)
            {
                List_SICF_Temp.push_back(SICF_Temp);
                list<S_Int_Cel_Front>::iterator k=j;
                j++;
                List_SICF.erase(k);
            }else j++;
        }

        vector<S_Som_Cel_Front>* P_List_SSCF = new vector<S_Som_Cel_Front>;

        SICF_Temp=List_SICF_Temp.back();
        List_SICF_Temp.pop_back();
        
        list<S_Arete>::iterator k_Ini=SICF_Temp.Iter[0];
        list<S_Arete>::iterator k_Fin=SICF_Temp.Iter[1];
        
        S_Som_Cel_Front SSCF_Temp;
        
        SSCF_Temp.Type=1;
        SSCF_Temp.Index=SICF_Temp.Ind_Pnt_Int[1];
        P_List_SSCF->push_back(SSCF_Temp);
    
        if(!SICF_Temp.Type)
        {
            SSCF_Temp.Type=2;
            SSCF_Temp.Index=-1;
            P_List_SSCF->push_back(SSCF_Temp);
        }

        SSCF_Temp.Type=1;
        SSCF_Temp.Index=SICF_Temp.Ind_Pnt_Int[0];
        P_List_SSCF->push_back(SSCF_Temp);

        while(k_Ini!=k_Fin)
        {
            bool b=1;
            for(j=List_SICF_Temp.begin();j!=List_SICF_Temp.end();j++)
            {
                SICF_Temp=(*j);
                if(SICF_Temp.Iter[1]==k_Ini)
                {
                    SSCF_Temp.Type=1;
                     SSCF_Temp.Index=SICF_Temp.Ind_Pnt_Int[1];
                      P_List_SSCF->push_back(SSCF_Temp);

                    if(!SICF_Temp.Type)
                    {
                        SSCF_Temp.Type=2;
                          SSCF_Temp.Index=-1;
                         P_List_SSCF->push_back(SSCF_Temp);
                    }

                     SSCF_Temp.Type=1;
                    SSCF_Temp.Index=SICF_Temp.Ind_Pnt_Int[0];
                    P_List_SSCF->push_back(SSCF_Temp);

                    k_Ini=SICF_Temp.Iter[0];

                    b=0;
                    break;
                }
            }

            if(b)
            {
                S_Arete Arete_Temp=(*k_Ini);

                SSCF_Temp.Type=0;
                 SSCF_Temp.Index=Arete_Temp.Ind_Sommet[1];
                 P_List_SSCF->push_back(SSCF_Temp);

                k_Ini++;
                if(k_Ini==List_Cellule[Ind_Noeud].P_List_Arete->end())
                    k_Ini=List_Cellule[Ind_Noeud].P_List_Arete->begin();
            }
        }

        S_Cel_Front SCF_Temp;
        SCF_Temp.Ind_Noeud=Ind_Noeud;
        SCF_Temp.P_List_SSCF=P_List_SSCF;

        List_S_Cel_Front.push_back(SCF_Temp);
    }

    //-----------------------------------------------------------------------//

    vector<bool> List_Bool_Temp;
    long Nb_Noeud=List_Noeud.size();
    for(i=0;i<Nb_Noeud;i++)
        List_Bool_Temp.push_back(1);

    long Nb_Cel_Front=List_S_Cel_Front.size();
    for(i=0;i<Nb_Cel_Front;i++)
        List_Bool_Temp[List_S_Cel_Front[i].Ind_Noeud]=0;

    for(i=0;i<Nb_Noeud;i++)
    {
        if(List_Bool_Temp[i])
            List_Ind_Cel_Interne.push_back(i);
    }

    //-----------------------------------------------------------------------//
}

//===========================================================================//
/*
long C_Meshless_2d::Recherche_Premeier_Sommet_a_Suprimer_Aleatoire(C_Pnt2d Noeud_a_Inserer)
{
    long Ind_Pr_S_a_Suprimer=-1;
    map<const long,S_Sommet>::iterator i;
    for(i=List_Sommet.begin();i!=List_Sommet.end();i++)
    {
        pair<const long,S_Sommet> Paire=(*i);
           if(!Paire.second.Sommet_Infini)
        {
            bool b=1;
            long j;
            for(j=0;j<3;j++)
            {
                C_Vec2d N_Tri_N_a_Inserer=C_Vec2d(List_Noeud[Paire.second.Ind_Noeud[j]],Noeud_a_Inserer);
                 C_Vec2d Arete_Tri=C_Vec2d(List_Noeud[Paire.second.Ind_Noeud[j]],
                                          List_Noeud[Paire.second.Ind_Noeud[(j+1)%3]]).Normalized();
        
                double PrV=N_Tri_N_a_Inserer^Arete_Tri;

                if(PrV>PRECISION_0) 
                {
                    b=0;
                    break;
                }
            }

            if(b)
            {
                Ind_Pr_S_a_Suprimer=Paire.first;
                break;
            }
        }
    }

    return Ind_Pr_S_a_Suprimer;
}
*/
//===========================================================================//

class gs_int_cel
{
public:
	C_Meshless_2d* p_ML;
	vector<S_Int_Grad_sur_Cel>* p_List_S_Int_Grad_sur_Cel;

public:
	gs_int_cel(C_Meshless_2d* p_ML_,vector<S_Int_Grad_sur_Cel>* p_List_S_Int_Grad_sur_Cel_):p_ML(p_ML_),
		p_List_S_Int_Grad_sur_Cel(p_List_S_Int_Grad_sur_Cel_){}

	void operator()(const blocked_range<size_t>& r)const
    {
		for(size_t i=r.begin();i!=r.end();++i)
		{
			vector<C_Pnt2d> List_Sommet_Cellule;

			C_Cellule Cellule=p_ML->List_Cellule[p_ML->List_Ind_Cel_Interne[i]];
			C_Pnt2d Noeud_Cellule=p_ML->List_Noeud[p_ML->List_Ind_Cel_Interne[i]];
			S_Int_Grad_sur_Cel& Ref_SIGsC=p_List_S_Int_Grad_sur_Cel->at(p_ML->List_Ind_Cel_Interne[i]);
        
			C_Pnt2d P_0=p_ML->List_Sommet[Cellule.P_List_Arete->front().Ind_Sommet[0]].Coord_Sommet;
			list<S_Arete>::iterator j;
			for(j=Cellule.P_List_Arete->begin();j!=Cellule.P_List_Arete->end();j++)
			{
				S_Arete Arete=(*j);
				C_Pnt2d P_1=p_ML->List_Sommet[Arete.Ind_Sommet[1]].Coord_Sommet;

				List_Sommet_Cellule.push_back(P_0);
            
				C_Vec2d P0_P1(P_0,P_1);
            
				if(P0_P1.Magnitude()<p_ML->PRECISION_0)
				{
					P_0=P_1;
					continue;
				}

				C_Vec2d Normale_Arete(P0_P1.Y(),-P0_P1.X());
            
				C_Pnt2d Point_d_Integration((P_0.X()+P_1.X())/2.,(P_0.Y()+P_1.Y())/2.);

				long Ind_Pr_S_a_Suprimer=p_ML->Recherche_Premeier_Sommet_a_Suprimer_dans_Cellule(Point_d_Integration,Noeud_Cellule,Cellule);
				vector<S_FoFo> List_SFoFo;
				p_ML->Fonction_de_Forme_et_Gradiant_de_Fonction_de_Forme(Point_d_Integration,Ind_Pr_S_a_Suprimer,&List_SFoFo);

				long Nb_Contribution=Ref_SIGsC.P_List_Contribution->size();
				long Nb_FoFo=List_SFoFo.size();
				long k;
				for(k=0;k<Nb_FoFo;k++)
				{
					bool b=1;
					long l;
					for(l=0;l<Nb_Contribution;l++)
					{
						S_Contribution_IGsC& Ref_Contribution=Ref_SIGsC.P_List_Contribution->at(l);
						if(List_SFoFo[k].Ind_Voisin==Ref_Contribution.Ind_Voisin)
						{
							Ref_Contribution.Contribution+=Normale_Arete*List_SFoFo[k].Valeur_FF;
							b=0;
							break;
						}
					}
					if(b)
					{
						S_Contribution_IGsC Nouvelle_Contribution;
						Nouvelle_Contribution.Ind_Voisin=List_SFoFo[k].Ind_Voisin;
						Nouvelle_Contribution.Contribution=Normale_Arete*List_SFoFo[k].Valeur_FF;
						Ref_SIGsC.P_List_Contribution->push_back(Nouvelle_Contribution);
					}
				}
				P_0=P_1;
			}

			Ref_SIGsC.Aire_Cellule=p_ML->Calcul_Aire_Polygone(&List_Sommet_Cellule);
			Ref_SIGsC.CdM=p_ML->Calcul_CdM_Polygone(&List_Sommet_Cellule);
		}
    }
};

void C_Meshless_2d::Integration_Stabilisee
(vector<size_t>* P_Nb_Voisin,vector<double>* P_Aire_Cellule,vector<double>* P_XY_CdM,
 vector<size_t>* P_Ind_Voisin,vector<double>* P_Contribution_XY)
{
//	ofstream data0("cel_0.dat");
//	ofstream data1("cel_1.dat");

    vector<S_Int_Grad_sur_Cel> List_S_Int_Grad_sur_Cel;

    long Nb_Cel_Interne=List_Ind_Cel_Interne.size();
    long Nb_Cel_Front=List_S_Cel_Front.size();
    long Nb_Cellule=Nb_Cel_Interne+Nb_Cel_Front;
    
    long i;
    for(i=0;i<Nb_Cellule;i++)
    {
        S_Int_Grad_sur_Cel SIGsC_Temp;
        SIGsC_Temp.Aire_Cellule=0.;
        SIGsC_Temp.P_List_Contribution = new vector<S_Contribution_IGsC>;
        List_S_Int_Grad_sur_Cel.push_back(SIGsC_Temp);
    }

    //-----------------------------------------------------------------------//
	
	size_t Grain_Size=task_scheduler_init::default_num_threads();//thread::hardware_concurrency();

	cout<<"\nnb worker thread : "<<Grain_Size<<"\n";

	parallel_for(blocked_range<size_t>(0,Nb_Cel_Interne,Grain_Size),gs_int_cel(this,&List_S_Int_Grad_sur_Cel));
	
    //--------------------------------------------------------------------------------//

    for(i=0;i<Nb_Cel_Front;i++)
    {
        vector<C_Pnt2d> List_Sommet_Cellule;

        S_Cel_Front SCF_Temp=List_S_Cel_Front[i];
        S_Int_Grad_sur_Cel& Ref_SIGsC=List_S_Int_Grad_sur_Cel[SCF_Temp.Ind_Noeud];
        C_Pnt2d Noeud_Cellule=List_Noeud[SCF_Temp.Ind_Noeud];
        C_Cellule Cellule=List_Cellule[SCF_Temp.Ind_Noeud];

        long Nb_SSCF=SCF_Temp.P_List_SSCF->size();
        
        S_Som_Cel_Front SSCF_0=SCF_Temp.P_List_SSCF->at(Nb_SSCF-1);
        C_Pnt2d P_0;
        if(SSCF_0.Type==0)
            P_0=List_Sommet[SSCF_0.Index].Coord_Sommet;
        else
        {
            if(SSCF_0.Type==1)
                P_0=List_Pnt_Int[SSCF_0.Index].Coord_Pnt_Int;
            else
                P_0=Noeud_Cellule;
        }
        
        long j;
        for(j=0;j<Nb_SSCF;j++)
        {
            List_Sommet_Cellule.push_back(P_0);
            
            bool PI_sur_Frontiere=0;
            double Landa;
            S_Contribution_IGsC Contribution_sur_Frontiere[2];
                        
            S_Som_Cel_Front SSCF_1=SCF_Temp.P_List_SSCF->at(j);;
            C_Pnt2d P_1;
            if(SSCF_1.Type==0)
                P_1=List_Sommet[SSCF_1.Index].Coord_Sommet;
            else
            {
                if(SSCF_1.Type==1)
                {
                    P_1=List_Pnt_Int[SSCF_1.Index].Coord_Pnt_Int;
                                        
                    if(SSCF_0.Type==1)
                    {// Type1-Type1
                            
                        if(List_Pnt_Int[SSCF_0.Index].Ind_Noeud[0]==List_Pnt_Int[SSCF_1.Index].Ind_Noeud[0])
                        {// les 2 point d'intersection sont sur la meme arete de la frontiere
                            PI_sur_Frontiere=1;
                            Landa=(List_Pnt_Int[SSCF_0.Index].Landa+List_Pnt_Int[SSCF_1.Index].Landa)/2.;
                            Contribution_sur_Frontiere[0].Ind_Voisin=List_Pnt_Int[SSCF_0.Index].Ind_Noeud[0];
                            Contribution_sur_Frontiere[1].Ind_Voisin=List_Pnt_Int[SSCF_0.Index].Ind_Noeud[1];
                        }
                    }
                    else
                    {
                        if(SSCF_0.Type==2)
                        {// Type2-Type1
                            PI_sur_Frontiere=1;
                            Landa=(1+List_Pnt_Int[SSCF_1.Index].Landa)/2.;
                            Contribution_sur_Frontiere[0].Ind_Voisin=List_Pnt_Int[SSCF_1.Index].Ind_Noeud[0];
                            Contribution_sur_Frontiere[1].Ind_Voisin=List_Pnt_Int[SSCF_1.Index].Ind_Noeud[1];
                        }
                    }
                }
                else
                {// Type1-Type2

                    P_1=Noeud_Cellule;
                    
                    PI_sur_Frontiere=1;
                    Landa=List_Pnt_Int[SSCF_0.Index].Landa/2.;
                    Contribution_sur_Frontiere[0].Ind_Voisin=List_Pnt_Int[SSCF_0.Index].Ind_Noeud[0];
                    Contribution_sur_Frontiere[1].Ind_Voisin=List_Pnt_Int[SSCF_0.Index].Ind_Noeud[1];
                }
            }
            
            C_Vec2d P0_P1(P_0,P_1);
            
            if(P0_P1.Magnitude()<PRECISION_0)
            {
                SSCF_0=SSCF_1;
                P_0=P_1;
                continue;
            }
            
            C_Vec2d Normale_Arete(P0_P1.Y(),-P0_P1.X());
                                        
            if(PI_sur_Frontiere)
            {
                Contribution_sur_Frontiere[0].Contribution=Normale_Arete*(1-Landa);
                Contribution_sur_Frontiere[1].Contribution=Normale_Arete*Landa;
                 
                long Nb_Contribution=Ref_SIGsC.P_List_Contribution->size();
                long k;
                for(k=0;k<2;k++)
                {
                    bool b=1;
                    long l;
                    for(l=0;l<Nb_Contribution;l++)
                    {
                        S_Contribution_IGsC& Ref_Contribution=Ref_SIGsC.P_List_Contribution->at(l);
                        if(Contribution_sur_Frontiere[k].Ind_Voisin==Ref_Contribution.Ind_Voisin)
                        {
                            Ref_Contribution.Contribution+=Contribution_sur_Frontiere[k].Contribution;
                            b=0;
                            break;
                        }
                    }

                    if(b)
                        Ref_SIGsC.P_List_Contribution->push_back(Contribution_sur_Frontiere[k]);
                }
            }
            else
            {

                C_Pnt2d Point_d_Integration((P_0.X()+P_1.X())/2.,(P_0.Y()+P_1.Y())/2.);

                long Ind_Pr_S_a_Suprimer=Recherche_Premeier_Sommet_a_Suprimer_dans_Cellule(Point_d_Integration,Noeud_Cellule,Cellule);
				if(Ind_Pr_S_a_Suprimer==-1)exit(1);

                vector<S_FoFo> List_SFoFo;
                Fonction_de_Forme_et_Gradiant_de_Fonction_de_Forme(Point_d_Integration,Ind_Pr_S_a_Suprimer,&List_SFoFo);

                long Nb_Contribution=Ref_SIGsC.P_List_Contribution->size();
                long Nb_FoFo=List_SFoFo.size();
                long k;
                for(k=0;k<Nb_FoFo;k++)
                {
                    bool b=1;
                    long l;
                    for(l=0;l<Nb_Contribution;l++)
                    {
                        S_Contribution_IGsC& Ref_Contribution=Ref_SIGsC.P_List_Contribution->at(l);
                        if(List_SFoFo[k].Ind_Voisin==Ref_Contribution.Ind_Voisin)
                        {
                            Ref_Contribution.Contribution+=Normale_Arete*List_SFoFo[k].Valeur_FF;
                            b=0;
                            break;
                        }
                    }

                    if(b)
                    {
                        S_Contribution_IGsC Nouvelle_Contribution;
                        Nouvelle_Contribution.Ind_Voisin=List_SFoFo[k].Ind_Voisin;
                        Nouvelle_Contribution.Contribution=Normale_Arete*List_SFoFo[k].Valeur_FF;
                        Ref_SIGsC.P_List_Contribution->push_back(Nouvelle_Contribution);
                    }
                }
            }
            
            SSCF_0=SSCF_1;
            P_0=P_1;
        }
        
        Ref_SIGsC.Aire_Cellule=Calcul_Aire_Polygone(&List_Sommet_Cellule);
        Ref_SIGsC.CdM=Calcul_CdM_Polygone(&List_Sommet_Cellule);

//		data0<<List_Sommet_Cellule.size()<<endl;
//		for(j=0;j<List_Sommet_Cellule.size();j++)data1<<List_Sommet_Cellule[j].X()<<' '<<List_Sommet_Cellule[j].Y()<<endl;
    }

//	data0.close();
//	data1.close();

    for(i=0;i<Nb_Cellule;i++)
    {
        S_Int_Grad_sur_Cel SIGsC=List_S_Int_Grad_sur_Cel[i];
        
        P_Aire_Cellule->push_back(SIGsC.Aire_Cellule);

        P_XY_CdM->push_back(SIGsC.CdM.X());
        P_XY_CdM->push_back(SIGsC.CdM.Y());

        long Nb_Contribution=SIGsC.P_List_Contribution->size();

        P_Nb_Voisin->push_back(Nb_Contribution);

        long j;
        for(j=0;j<Nb_Contribution;j++)
        {
            P_Ind_Voisin->push_back(SIGsC.P_List_Contribution->at(j).Ind_Voisin);
            P_Contribution_XY->push_back(SIGsC.P_List_Contribution->at(j).Contribution.X()/SIGsC.Aire_Cellule);
            P_Contribution_XY->push_back(SIGsC.P_List_Contribution->at(j).Contribution.Y()/SIGsC.Aire_Cellule);
        }

        delete SIGsC.P_List_Contribution;
    }
}

//===========================================================================//

void C_Meshless_2d::Sortie_Cellule_VC
(vector<size_t>* P_Ind_Noeud_Cel,
 vector<size_t>* P_Nb_S_Cel,
 vector<double>* P_S_Cel)
{
    long Nb_Cel_Interne=List_Ind_Cel_Interne.size();
    long Nb_Cel_Front=List_S_Cel_Front.size();
    long Nb_Cellule=Nb_Cel_Interne+Nb_Cel_Front;
    
    long i;        
    for(i=0;i<Nb_Cel_Interne;i++)
    {
        C_Cellule Cellule=List_Cellule[List_Ind_Cel_Interne[i]];
        C_Pnt2d Noeud_Cellule=List_Noeud[List_Ind_Cel_Interne[i]];

        P_Ind_Noeud_Cel->push_back(List_Ind_Cel_Interne[i]);

        P_Nb_S_Cel->push_back(Cellule.P_List_Arete->size());

        list<S_Arete>::iterator j;
        for(j=Cellule.P_List_Arete->begin();j!=Cellule.P_List_Arete->end();j++)
        {
            S_Arete Arete=(*j);
            C_Pnt2d S_j=List_Sommet[Arete.Ind_Sommet[0]].Coord_Sommet;
            P_S_Cel->push_back(S_j.X());
            P_S_Cel->push_back(S_j.Y());
        }
    }
    
    //--------------------------------------------------------------------------------//

    for(i=0;i<Nb_Cel_Front;i++)
    {
        S_Cel_Front SCF_Temp=List_S_Cel_Front[i];
        C_Pnt2d Noeud_Cellule=List_Noeud[SCF_Temp.Ind_Noeud];
        C_Cellule Cellule=List_Cellule[SCF_Temp.Ind_Noeud];
        
        P_Ind_Noeud_Cel->push_back(SCF_Temp.Ind_Noeud);
        
        long Nb_SSCF=SCF_Temp.P_List_SSCF->size();

        P_Nb_S_Cel->push_back(Nb_SSCF);

           long j;
        for(j=0;j<Nb_SSCF;j++)
        {                                    
            S_Som_Cel_Front SSCF_j=SCF_Temp.P_List_SSCF->at(j);;
            C_Pnt2d S_j;
            if(SSCF_j.Type==0)
                S_j=List_Sommet[SSCF_j.Index].Coord_Sommet;
            else
            {
                if(SSCF_j.Type==1)
                {
                    S_j=List_Pnt_Int[SSCF_j.Index].Coord_Pnt_Int;
                }
                else
                {// Type1-Type2

                    S_j=Noeud_Cellule;
                }
            }
            P_S_Cel->push_back(S_j.X());
            P_S_Cel->push_back(S_j.Y());
        }
    }
}

void C_Meshless_2d::Interpolation_point(
size_t Nb_PntInt,double* P_XY_PntInt,size_t* P_Close_Node,
vector<size_t>* P_Vec_Nb_Contrib,
vector<size_t>* P_Vec_INV,
vector<double>* P_Vec_Phi
/*,vector<double>* P_Vec_Gard*/)
{
	size_t Nb_Front=List_P_Frontiere.size();
	C_Meshless_2d** Tab_PML=(C_Meshless_2d**)malloc(sizeof(C_Meshless_2d*)*(Nb_Front+1));
    Tab_PML[0]=this;

    size_t i;
    for(i=0;i<Nb_Front;i++)
    {
        size_t Nb_Noeud_i=Tab_PML[0]->List_P_Frontiere[i]->size();
        size_t Nb_Noeud_Front_i=Nb_Noeud_i;
        double* P_XY_Noeud_i=(double*)malloc(sizeof(double)*2*Nb_Noeud_i);
        size_t* P_Ind_Noeud_Front_i=(size_t*)malloc(sizeof(size_t)*Nb_Noeud_i);
        size_t j;
        for(j=0;j<Nb_Noeud_Front_i;j++)
        {
            P_Ind_Noeud_Front_i[j]=j;
            C_Pnt2d Noeud_j=Tab_PML[0]->List_Noeud[Tab_PML[0]->List_P_Frontiere[i]->at(Nb_Noeud_Front_i-1-j)];
            P_XY_Noeud_i[2*j]=Noeud_j.X();
            P_XY_Noeud_i[2*j+1]=Noeud_j.Y();
        }

        Tab_PML[i+1]=new C_Meshless_2d(Nb_Noeud_i,P_XY_Noeud_i,1,&Nb_Noeud_Front_i,P_Ind_Noeud_Front_i);
        Tab_PML[i+1]->Voronoi_Non_Contrain();
        Tab_PML[i+1]->Voronoi_Contrain();  

        for(j=0;j<Nb_Noeud_Front_i;j++)
        {
            C_Cellule C0=Tab_PML[0]->List_Cellule[Tab_PML[0]->List_P_Frontiere[i]->at(j)];
            C_Cellule C1=Tab_PML[i+1]->List_Cellule[Tab_PML[i+1]->List_P_Frontiere[0]->at(Nb_Noeud_Front_i-1-j)];

            S_Arete Af_C0=C0.P_List_Arete->front();
            S_Arete Ab_C1=C1.P_List_Arete->back();

            S_Sommet& Ref_S0_Cel0=Tab_PML[0]->List_Sommet[Af_C0.Ind_Sommet[0]];
            S_Sommet& Ref_S1_Cel1=Tab_PML[i+1]->List_Sommet[Ab_C1.Ind_Sommet[1]];

            Ref_S0_Cel0.Ind_MExt=i+1;
            Ref_S0_Cel0.Ind_SExt=Ab_C1.Ind_Sommet[0];

            Ref_S1_Cel1.Ind_MExt=0;
            Ref_S1_Cel1.Ind_SExt=Af_C0.Ind_Sommet[1];
        }

        free(P_XY_Noeud_i);
        free(P_Ind_Noeud_Front_i);
    }

    //-----------------------------------------------------------------------//

    cout<<endl;
    long Nb_C_Nb=-1;
    for(i=0;i<Nb_PntInt;i++)
    {
        long I=100.*double(i)/double(Nb_PntInt);
        if(!(I%5))
        {
            char Char[255];sprintf(Char,"%d",I);string Nb(Char);long J;for(J=0;J<=Nb_C_Nb;J++)cout<<"\b";Nb_C_Nb=Nb.size();cout<<I<<'%';cout.flush();
        }

        C_Pnt2d X(P_XY_PntInt[2*i],P_XY_PntInt[2*i+1]);
        
        long Ind_M=0;
        long Ind_Sommet_Temp=(P_Close_Node==NULL)?-1:Tab_PML[0]->List_Cellule[P_Close_Node[i]].P_List_Arete->front().Ind_Sommet[1];
    
        bool ok=0;
        long Pnt_sur_Arete_Noeud;
        long Ind_PaS;
        do
        {
            Ind_PaS=Tab_PML[Ind_M]->Descente_Gradiant(Ind_Sommet_Temp,X,Pnt_sur_Arete_Noeud);
            S_Sommet PaS=Tab_PML[Ind_M]->List_Sommet[Ind_PaS];
            if(PaS.Sommet_Infini)
            {
                if(PaS.Ind_MExt!=-1)
                {
                    Ind_M=PaS.Ind_MExt;
                    Ind_Sommet_Temp=PaS.Ind_SExt;    
                }
                else break;
            }
            else 
            {
                if(Ind_M==0)ok=1;
                break;
            }
        }while(1);

        if(ok)
        {
            if(Pnt_sur_Arete_Noeud!=0)
            {
                if(Pnt_sur_Arete_Noeud>0)
                {
                    Pnt_sur_Arete_Noeud-=1;

                    S_Sommet PaS=Tab_PML[Ind_M]->List_Sommet[Ind_PaS];
                    long Ind_Noeud_a=PaS.Ind_Noeud[Pnt_sur_Arete_Noeud];
                    long Ind_Noeud_b=PaS.Ind_Noeud[(Pnt_sur_Arete_Noeud+1)%3]; 

                    double FF_b=C_Vec2d(Tab_PML[Ind_M]->List_Noeud[Ind_Noeud_a],X).Magnitude()/
                                C_Vec2d(Tab_PML[Ind_M]->List_Noeud[Ind_Noeud_a],Tab_PML[Ind_M]->List_Noeud[Ind_Noeud_b]).Magnitude();

                    double FF_a=1-FF_b;

                    P_Vec_Nb_Contrib->push_back(2);
                    P_Vec_INV->push_back(Ind_Noeud_a);
                    P_Vec_INV->push_back(Ind_Noeud_b);
                    P_Vec_Phi->push_back(FF_a);
                    P_Vec_Phi->push_back(FF_b);
                }
                else
                {
                    Pnt_sur_Arete_Noeud=-Pnt_sur_Arete_Noeud-1;
                    P_Vec_Nb_Contrib->push_back(1);
                    P_Vec_INV->push_back(Pnt_sur_Arete_Noeud);
                    P_Vec_Phi->push_back(1.);
                }
            }
            else
            {
                vector<S_FoFo> List_PSFoFo;
                Tab_PML[Ind_M]->Fonction_de_Forme_et_Gradiant_de_Fonction_de_Forme
                    (X,Ind_PaS,&List_PSFoFo);
				
				if(!List_PSFoFo.empty())
				{                
					P_Vec_Nb_Contrib->push_back(List_PSFoFo.size());
					vector<S_FoFo>::iterator j;
					for(j=List_PSFoFo.begin();j!=List_PSFoFo.end();j++)
					{
						S_FoFo FF_j=*j;
						P_Vec_INV->push_back(FF_j.Ind_Voisin);
						P_Vec_Phi->push_back(FF_j.Valeur_FF);
					}
				}
				else
				{
					S_Sommet PaS=Tab_PML[Ind_M]->List_Sommet[Ind_PaS];
                    long i_npp;
					double d_npp;
					long j;
					for(j=0;j<3;j++)
					{
						double d_njx=C_Vec2d(Tab_PML[Ind_M]->List_Noeud[PaS.Ind_Noeud[j]],X).Magnitude();
						if((j==0)||(d_njx<d_npp))
						{
							i_npp=j;
							d_npp=d_njx;
						}
					}

					P_Vec_Nb_Contrib->push_back(1);
					P_Vec_INV->push_back(PaS.Ind_Noeud[i_npp]);
					P_Vec_Phi->push_back(1.);
				}
            }
        }
        else P_Vec_Nb_Contrib->push_back(0);
    }

    //cout<<endl;    

	//-----------------------------------------------------------------------//

    for(i=1;i<Nb_Front;i++)delete Tab_PML[i];
    free(Tab_PML);
}

//---------------------------------------------------------------------------//

void C_Meshless_2d::Construction_Base()
{
    Voronoi_Non_Contrain();
    Voronoi_Contrain();    
    Intersection_Voronoi_Contrain_avec_Frontiere();
}

void C_Meshless_2d::Integration_Stabilisee(S_Grad_Stab* P_GS)
{
    Integration_Stabilisee(&P_GS->Nb_Voisin,&P_GS->Aire_Cellule,&P_GS->XY_CdM,&P_GS->Ind_Voisin,&P_GS->Contribution_XY);

    long Nb_Contribution_Max=0;
    P_GS->Id_Voisin_0.push_back(0);
    size_t i;
    for(i=0;i<P_GS->Nb_Voisin.size();i++)
    {
        P_GS->Id_Voisin_0.push_back(P_GS->Id_Voisin_0.back()+P_GS->Nb_Voisin[i]);
        if(P_GS->Nb_Voisin[i]>Nb_Contribution_Max)Nb_Contribution_Max=P_GS->Nb_Voisin[i];
    }
    P_GS->Nb_Contribution_Max=Nb_Contribution_Max;
}

//---------------------------------------------------------------------------//
