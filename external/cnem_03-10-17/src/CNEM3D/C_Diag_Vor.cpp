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

#include "C_Diag_Vor.h"

C_Diag_Vor::C_Diag_Vor()
{
}

//---------------------------------------------------------------------------//

C_Diag_Vor::~C_Diag_Vor()
{
    free(Tab_Noeud);
    
    vector<C_Sommet*>::iterator i;
    for(i=List_Sommet.begin();i!=List_Sommet.end();i++)
    {
        C_Sommet* P_Sommet_i=*i;
        delete(P_Sommet_i);
    }
    
    vector<S_Arete_V*>::iterator j;
    for(j=List_Arete.begin();j!=List_Arete.end();j++)
    {
        S_Arete_V* P_Arete_j=*j;
        delete P_Arete_j;
    }
    
    vector<S_Face_V*>::iterator k;
    for(k=List_Face.begin();k!=List_Face.end();k++)
    {
        S_Face_V* P_Face_k=*k;
        delete P_Face_k->P_list_Ind_Arete;
        delete P_Face_k;
    }

    vector<S_Cellule_V*>::iterator l;
    for(l=List_Cellule.begin();l!=List_Cellule.end();l++)
    {
        S_Cellule_V* P_Cellule_Temp=*l;
        delete P_Cellule_Temp->P_List_Ind_Face;
        if(P_Cellule_Temp->P_List_Ind_Sommet!=NULL)delete P_Cellule_Temp->P_List_Ind_Sommet;
        delete P_Cellule_Temp;
    }
}

//---------------------------------------------------------------------------//

void C_Diag_Vor::Ajout_Sommet(C_Sommet* P_Sommet)
{
    if(Table_Aloc_List_Sommet.empty())
    {
        long Ind_Sommet=List_Sommet.size();
        P_Sommet->My_Index=Ind_Sommet;
        List_Sommet.push_back(P_Sommet);
    }
    else
    {
        long Ind_Sommet=Table_Aloc_List_Sommet.back();
        Table_Aloc_List_Sommet.pop_back();
        P_Sommet->My_Index=Ind_Sommet;
        List_Sommet[Ind_Sommet]=P_Sommet;
    }
}

//---------------------------------------------------------------------------//

void C_Diag_Vor::Retire_Sommet(long Ind_Sommet)
{
    delete List_Sommet[Ind_Sommet];
    List_Sommet[Ind_Sommet]=NULL;
    Table_Aloc_List_Sommet.push_back(Ind_Sommet);
}

//---------------------------------------------------------------------------//

C_Sommet* C_Diag_Vor::Trouve_Sommet_non_Infini()
{
    C_Sommet* P_Sommet_non_Infini=NULL;
    
    vector<C_Sommet*>::iterator i;
    for(i=List_Sommet.begin();i!=List_Sommet.end();i++)
    {
        C_Sommet* P_Sommet_Temp=*i;
        if(P_Sommet_Temp!=NULL)
        {
            if(!P_Sommet_Temp->Sommet_Infinie)
            {
                P_Sommet_non_Infini=P_Sommet_Temp;
                break;
            }
        }
    }
    return P_Sommet_non_Infini;
}

//---------------------------------------------------------------------------//

void C_Diag_Vor::Ajout_Arete(S_Arete_V* P_Arete)
{
    if(Table_Aloc_List_Arete.empty())
    {
        long Ind_Arete=List_Arete.size();
        P_Arete->My_Index=Ind_Arete;
        List_Arete.push_back(P_Arete);
    }
    else
    {
        long Ind_Arete=Table_Aloc_List_Arete.back();
        Table_Aloc_List_Arete.pop_back();
        P_Arete->My_Index=Ind_Arete;
        List_Arete[Ind_Arete]=P_Arete;
    }
}

//---------------------------------------------------------------------------//

void C_Diag_Vor::Retire_Arete(long Ind_Arete)
{
    delete List_Arete[Ind_Arete];
    List_Arete[Ind_Arete]=NULL;
    Table_Aloc_List_Arete.push_back(Ind_Arete);
}

//---------------------------------------------------------------------------//

void C_Diag_Vor::Ajout_Face(S_Face_V* P_Face)
{
    if(Table_Aloc_List_Face.empty())
    {
        long Ind_Face=List_Face.size();
        P_Face->My_Index=Ind_Face;
        List_Face.push_back(P_Face);
    }
    else
    {
        long Ind_Face=Table_Aloc_List_Face.back();
        Table_Aloc_List_Face.pop_back();
        P_Face->My_Index=Ind_Face;
        List_Face[Ind_Face]=P_Face;
    }
}

//---------------------------------------------------------------------------//

void C_Diag_Vor::Retire_Face(long Ind_Face)
{
    delete List_Face[Ind_Face]->P_list_Ind_Arete;
    delete List_Face[Ind_Face];
    List_Face[Ind_Face]=NULL;
    Table_Aloc_List_Face.push_back(Ind_Face);
}

//---------------------------------------------------------------------------//

void C_Diag_Vor::Build_Topologie() 
{
    long i;
    for(i=0;i<Nb_Noeud;i++)
    {
        S_Cellule_V* P_Cellule= new S_Cellule_V;
        P_Cellule->P_List_Ind_Face= new vector<long>;
        P_Cellule->P_List_Ind_Sommet= new vector<long>;
        P_Cellule->Ind_Cellule_Tronquee=-1;
        List_Cellule.push_back(P_Cellule);
    }
    
    //-----------------------------------------------------------------------//

    //cout<<"Nb sommet = "<<List_Sommet.size()<<endl;

    //-----------------------------------------------------------------------//

    vector<C_Sommet*>::iterator j;
    for(j=List_Sommet.begin();j!=List_Sommet.end();j++)
    {
        C_Sommet* P_Sommet_j=*j;

        if((P_Sommet_j!=NULL)&&(!P_Sommet_j->Ghost))
            Creation_Arete_et_face(P_Sommet_j);
    }

    //cout<<"Nb arete = "<<List_Arete.size()<<endl<<"Nb face = "<<List_Face.size()<<endl;

    //-----------------------------------------------------------------------//

    vector<S_Face_V*>::iterator k;
    for(k=List_Face.begin();k!=List_Face.end();k++)
    {
        S_Face_V* P_Face_k=*k;
        Range_Arete_dans_Face(P_Face_k);
    }

    //cout<<"Arete face rangee"<<endl;

    //-----------------------------------------------------------------------//

    vector<S_Arete_V*>::iterator l;
    for(l=List_Arete.begin();l!=List_Arete.end();l++)
    {
        S_Arete_V* P_Arete_l=*l;
                
        C_Sommet* P_Sommet_0=List_Sommet[P_Arete_l->Ind_Sommet[0]];
        C_Sommet* P_Sommet_1=List_Sommet[P_Arete_l->Ind_Sommet[1]];
        
        P_Sommet_0->Ind_Arete[P_Arete_l->Ind_dans_Sommet_0]=P_Arete_l->My_Index+1;
        
        for(i=0;i<4;i++)
        {
            if(P_Sommet_1->Ind_Sommet[i]==P_Arete_l->Ind_Sommet[0])
            {
                P_Sommet_1->Ind_Arete[i]=-(P_Arete_l->My_Index+1);
                break;
            }
        }
    }

    for(j=List_Sommet.begin();j!=List_Sommet.end();j++)
    {
        C_Sommet* P_Sommet_j=*j;
        
        if((P_Sommet_j!=NULL)&&(!P_Sommet_j->Ghost))
        {
            for(i=0;i<4;i++)
            {
                if(P_Sommet_j->Ind_Noeud[i]+1)
                    List_Cellule[P_Sommet_j->Ind_Noeud[i]]->P_List_Ind_Sommet->push_back(P_Sommet_j->My_Index);
            }
        }
    }
    
    //-----------------------------------------------------------------------//
}

//---------------------------------------------------------------------------//

void C_Diag_Vor::Creation_Arete_et_face(C_Sommet* P_Sommet)
{
    bool b=1;
    long Ind_Arete[4];
    S_Arete_V* P_Arete[4]; 

    long i;
    for(i=0;i<4;i++)
    {
        Ind_Arete[i]=-1;
        P_Arete[i]=NULL;

        if((P_Sommet->Ind_Sommet[i]+1)&&(P_Sommet->My_Index<P_Sommet->Ind_Sommet[i]))
        {
            P_Arete[i]= new S_Arete_V;
            P_Arete[i]->Type=0;
            P_Arete[i]->Ind_dans_Sommet_0=i;
            P_Arete[i]->Ind_Sommet[0]=P_Sommet->My_Index;
            P_Arete[i]->Ind_Sommet[1]=P_Sommet->Ind_Sommet[i];
            
            Ajout_Arete(P_Arete[i]);
            Ind_Arete[i]=P_Arete[i]->My_Index;
            b=0;
        }
    }

    if(b)
        return;

    //-----------------------------------------------------------------------//

    for(i=0;i<3;i++)
    {
        if((Ind_Arete[0]+1)||(Ind_Arete[(i+2)%3+1]+1))
        {
            S_Cellule_V* P_Cellule=List_Cellule[P_Sommet->Ind_Noeud[i]];
    
            bool Face_Deja_Cree=0;
            vector<long>::iterator j;
            for(j=P_Cellule->P_List_Ind_Face->begin();j!=P_Cellule->P_List_Ind_Face->end();j++)
            {
                S_Face_V* P_Face=List_Face[*j];
                    
                if(P_Face->Ind_Noeud[0]==P_Sommet->Ind_Noeud[i])
                {
                    if(P_Face->Ind_Noeud[1]==P_Sommet->Ind_Noeud[(i+1)%3])
                    {
                        Face_Deja_Cree=1;

                        if(Ind_Arete[0]+1)
                        {
                            P_Arete[0]->Ind_Face[i]=P_Face->My_Index+1;
                            P_Face->P_list_Ind_Arete->push_back(Ind_Arete[0]+1);
                        }

                        if(Ind_Arete[(i+2)%3+1]+1)
                        {
                            P_Arete[(i+2)%3+1]->Ind_Face[0]=-(P_Face->My_Index+1);
                            P_Face->P_list_Ind_Arete->push_back(-(Ind_Arete[(i+2)%3+1]+1));
                        }

                        break;
                    }
                }
                else
                {
                    if(P_Face->Ind_Noeud[0]==P_Sommet->Ind_Noeud[(i+1)%3])
                    {
                        Face_Deja_Cree=1;

                        if(Ind_Arete[0]+1)
                        {
                            P_Arete[0]->Ind_Face[i]=-(P_Face->My_Index+1);
                            P_Face->P_list_Ind_Arete->push_back(-(Ind_Arete[0]+1));
                        }

                        if(Ind_Arete[(i+2)%3+1]+1)
                        {
                             P_Arete[(i+2)%3+1]->Ind_Face[0]=P_Face->My_Index+1;
                            P_Face->P_list_Ind_Arete->push_back(Ind_Arete[(i+2)%3+1]+1);
                        }

                        break;
                    }
                }
            } 

            if(!Face_Deja_Cree)
            {
                S_Face_V* P_Face = new S_Face_V;
                P_Face->Type=0;
                P_Face->Ind_Face_Tronquee=-1;
                P_Face->Ind_Noeud[0]=P_Sommet->Ind_Noeud[i];
                P_Face->Ind_Noeud[1]=P_Sommet->Ind_Noeud[(i+1)%3];
                 P_Face->P_list_Ind_Arete = new list<long>;
            
                Ajout_Face(P_Face);
                P_Cellule->P_List_Ind_Face->push_back(P_Face->My_Index);
                List_Cellule[P_Face->Ind_Noeud[1]]->P_List_Ind_Face->push_back(P_Face->My_Index);
                if(Ind_Arete[0]+1)
                {
                    P_Arete[0]->Ind_Face[i]=P_Face->My_Index+1;
                       P_Face->P_list_Ind_Arete->push_back(Ind_Arete[0]+1);
                }

                if(Ind_Arete[(i+2)%3+1]+1)
                {
                     P_Arete[(i+2)%3+1]->Ind_Face[0]=-(P_Face->My_Index+1);
                    P_Face->P_list_Ind_Arete->push_back(-(Ind_Arete[(i+2)%3+1]+1));
                }
            }
        }
    }

    //-----------------------------------------------------------------------//

    if(!P_Sommet->Sommet_Infinie)
    {
        S_Cellule_V* P_Cellule=List_Cellule[P_Sommet->Ind_Noeud[3]];
        for(i=0;i<3;i++)
        {
            if((Ind_Arete[(i+1)%3+1]+1)||(Ind_Arete[(i+2)%3+1]+1))
            {
                bool Face_Deja_Cree=0;
                vector<long>::iterator j;
                for(j=P_Cellule->P_List_Ind_Face->begin();j!=P_Cellule->P_List_Ind_Face->end();j++)
                {
                    S_Face_V* P_Face=List_Face[*j];
                    
                    if(P_Face->Ind_Noeud[0]==P_Sommet->Ind_Noeud[3])
                    {
                         if(P_Face->Ind_Noeud[1]==P_Sommet->Ind_Noeud[i])
                        {
                            Face_Deja_Cree=1;

                            if(Ind_Arete[(i+1)%3+1]+1)
                            {
                                 P_Arete[(i+1)%3+1]->Ind_Face[2]=P_Face->My_Index+1;
                                P_Face->P_list_Ind_Arete->push_back(Ind_Arete[(i+1)%3+1]+1);
                            }  

                            if(Ind_Arete[(i+2)%3+1]+1)
                            {
                                P_Arete[(i+2)%3+1]->Ind_Face[1]=-(P_Face->My_Index+1);
                                P_Face->P_list_Ind_Arete->push_back(-(Ind_Arete[(i+2)%3+1]+1));
                            } 

                            break;
                        }
                    } 
                    else 
                    {
                        if(P_Face->Ind_Noeud[0]==P_Sommet->Ind_Noeud[i])
                        {
                            Face_Deja_Cree=1;
 
                            if(Ind_Arete[(i+1)%3+1]+1)
                            {
                                P_Arete[(i+1)%3+1]->Ind_Face[2]=-(P_Face->My_Index+1);
                                P_Face->P_list_Ind_Arete->push_back(-(Ind_Arete[(i+1)%3+1]+1));
                            } 

                            if(Ind_Arete[(i+2)%3+1]+1)
                            {
                                P_Arete[(i+2)%3+1]->Ind_Face[1]=P_Face->My_Index+1;
                                P_Face->P_list_Ind_Arete->push_back(Ind_Arete[(i+2)%3+1]+1);
                            } 

                            break;    
                        }
                    } 
                } 
 
                if(!Face_Deja_Cree)
                {  
                     S_Face_V* P_Face = new S_Face_V;
                    P_Face->Type=0;
                    P_Face->Ind_Face_Tronquee=-1;
                    P_Face->Ind_Noeud[0]=P_Sommet->Ind_Noeud[3];
                    P_Face->Ind_Noeud[1]=P_Sommet->Ind_Noeud[i];
                     P_Face->P_list_Ind_Arete = new list<long>;
            
                    Ajout_Face(P_Face);
                    P_Cellule->P_List_Ind_Face->push_back(P_Face->My_Index);
                    List_Cellule[P_Face->Ind_Noeud[1]]->P_List_Ind_Face->push_back(P_Face->My_Index);

                    if(Ind_Arete[(i+1)%3+1]+1)
                    {
                        P_Arete[(i+1)%3+1]->Ind_Face[2]=P_Face->My_Index+1;
                            P_Face->P_list_Ind_Arete->push_back(Ind_Arete[(i+1)%3+1]+1);
                    }

                     if(Ind_Arete[(i+2)%3+1]+1)
                    {
                        P_Arete[(i+2)%3+1]->Ind_Face[1]=-(P_Face->My_Index+1);
                        P_Face->P_list_Ind_Arete->push_back(-(Ind_Arete[(i+2)%3+1]+1));
                    } 
                } 
            } 
        } 
    }

    //-----------------------------------------------------------------------//
}

//---------------------------------------------------------------------------//

void C_Diag_Vor::Range_Arete_dans_Face(S_Face_V* P_Face)
{
    long Ind_Arete_Ini=P_Face->P_list_Ind_Arete->back();
    P_Face->P_list_Ind_Arete->pop_back();
    S_Arete_V* P_Arete_Ini=List_Arete[labs(Ind_Arete_Ini)-1];
    
    list<long> List_Ind_Arete_Rangee;
    List_Ind_Arete_Rangee.push_back(Ind_Arete_Ini);

    long Ind_Sommet_Liaison_Debut;
    long Ind_Sommet_Liaison_Fin;

    if(Ind_Arete_Ini>0)
    {
        Ind_Sommet_Liaison_Debut=P_Arete_Ini->Ind_Sommet[0];
        Ind_Sommet_Liaison_Fin=P_Arete_Ini->Ind_Sommet[1];
    }
    else
    {
        Ind_Sommet_Liaison_Debut=P_Arete_Ini->Ind_Sommet[1];
        Ind_Sommet_Liaison_Fin=P_Arete_Ini->Ind_Sommet[0];
    }

    list<long>::iterator i;
    while(!P_Face->P_list_Ind_Arete->empty())
    {
        for(i=P_Face->P_list_Ind_Arete->begin();i!=P_Face->P_list_Ind_Arete->end();i++)
        {
            long Ind_Arete_i=(*i);
            S_Arete_V* P_Arete=List_Arete[labs(Ind_Arete_i)-1];

            if(Ind_Arete_i>0)
            {
                if(P_Arete->Ind_Sommet[0]==Ind_Sommet_Liaison_Fin)
                {
                    List_Ind_Arete_Rangee.push_back(Ind_Arete_i);
                    Ind_Sommet_Liaison_Fin=P_Arete->Ind_Sommet[1];
                    P_Face->P_list_Ind_Arete->erase(i);
                    break;
                }
                else
                {
                    if(P_Arete->Ind_Sommet[1]==Ind_Sommet_Liaison_Debut)
                    {
                        List_Ind_Arete_Rangee.push_front(Ind_Arete_i);
                        Ind_Sommet_Liaison_Debut=P_Arete->Ind_Sommet[0];
                        P_Face->P_list_Ind_Arete->erase(i);
                        break;
                    }
                }
            }
            else
            {
                if(P_Arete->Ind_Sommet[1]==Ind_Sommet_Liaison_Fin)
                {
                    List_Ind_Arete_Rangee.push_back(Ind_Arete_i);
                    Ind_Sommet_Liaison_Fin=P_Arete->Ind_Sommet[0];
                    P_Face->P_list_Ind_Arete->erase(i);
                    break;
                }
                else
                {
                    if(P_Arete->Ind_Sommet[0]==Ind_Sommet_Liaison_Debut)
                    {
                        List_Ind_Arete_Rangee.push_front(Ind_Arete_i);
                        Ind_Sommet_Liaison_Debut=P_Arete->Ind_Sommet[1];
                        P_Face->P_list_Ind_Arete->erase(i);
                        break;
                    }
                }
            }
        }
    }

    for(i=List_Ind_Arete_Rangee.begin();i!=List_Ind_Arete_Rangee.end();i++)
    {
        long Ind_Arete_i=(*i);
        P_Face->P_list_Ind_Arete->push_back(Ind_Arete_i);
    }

    if(Ind_Sommet_Liaison_Fin==Ind_Sommet_Liaison_Debut)
        P_Face->Fermee=1;
    else
          P_Face->Fermee=0;
}

//---------------------------------------------------------------------------//

long C_Diag_Vor::Trouve_Ind_Noeud_Arete_dans_Face(S_Arete_V* P_Arete,long* Ind_Noeud_Face)
{
    long Ind_Noeud_Arete;
    C_Sommet* P_Sommet=List_Sommet[P_Arete->Ind_Sommet[0]];
    
    long Ind_Noeud_0=P_Sommet->Ind_Noeud[P_Arete->Ind_dans_Sommet_0%4];
    long Ind_Noeud_1=P_Sommet->Ind_Noeud[(P_Arete->Ind_dans_Sommet_0+1)%4];
    long Ind_Noeud_2=P_Sommet->Ind_Noeud[(P_Arete->Ind_dans_Sommet_0+2)%4];
    
    if(Ind_Noeud_0==Ind_Noeud_Face[0])
    {
        if(Ind_Noeud_1==Ind_Noeud_Face[1])
            Ind_Noeud_Arete=Ind_Noeud_2;
        else
            Ind_Noeud_Arete=Ind_Noeud_1;
    }
    else
    {
        if(Ind_Noeud_0==Ind_Noeud_Face[1])
        {
            if(Ind_Noeud_1==Ind_Noeud_Face[0])
                Ind_Noeud_Arete=Ind_Noeud_2;
            else
                Ind_Noeud_Arete=Ind_Noeud_1;
        }
        else
            Ind_Noeud_Arete=Ind_Noeud_0;
    }
    
    return Ind_Noeud_Arete;
}

//---------------------------------------------------------------------------//

double* C_Diag_Vor::Trouve_Point_sur_Face(S_Face_V* P_Face)
{
    double* Pnt;
    long Ind_Arete_0=P_Face->P_list_Ind_Arete->front();
    if(Ind_Arete_0>0)
        Pnt=List_Sommet[List_Arete[labs(Ind_Arete_0)-1]->Ind_Sommet[1]]->Sommet;
    else
        Pnt=List_Sommet[List_Arete[labs(Ind_Arete_0)-1]->Ind_Sommet[0]]->Sommet;
    return Pnt;
}

//---------------------------------------------------------------------------//

C_Vec3d C_Diag_Vor::Calcul_Normale_Face(S_Face_V* P_Face)
{
    return C_Vec3d(&Tab_Noeud[P_Face->Ind_Noeud[0]*3],&Tab_Noeud[P_Face->Ind_Noeud[1]*3]);
}

//---------------------------------------------------------------------------//

void C_Diag_Vor::Trouve_Coord_Sommet_Face(S_Face_V* P_Face,vector<double*>* P_List_Coord_Sommet_Face)    
{
    list<long>::iterator i;
    for(i=P_Face->P_list_Ind_Arete->begin();i!=P_Face->P_list_Ind_Arete->end();i++)
    {
        long Ind_Arete_i=(*i);
        if(Ind_Arete_i>0)
            P_List_Coord_Sommet_Face->push_back(List_Sommet[List_Arete[labs(Ind_Arete_i)-1]->Ind_Sommet[0]]->Sommet);
        else
            P_List_Coord_Sommet_Face->push_back(List_Sommet[List_Arete[labs(Ind_Arete_i)-1]->Ind_Sommet[1]]->Sommet);
    }
}

//---------------------------------------------------------------------------//

void C_Diag_Vor::Trouve_Coord_Sommet_Face(S_Face_V* P_Face,vector<double*>* P_List_Coord_Sommet_Face,C_Vec3d* Dir_Inf)    
{
    list<long>::iterator i=P_Face->P_list_Ind_Arete->begin();
    for(i++;i!=P_Face->P_list_Ind_Arete->end();i++)
    {
        long Ind_Arete_i=(*i);
        if(Ind_Arete_i>0)
            P_List_Coord_Sommet_Face->push_back(List_Sommet[List_Arete[labs(Ind_Arete_i)-1]->Ind_Sommet[0]]->Sommet);
        else
            P_List_Coord_Sommet_Face->push_back(List_Sommet[List_Arete[labs(Ind_Arete_i)-1]->Ind_Sommet[1]]->Sommet);
    }
    
    C_Sommet* P_Sommet_Inf[2];

    long Ind_Arete_Inf=P_Face->P_list_Ind_Arete->front();
    if(Ind_Arete_Inf>0)
        P_Sommet_Inf[0]=List_Sommet[List_Arete[labs(Ind_Arete_Inf)-1]->Ind_Sommet[0]];
    else
        P_Sommet_Inf[0]=List_Sommet[List_Arete[labs(Ind_Arete_Inf)-1]->Ind_Sommet[1]];

    Ind_Arete_Inf=P_Face->P_list_Ind_Arete->back();
    if(Ind_Arete_Inf>0)
        P_Sommet_Inf[1]=List_Sommet[List_Arete[labs(Ind_Arete_Inf)-1]->Ind_Sommet[1]];
    else
        P_Sommet_Inf[1]=List_Sommet[List_Arete[labs(Ind_Arete_Inf)-1]->Ind_Sommet[0]];

    long j;
    for(j=0;j<2;j++)
    {
        double* Noeud_Sommet_Inf[3];
        long k;
           for(k=0;k<3;k++)
            Noeud_Sommet_Inf[k]=&Tab_Noeud[P_Sommet_Inf[j]->Ind_Noeud[k]*3];
        
        Dir_Inf[j]=(C_Vec3d(Noeud_Sommet_Inf[0],Noeud_Sommet_Inf[2])^
                    C_Vec3d(Noeud_Sommet_Inf[0],Noeud_Sommet_Inf[1])).Normalized();
    }
}

//---------------------------------------------------------------------------//

C_Vec3d C_Diag_Vor::Dir_Inf(C_Sommet* P_Sommet_Inf)
{
    double* Noeud_Sommet_Inf[3];
    long i;
       for(i=0;i<3;i++)
        Noeud_Sommet_Inf[i]=&Tab_Noeud[P_Sommet_Inf->Ind_Noeud[i]*3];
        
    return (C_Vec3d(Noeud_Sommet_Inf[0],Noeud_Sommet_Inf[2])^C_Vec3d(Noeud_Sommet_Inf[0],Noeud_Sommet_Inf[1])).Normalized();
}

//---------------------------------------------------------------------------//

void C_Diag_Vor::Trouve_Face_Cel_Libre(long Ind_Noeud,S_Cellule_V* P_Cellule,vector<long>* P_List_Ind_Face_Libre)
{
    map<long,bool> Map_Face_Libre;
    
    long Nb_Sommet=P_Cellule->P_List_Ind_Sommet->size();

    long i;
    for(i=0;i<Nb_Sommet;i++)
    {
        C_Sommet* P_Sommet=List_Sommet[P_Cellule->P_List_Ind_Sommet->at(i)];
        if(P_Sommet->Valide)
        {
            long j;
            for(j=0;j<4;j++)
            {
                if(P_Sommet->Ind_Noeud[j]==Ind_Noeud)
                {
                    long k;
                    for(k=2;k<5;k++)
                    {
                        map<long,bool>::iterator l=Map_Face_Libre.find(-(P_Sommet->Ind_Arete[(j+k)%4]));
                         if(l==Map_Face_Libre.end())
                            Map_Face_Libre[P_Sommet->Ind_Arete[(j+k)%4]]=1;
                         else
                             Map_Face_Libre.erase(l);
                    }
                    break;
                } 
            }
        }
    }

    map<long,bool>::iterator j;
    for(j=Map_Face_Libre.begin();j!=Map_Face_Libre.end();j++)
    {
        pair<long,bool> Paire_j=*j;
        P_List_Ind_Face_Libre->push_back(Paire_j.first);
    }
}

//---------------------------------------------------------------------------//

double C_Diag_Vor::Calcul_Aire_Polygon(vector<double*>* P_List_Pnt_Face,C_Vec3d* P_Normale_Face)
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

void C_Diag_Vor::Calcul_Normale_et_Aire_Face(S_Face_V* P_Face)
{
    vector<double*> List_Pnt_Face;
    Trouve_Coord_Sommet_Face(P_Face,&List_Pnt_Face);
    P_Face->Normale=Calcul_Normale_Face(P_Face);
    C_Vec3d Normale_Face=P_Face->Normale.Normalized();
    if(P_Face->Fermee)
        P_Face->Aire=Calcul_Aire_Polygon(&List_Pnt_Face,&Normale_Face);
    else
        P_Face->Aire=0;
}

//---------------------------------------------------------------------------//

void C_Diag_Vor::Calcul_Normale_et_Aire_Faces()
{
    vector<S_Face_V*>::iterator i;
    for(i=List_Face.begin();i!=List_Face.end();i++)
    {
        S_Face_V* P_Face_i=*i;
        Calcul_Normale_et_Aire_Face(P_Face_i);
    }
}

//---------------------------------------------------------------------------//

void C_Diag_Vor::Calcul_Volume_Cellule(S_Cellule_V* P_Cellule)
{
    P_Cellule->Volume=0.;
    vector<long>::iterator i;
    for(i=P_Cellule->P_List_Ind_Face->begin();i!=P_Cellule->P_List_Ind_Face->end();i++)
    {
        long Ind_Face_i=(*i);
        S_Face_V* P_Face_i=List_Face[Ind_Face_i];
        P_Cellule->Volume+=P_Face_i->Aire*P_Face_i->Normale.Magnitude()/6.;
    }
}

//---------------------------------------------------------------------------//

void C_Diag_Vor::Calcul_Volume_Cellules()
{
    vector<S_Cellule_V*>::iterator i;
    for(i=List_Cellule.begin();i!=List_Cellule.end();i++)
    {
        S_Cellule_V* P_Cellule_i=*i;
        Calcul_Volume_Cellule(P_Cellule_i);
    }
}

//---------------------------------------------------------------------------//
