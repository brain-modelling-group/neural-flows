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
//

#include "out_elem_celqt.h"

//---------------------------------------------------------------------------//

void out_elem_celqt
(C_Meshless_3d* PML,vector<long>* P_Ind_Voisin_NE,vector<double>* P_Phi_Voisin_NE,
 vector<long>* P_Ind_Noeud_Hexa,vector<long>* P_Ind_Cel_Elem_Hexa,
 vector<long>* P_Ind_Noeud_Tet,vector<long>* P_Ind_Cel_Elem_Tet,
 vector<long>* P_Ind_S_Elem_Tet,vector<long>* P_Id_in_S_Elem_Tet,
 vector<double>* P_Coord_Noeud,
 vector<long>* P_Nb_Voisin,vector<long>* P_Ind_Voisin,vector<double>* P_Phi_Voisin)
{
	//-----------------------------------------------------------------------//

	long* Ind_Noeud_CT_CF_CA_Tet=(long*)malloc(11*PML->Diag_Vor.List_Sommet.size()*sizeof(long));
	long i;for(i=0;i<11*PML->Diag_Vor.List_Sommet.size();i++)Ind_Noeud_CT_CF_CA_Tet[i]=-1;

	//-----------------------------------------------------------------------//

	for(i=0;i<PML->Nb_Noeud_Ini;i++)
	{
		long j;for(j=0;j<3;j++)P_Coord_Noeud->push_back(PML->Diag_Vor.Tab_Noeud[3*i+j]);
		P_Nb_Voisin->push_back(1);
		P_Ind_Voisin->push_back(i);
		P_Phi_Voisin->push_back(1.);
	}

	//-----------------------------------------------------------------------//

	long k=0;
	for(i=PML->Nb_Noeud_Ini;i<PML->Diag_Vor.Nb_Noeud;i++)
	{
		long j;for(j=0;j<3;j++)P_Coord_Noeud->push_back(PML->Diag_Vor.Tab_Noeud[3*i+j]);
		P_Nb_Voisin->push_back(3);
		for(j=0;j<3;j++){P_Ind_Voisin->push_back(P_Ind_Voisin_NE->at(3*k+j));P_Phi_Voisin->push_back(P_Phi_Voisin_NE->at(3*k+j));}
		k++;
	}

	//-----------------------------------------------------------------------//

	long Id_Pnt_CT_CF_CA_Tet=PML->Diag_Vor.Nb_Noeud;

	for(i=0;i<PML->Diag_Vor.List_Sommet.size();i++)
	{
		C_Sommet* P_S_i=PML->Diag_Vor.List_Sommet[i];
		if(!P_S_i->Sommet_Infinie)
		{
			Ind_Noeud_CT_CF_CA_Tet[11*i]=Id_Pnt_CT_CF_CA_Tet;
			Id_Pnt_CT_CF_CA_Tet++;

			long j;
			for(j=0;j<3;j++)P_Coord_Noeud->push_back((PML->Diag_Vor.Tab_Noeud[3*P_S_i->Ind_Noeud[0]+j]+
			 									      PML->Diag_Vor.Tab_Noeud[3*P_S_i->Ind_Noeud[1]+j]+
												      PML->Diag_Vor.Tab_Noeud[3*P_S_i->Ind_Noeud[2]+j]+
												      PML->Diag_Vor.Tab_Noeud[3*P_S_i->Ind_Noeud[3]+j])/4.);
			vector<long>Ind_Voisin_tmp;
			vector<double>Phi_Voisin_tmp;
			for(j=0;j<4;j++)
			{
				long Ind_Noeud_j=P_S_i->Ind_Noeud[j];

				if(Ind_Noeud_j>=PML->Nb_Noeud_Ini)
				{
					long l;
					for(l=0;l<3;l++)
					{
						long Ind_Voisin_l=P_Ind_Voisin_NE->at(3*(Ind_Noeud_j-PML->Nb_Noeud_Ini)+l);
						double Phi_Voisin_l=(1./4.)*P_Phi_Voisin_NE->at(3*(Ind_Noeud_j-PML->Nb_Noeud_Ini)+l);

						bool b=1;
						long m;
						for(m=0;m<Ind_Voisin_tmp.size();m++)
						{
							if(Ind_Voisin_tmp[m]==Ind_Voisin_l)
							{
								Phi_Voisin_tmp[m]+=Phi_Voisin_l;
								b=0;
								break;
							}
						}
						
						if(b)
						{
							Ind_Voisin_tmp.push_back(Ind_Voisin_l);
							Phi_Voisin_tmp.push_back(Phi_Voisin_l);
						}
					}
				}
				else
				{
					bool b=1;
					long m;
					for(m=0;m<Ind_Voisin_tmp.size();m++)
					{
						if(Ind_Voisin_tmp[m]==Ind_Noeud_j)
						{
							Phi_Voisin_tmp[m]+=1./4.;
							b=0;
							break;
						}
					}
					
					if(b)
					{
						Ind_Voisin_tmp.push_back(Ind_Noeud_j);
						Phi_Voisin_tmp.push_back(1./4.);
					}
				}
			}
			
			P_Nb_Voisin->push_back(Ind_Voisin_tmp.size());
			P_Ind_Voisin->insert(P_Ind_Voisin->end(),Ind_Voisin_tmp.begin(),Ind_Voisin_tmp.end());
			P_Phi_Voisin->insert(P_Phi_Voisin->end(),Phi_Voisin_tmp.begin(),Phi_Voisin_tmp.end());
		}
	}

	//-----------------------------------------------------------------------//

	for(i=0;i<PML->Diag_Vor.List_Arete.size();i++)
	{
		S_Arete_V* P_A_i=PML->Diag_Vor.List_Arete[i];
		C_Sommet* P_S_0_A_i=PML->Diag_Vor.List_Sommet[P_A_i->Ind_Sommet[0]];
		C_Sommet* P_S_1_A_i=PML->Diag_Vor.List_Sommet[P_A_i->Ind_Sommet[1]];
		
		Ind_Noeud_CT_CF_CA_Tet[11*P_A_i->Ind_Sommet[0]+P_A_i->Ind_dans_Sommet_0+1]=Id_Pnt_CT_CF_CA_Tet;
		long j;for(j=0;j<4;j++){if(P_S_1_A_i->Ind_Sommet[j]==P_A_i->Ind_Sommet[0])break;}
		Ind_Noeud_CT_CF_CA_Tet[11*P_A_i->Ind_Sommet[1]+j+1]=Id_Pnt_CT_CF_CA_Tet;
		Id_Pnt_CT_CF_CA_Tet++;

		for(j=0;j<3;j++)P_Coord_Noeud->push_back((PML->Diag_Vor.Tab_Noeud[3*P_S_0_A_i->Ind_Noeud[(P_A_i->Ind_dans_Sommet_0)%4]+j]+
			                                      PML->Diag_Vor.Tab_Noeud[3*P_S_0_A_i->Ind_Noeud[(P_A_i->Ind_dans_Sommet_0+1)%4]+j]+
											      PML->Diag_Vor.Tab_Noeud[3*P_S_0_A_i->Ind_Noeud[(P_A_i->Ind_dans_Sommet_0+2)%4]+j])/3.);
		vector<long>Ind_Voisin_tmp;
		vector<double>Phi_Voisin_tmp;

		for(j=0;j<3;j++)
		{
			long Ind_Noeud_j=P_S_0_A_i->Ind_Noeud[(P_A_i->Ind_dans_Sommet_0+j)%4];

			if(Ind_Noeud_j>=PML->Nb_Noeud_Ini)
			{
				long l;
				for(l=0;l<3;l++)
				{
					long Ind_Voisin_l=P_Ind_Voisin_NE->at(3*(Ind_Noeud_j-PML->Nb_Noeud_Ini)+l);
					double Phi_Voisin_l=(1./3.)*P_Phi_Voisin_NE->at(3*(Ind_Noeud_j-PML->Nb_Noeud_Ini)+l);

					bool b=1;
					long m;
					for(m=0;m<Ind_Voisin_tmp.size();m++)
					{
						if(Ind_Voisin_tmp[m]==Ind_Voisin_l)
						{
							Phi_Voisin_tmp[m]+=Phi_Voisin_l;
							b=0;
							break;
						}
					}
					
					if(b)
					{
						Ind_Voisin_tmp.push_back(Ind_Voisin_l);
						Phi_Voisin_tmp.push_back(Phi_Voisin_l);
					}
				}
			}
			else
			{
				bool b=1;
				long m;
				for(m=0;m<Ind_Voisin_tmp.size();m++)
				{
					if(Ind_Voisin_tmp[m]==Ind_Noeud_j)
					{
						Phi_Voisin_tmp[m]+=1./3.;
						b=0;
						break;
					}
				}
				
				if(b)
				{
					Ind_Voisin_tmp.push_back(Ind_Noeud_j);
					Phi_Voisin_tmp.push_back(1./3.);
				}
			}
		}

		P_Nb_Voisin->push_back(Ind_Voisin_tmp.size());
		P_Ind_Voisin->insert(P_Ind_Voisin->end(),Ind_Voisin_tmp.begin(),Ind_Voisin_tmp.end());
		P_Phi_Voisin->insert(P_Phi_Voisin->end(),Phi_Voisin_tmp.begin(),Phi_Voisin_tmp.end());
	}

	//-----------------------------------------------------------------------//
	
	for(i=0;i<PML->Diag_Vor.List_Face.size();i++)
	{
		S_Face_V* P_F_i=PML->Diag_Vor.List_Face[i];
		
		list<long>::iterator it_j;
		for(it_j=P_F_i->P_list_Ind_Arete->begin();it_j!=P_F_i->P_list_Ind_Arete->end();it_j++)
		{
			long Ind_Arete_j=*it_j;
			S_Arete_V* P_Arete_j=PML->Diag_Vor.List_Arete[labs(Ind_Arete_j)-1];
			C_Sommet* P_S_j=(Ind_Arete_j>0)?PML->Diag_Vor.List_Sommet[P_Arete_j->Ind_Sommet[1]]:
				                            PML->Diag_Vor.List_Sommet[P_Arete_j->Ind_Sommet[0]];
			if(!P_S_j->Sommet_Infinie)
			{

				long m;for(m=0;m<4;m++)if(P_S_j->Ind_Noeud[m]==P_F_i->Ind_Noeud[0])break;
				long n;for(n=0;n<4;n++)if(P_S_j->Ind_Noeud[n]==P_F_i->Ind_Noeud[1])break;
				long l;
				if     ((m==0&&n==1)||(m==1&&n==0))l=0;
				else if((m==1&&n==2)||(m==2&&n==1))l=1;
				else if((m==2&&n==0)||(m==0&&n==2))l=2;
				else if((m==0&&n==3)||(m==3&&n==0))l=3;
				else if((m==1&&n==3)||(m==3&&n==1))l=4;
				else if((m==2&&n==3)||(m==3&&n==2))l=5;

				Ind_Noeud_CT_CF_CA_Tet[11*P_S_j->My_Index+5+l]=Id_Pnt_CT_CF_CA_Tet;
			}
		}
		Id_Pnt_CT_CF_CA_Tet++;

		long j;
		for(j=0;j<3;j++)P_Coord_Noeud->push_back((PML->Diag_Vor.Tab_Noeud[3*P_F_i->Ind_Noeud[0]+j]+
			                                      PML->Diag_Vor.Tab_Noeud[3*P_F_i->Ind_Noeud[1]+j])/2.);

		vector<long>Ind_Voisin_tmp;
		vector<double>Phi_Voisin_tmp;

		for(j=0;j<2;j++)
		{
			long Ind_Noeud_j=P_F_i->Ind_Noeud[j];

			if(Ind_Noeud_j>=PML->Nb_Noeud_Ini)
			{
				long l;
				for(l=0;l<3;l++)
				{
					long Ind_Voisin_l=P_Ind_Voisin_NE->at(3*(Ind_Noeud_j-PML->Nb_Noeud_Ini)+l);
					double Phi_Voisin_l=(1./2.)*P_Phi_Voisin_NE->at(3*(Ind_Noeud_j-PML->Nb_Noeud_Ini)+l);

					bool b=1;
					long m;
					for(m=0;m<Ind_Voisin_tmp.size();m++)
					{
						if(Ind_Voisin_tmp[m]==Ind_Voisin_l)
						{
							Phi_Voisin_tmp[m]+=Phi_Voisin_l;
							b=0;
							break;
						}
					}
					
					if(b)
					{
						Ind_Voisin_tmp.push_back(Ind_Voisin_l);
						Phi_Voisin_tmp.push_back(Phi_Voisin_l);
					}
				}
			}
			else
			{
				bool b=1;
				long m;
				for(m=0;m<Ind_Voisin_tmp.size();m++)
				{
					if(Ind_Voisin_tmp[m]==Ind_Noeud_j)
					{
						Phi_Voisin_tmp[m]+=1./2.;
						b=0;
						break;
					}
				}
				
				if(b)
				{
					Ind_Voisin_tmp.push_back(Ind_Noeud_j);
					Phi_Voisin_tmp.push_back(1./2.);
				}
			}
		}
		
		P_Nb_Voisin->push_back(Ind_Voisin_tmp.size());
		P_Ind_Voisin->insert(P_Ind_Voisin->end(),Ind_Voisin_tmp.begin(),Ind_Voisin_tmp.end());
		P_Phi_Voisin->insert(P_Phi_Voisin->end(),Phi_Voisin_tmp.begin(),Phi_Voisin_tmp.end());
	}

	//-----------------------------------------------------------------------//

	long gui_hexa[4][7]={{7,1,5,8 ,3,0,4},
	                     {5,1,6,9 ,4,0,2},
	                     {6,1,7,10,2,0,3},
	                     {8,4,9,10,3,0,2}};

	long gui_tet[4][3][2][4]={{{{0,5 ,4},{0,1,5 }},{{0,7,1},{0,3,7}},{{0,8 ,3},{0,4,8 }}},
	                          {{{0,6 ,2},{0,1,6 }},{{0,9,4},{0,2,9}},{{0,5 ,1},{0,4,5 }}},
	                          {{{0,10,2},{0,3,10}},{{0,7,3},{0,1,7}},{{0,6 ,1},{0,2,6 }}},
	                          {{{0,8 ,4},{0,3,8 }},{{0,9,2},{0,4,9}},{{0,10,3},{0,2,10}}}};

	for(i=0;i<PML->Diag_Vor.List_Sommet.size();i++)
	{
		C_Sommet* P_S_i=PML->Diag_Vor.List_Sommet[i];

		if(!P_S_i->Sommet_Infinie)
		{
			long j;
			for(j=0;j<4;j++)
			{
				if(P_S_i->Ind_Noeud[j]<PML->Nb_Noeud_Ini)
				{
					P_Ind_Noeud_Hexa->push_back(P_S_i->Ind_Noeud[j]);
					long l;for(l=0;l<7;l++)P_Ind_Noeud_Hexa->push_back(Ind_Noeud_CT_CF_CA_Tet[11*P_S_i->My_Index+gui_hexa[j][l]]);
					P_Ind_Cel_Elem_Hexa->push_back(P_S_i->Ind_Noeud[j]);
				}
				else
				{
					long l;
					for(l=0;l<3;l++)
					{
						long m;
						for(m=0;m<2;m++)
						{
							P_Ind_Noeud_Tet->push_back(P_S_i->Ind_Noeud[j]);
							long n;for(n=0;n<3;n++)P_Ind_Noeud_Tet->push_back(Ind_Noeud_CT_CF_CA_Tet[11*P_S_i->My_Index+gui_tet[j][l][m][n]]);
							
							for(n=0;n<3;n++)if(P_S_i->Ind_Noeud[(j+l+1+n)%4]<PML->Nb_Noeud_Ini)break;
							if(n<3)P_Ind_Cel_Elem_Tet->push_back(P_S_i->Ind_Noeud[(j+l+1+n)%4]);
							else 
							{
								long o=0;
								for(n=1;n<3;n++)if(P_Phi_Voisin_NE->at(3*(P_S_i->Ind_Noeud[j]-PML->Nb_Noeud_Ini)+n)>
									               P_Phi_Voisin_NE->at(3*(P_S_i->Ind_Noeud[j]-PML->Nb_Noeud_Ini)+o))o=n;
								P_Ind_Cel_Elem_Tet->push_back(P_Ind_Voisin_NE->at(3*(P_S_i->Ind_Noeud[j]-PML->Nb_Noeud_Ini)+o));
							}
							P_Ind_S_Elem_Tet->push_back(i);
							P_Id_in_S_Elem_Tet->push_back(j*6+l*2+m);
						}
					}
				}
			}
		}
	}
	
	//-----------------------------------------------------------------------//

	free(Ind_Noeud_CT_CF_CA_Tet);
}
