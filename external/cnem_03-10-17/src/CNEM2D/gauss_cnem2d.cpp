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
#include "pnt_gauss_2d.h"
#include "mat_map.h"

//---------------------------------------------------------------------------//

void gauss_integration(
C_Meshless_2d* PML,
double** Tab_Vec_Coef,
long Ind_LPG,
long Axi,
bool Row_Major,
double Zero_Sparse,
Mat_Map** Tab_Map_Mat)
{
	long Nb_Noeud=PML->List_Noeud.size();
	
	bool b_0=0;
	bool b_1=0;
	bool b_2=0;
	
	if(Tab_Vec_Coef[0]!=NULL)
	{
		Tab_Map_Mat[0]=new Mat_Map;
		Tab_Map_Mat[0]->m_Size=Nb_Noeud;
		Tab_Map_Mat[0]->n_Size=Nb_Noeud;
		Tab_Map_Mat[0]->Row_Major=Row_Major;
		b_0=1;
	}

	if(Tab_Vec_Coef[1]!=NULL)
	{
		Tab_Map_Mat[1]=new Mat_Map;
		Tab_Map_Mat[1]->m_Size=Nb_Noeud;
		Tab_Map_Mat[1]->n_Size=Nb_Noeud;
		Tab_Map_Mat[1]->Row_Major=Row_Major;
		b_1=1;
	}

	if(Tab_Vec_Coef[2]!=NULL)
	{
		Tab_Map_Mat[2]=new Mat_Map;
		Tab_Map_Mat[2]->m_Size=3*Nb_Noeud;
		Tab_Map_Mat[2]->n_Size=3*Nb_Noeud;
		Tab_Map_Mat[2]->Row_Major=Row_Major;
		b_2=1;
	}

	//-----------------------------------------------------------------------//

	double pi2=2*acos(-1.);

	vector<S_Point_de_Gauss> Lists_SPoint_de_Gauss[8];
	Initialisation_Point_de_Gauss(Lists_SPoint_de_Gauss);

	vector<S_Point_de_Gauss>* P_List_SPoint_de_Gauss=&Lists_SPoint_de_Gauss[Ind_LPG];
	long Nb_Point_de_Gauss=P_List_SPoint_de_Gauss->size();

	//map<const long,S_Sommet>::iterator i;
	vector<S_Sommet>::iterator i;
	long Ind_S_i=0;
	for(i=PML->List_Sommet.begin();i!=PML->List_Sommet.end();i++)
	{
		//pair<const long,S_Sommet> Paire_i=(*i);
		S_Sommet S_i=(*i);
		if(S_i.Valide&&(!S_i.Sommet_Infini))
		{
			C_Pnt2d Noeud[3];

			Noeud[0]=PML->List_Noeud[S_i.Ind_Noeud[0]];
			Noeud[1]=PML->List_Noeud[S_i.Ind_Noeud[1]];
			Noeud[2]=PML->List_Noeud[S_i.Ind_Noeud[2]];

           	double Air_Triangle=(C_Vec2d(Noeud[0],Noeud[1])^C_Vec2d(Noeud[0],Noeud[2]))/2.;
			
	    	long j;
			for(j=0;j<Nb_Point_de_Gauss;j++)
			{
				S_Point_de_Gauss Point_de_Gauss_j=P_List_SPoint_de_Gauss->at(j);
	 			
	    		C_Pnt2d Point_d_Integration(
		    	Point_de_Gauss_j.Poids_Position[0]*Noeud[0].X()+Point_de_Gauss_j.Poids_Position[1]*Noeud[1].X()+Point_de_Gauss_j.Poids_Position[2]*Noeud[2].X(),
			    Point_de_Gauss_j.Poids_Position[0]*Noeud[0].Y()+Point_de_Gauss_j.Poids_Position[1]*Noeud[1].Y()+Point_de_Gauss_j.Poids_Position[2]*Noeud[2].Y());

				vector<S_FoFo> List_SFoFo;
		    	PML->Fonction_de_Forme_et_Gradiant_de_Fonction_de_Forme(Point_d_Integration,Ind_S_i,&List_SFoFo);
	         	
				long Nb_FoFo=List_SFoFo.size();

				if(b_0)//K Thermal
				{
					long id=0;

					long k;
					double kth_i=0.;
					for(k=0;k<Nb_FoFo;k++)kth_i+=Tab_Vec_Coef[id][PML->Vec_Ind_Noeud_Old_New[List_SFoFo[k].Ind_Voisin]]*List_SFoFo[k].Valeur_FF;

					double Coef=Air_Triangle*Point_de_Gauss_j.Poids;
					if(Axi==1)Coef*=pi2*Point_d_Integration.X();
					else if(Axi==2)Coef*=pi2*Point_d_Integration.Y();

					for(k=0;k<Nb_FoFo;k++)
					{
						long Ind_Voisin_k=List_SFoFo[k].Ind_Voisin;
						double dx_ff_k=List_SFoFo[k].Grad_FF.X();
						double dy_ff_k=List_SFoFo[k].Grad_FF.Y();

						long l;
						for(l=0;l<Nb_FoFo;l++)
						{
							long Ind_Voisin_l=List_SFoFo[l].Ind_Voisin;
							double dx_ff_l=List_SFoFo[l].Grad_FF.X();
							double dy_ff_l=List_SFoFo[l].Grad_FF.Y();

							double Contrib=Coef*kth_i*(dx_ff_k*dx_ff_l+dy_ff_k*dy_ff_l);
							
							if(fabs(Contrib)>Zero_Sparse)
							{
								pair<size_t,size_t> Index_Glob;
								if(Row_Major){Index_Glob.first=Ind_Voisin_k,Index_Glob.second=Ind_Voisin_l;}
								else{Index_Glob.first=Ind_Voisin_l,Index_Glob.second=Ind_Voisin_k;}
								 
								Map_KPL_D::iterator m=Tab_Map_Mat[id]->Mat.find(Index_Glob);
								if(m!=Tab_Map_Mat[id]->Mat.end())
								{
									pair<pair<size_t,size_t>const,double>& Ref_Paire_m=*m;
									Ref_Paire_m.second+=Contrib;
								}
								else
									Tab_Map_Mat[id]->Mat.insert(make_pair(Index_Glob,Contrib));
							}
						}
					}
				}

				if(b_1)//M Thermal
				{
					long id=1;

					long k;
					double roc_i=0.;
					for(k=0;k<Nb_FoFo;k++)roc_i+=Tab_Vec_Coef[id][PML->Vec_Ind_Noeud_Old_New[List_SFoFo[k].Ind_Voisin]]*List_SFoFo[k].Valeur_FF;

					double Coef=Air_Triangle*Point_de_Gauss_j.Poids;
					if(Axi==1)Coef*=pi2*Point_d_Integration.X();
					else if(Axi==2)Coef*=pi2*Point_d_Integration.Y();

					for(k=0;k<Nb_FoFo;k++)
					{
						long Ind_Voisin_k=List_SFoFo[k].Ind_Voisin;
						double ff_k=List_SFoFo[k].Valeur_FF;

						long l;
						for(l=0;l<Nb_FoFo;l++)
						{
							long Ind_Voisin_l=List_SFoFo[l].Ind_Voisin;
							double ff_l=List_SFoFo[l].Valeur_FF;

							double Contrib=Coef*roc_i*(ff_k*ff_l);
							
							//if(fabs(Contrib)>Zero_Sparse)
							{
								pair<size_t,size_t> Index_Glob;
								if(Row_Major){Index_Glob.first=Ind_Voisin_k,Index_Glob.second=Ind_Voisin_l;}
								else{Index_Glob.first=Ind_Voisin_l,Index_Glob.second=Ind_Voisin_k;}
								 
								Map_KPL_D::iterator m=Tab_Map_Mat[id]->Mat.find(Index_Glob);
								if(m!=Tab_Map_Mat[id]->Mat.end())
								{
									pair<pair<size_t,size_t>const,double>& Ref_Paire_m=*m;
									Ref_Paire_m.second+=Contrib;
								}
								else
									Tab_Map_Mat[id]->Mat.insert(make_pair(Index_Glob,Contrib));
							}
						}
					}
				}

				if(b_2)//K HydroDyn
				{
					double lambda_m1=(Tab_Vec_Coef[3]==NULL)?0.:1./(*Tab_Vec_Coef[3]);
					
					long id=2;

					long k;
					double Nuhd_i=0.;
					for(k=0;k<Nb_FoFo;k++)Nuhd_i+=Tab_Vec_Coef[id][PML->Vec_Ind_Noeud_Old_New[List_SFoFo[k].Ind_Voisin]]*List_SFoFo[k].Valeur_FF;

					long Ind_FF_Max=0;
					double dist_min=C_Vec2d(PML->List_Noeud[List_SFoFo[0].Ind_Voisin],Point_d_Integration).Magnitude();

					for(k=1;k<Nb_FoFo;k++)
					{
						//if(List_SFoFo[k].Valeur_FF>List_SFoFo[Ind_FF_Max].Valeur_FF)Ind_FF_Max=k;

						double dist=C_Vec2d(PML->List_Noeud[List_SFoFo[k].Ind_Voisin],Point_d_Integration).Magnitude();
						if(dist<dist_min)Ind_FF_Max=k;
					}
													 
					double coef_0=Air_Triangle*Point_de_Gauss_j.Poids;
					double coef_1=0.;
					double coef_2=0.;
					if(Axi==1){coef_0*=pi2*Point_d_Integration.X();coef_1=1./Point_d_Integration.X();coef_2=coef_1/Point_d_Integration.X();}
					else if(Axi==2){coef_0*=pi2*Point_d_Integration.Y();coef_1=1./Point_d_Integration.Y();coef_2=coef_1/Point_d_Integration.Y();}
					
					for(k=0;k<Nb_FoFo;k++)
					{
						long Ind_Voisin_k=List_SFoFo[k].Ind_Voisin;

						double dx_ff_UV_k=List_SFoFo[k].Grad_FF.X();
						double dy_ff_UV_k=List_SFoFo[k].Grad_FF.Y();
						double ff_UV_k=List_SFoFo[k].Valeur_FF;
						double ff_P_k=(k==Ind_FF_Max)?1.:0.; 

						long l;
						for(l=0;l<Nb_FoFo;l++)
						{
							long Ind_Voisin_l=List_SFoFo[l].Ind_Voisin;

							double dx_ff_UV_l=List_SFoFo[l].Grad_FF.X();
							double dy_ff_UV_l=List_SFoFo[l].Grad_FF.Y();
							double ff_UV_l=List_SFoFo[l].Valeur_FF;
							double ff_P_l=(l==Ind_FF_Max)?1.:0.;

							double Contrib[]={2*Nuhd_i*(dx_ff_UV_k*dx_ff_UV_l+0.5*dy_ff_UV_k*dy_ff_UV_l+coef_2*ff_UV_k*ff_UV_l),Nuhd_i*dy_ff_UV_k*dx_ff_UV_l,-ff_P_l*(dx_ff_UV_k+coef_1*ff_UV_k),
													 Nuhd_i*dx_ff_UV_k*dy_ff_UV_l,2*Nuhd_i*(0.5*dx_ff_UV_k*dx_ff_UV_l+dy_ff_UV_k*dy_ff_UV_l),-dy_ff_UV_k*ff_P_l,
													-ff_P_k*(dx_ff_UV_l+coef_1*ff_UV_l),-ff_P_k*dy_ff_UV_l,-lambda_m1/Nuhd_i};
							long m;
							for(m=0;m<3;m++)
							{
								long n;
								for(n=0;n<3;n++)
								{
									double Contrib_IJ=coef_0*Contrib[3*m+n];
								
									long Index_I=3*Ind_Voisin_k+m;
									long Index_J=3*Ind_Voisin_l+n;

									//if(fabs(Contrib_IJ)>Zero_Sparse)
									{
										pair<size_t,size_t> Index_Glob;
										if(Row_Major){Index_Glob.first=Index_I,Index_Glob.second=Index_J;}
										else{Index_Glob.first=Index_J,Index_Glob.second=Index_I;}
								 
										Map_KPL_D::iterator m=Tab_Map_Mat[id]->Mat.find(Index_Glob);
										if(m!=Tab_Map_Mat[id]->Mat.end())
										{
											pair<pair<size_t,size_t>const,double>& Ref_Paire_m=*m;
											Ref_Paire_m.second+=Contrib_IJ;
										}
										else
											Tab_Map_Mat[id]->Mat.insert(make_pair(Index_Glob,Contrib_IJ));
									}
								}
							}
						}
					}
				}
			}
		}
		Ind_S_i++;
	}
}

int gauss_cnem2d
(//IN
size_t Nb_Noeud,
double* P_XY_Noeud,    
size_t Nb_Front,
size_t* P_Nb_Noeud_Front,
size_t* P_Ind_Noeud_Front,
long Ind_LPG,
long Axi,
bool Row_Major,
double Zero_Sparse,
double** Tab_Vec_Coef,
//OUT
vector<size_t>* P_Vec_Ind_Noeud_New_Old,
vector<size_t>* P_Vec_Ind_Noeud_Old_New,
vector<size_t>* P_Vec_Tri,
Mat_Map** Tab_Map_Mat)
{
	//-----------------------------------------------------------------------//
    // Initialistation base:
    //----------------------

    C_Meshless_2d ML(Nb_Noeud,P_XY_Noeud,Nb_Front,P_Nb_Noeud_Front,P_Ind_Noeud_Front);

    ML.Voronoi_Non_Contrain();
    ML.Voronoi_Contrain();    

    //-----------------------------------------------------------------------//
	// Integration Gauss :
	//--------------------

	gauss_integration(&ML,Tab_Vec_Coef,Ind_LPG,Axi,Row_Major,0,Tab_Map_Mat);
	
    //-----------------------------------------------------------------------//
    // Sortie corespandance noeus new to old et inv :
    //----------------------------------------------

    size_t i;
    for(i=0;i<ML.Vec_Ind_Noeud_New_Old.size()-3;i++)P_Vec_Ind_Noeud_New_Old->push_back(ML.Vec_Ind_Noeud_New_Old[i]+1);
    for(i=0;i<ML.Vec_Ind_Noeud_Old_New.size();i++)P_Vec_Ind_Noeud_Old_New->push_back(ML.Vec_Ind_Noeud_Old_New[i]+1);
    
    //-----------------------------------------------------------------------//
    // Sortie triangulation :
    //-----------------------

    //map<const long,S_Sommet>::iterator k;
	vector<S_Sommet>::iterator k;
    for(k=ML.List_Sommet.begin();k!=ML.List_Sommet.end();k++)
    {
        //pair<const long,S_Sommet> Paire_k=(*k);
		S_Sommet S_k=(*k);
		if(S_k.Valide&&(!S_k.Sommet_Infini))
        {
            P_Vec_Tri->push_back(S_k.Ind_Noeud[0]);
            P_Vec_Tri->push_back(S_k.Ind_Noeud[1]);
            P_Vec_Tri->push_back(S_k.Ind_Noeud[2]);
		}
    }
    
    //-----------------------------------------------------------------------//
    
	return 0;
}








