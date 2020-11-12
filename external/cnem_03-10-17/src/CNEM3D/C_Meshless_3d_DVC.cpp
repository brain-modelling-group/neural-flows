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
// Building DVC

#include "C_Meshless_3d.h"
#include "Groupe_Tet.h"

//---------------------------------------------------------------------------//

int C_Meshless_3d::Load_Tetgen_TDC(int in_numberofpoints,int out_numberofpoints,int out_numberoftrifaces,int out_numberoftetrahedra,
                                   int* in_pointmarkerlist,REAL* out_pointlist,int* out_trifacelist,int* out_trifacemarkerlist,int* out_tetrahedronlist,int* out_neighborlist)
{
    //-----------------------------------------------------------------------//

    long i;for(i=0;i<in_numberofpoints;i++)if((in_pointmarkerlist[i]<=0)||(in_pointmarkerlist[i]>Nb_Noeud_Ini))return 1;

    //-----------------------------------------------------------------------//

    vector<int> Tab_Ind_Group_Tet(out_numberoftetrahedra,0);
    Group_Tet(out_numberoftrifaces,out_trifacelist,out_numberoftetrahedra,out_tetrahedronlist,out_neighborlist,&Tab_Ind_Group_Tet[0],
              Ind_Group_Tet>=0);
    
    if((Ind_Group_Tet>=0)&&Erase_Tet_Out)
    {
        vector<int> Noeud_a_Sup(out_numberofpoints,-1);
        vector<int> New_Ind_Old_Ind_Tet(out_numberoftetrahedra,-1);

        long I=0;
        for(i=0;i<out_numberoftetrahedra;i++)
        {
            if(Tab_Ind_Group_Tet[i]==Ind_Group_Tet)
            {
                long j;
                for(j=0;j<4;j++)Noeud_a_Sup[out_tetrahedronlist[4*i+j]]=0;
                if(I!=i)
                for(j=0;j<4;j++)
                {
                    out_tetrahedronlist[4*I+j]=out_tetrahedronlist[4*i+j];
                    out_neighborlist[4*I+j]=out_neighborlist[4*i+j];
                }
                Tab_Ind_Group_Tet[I]=Ind_Group_Tet;
                New_Ind_Old_Ind_Tet[i]=I;
                I++;
            }
        }

        if(I!=out_numberoftetrahedra)
        {
            out_numberoftetrahedra=I;

            for(i=0;i<out_numberoftetrahedra;i++)
            {
                long j;
                for(j=0;j<4;j++)
                {
                    if(out_neighborlist[4*i+j]>-1)out_neighborlist[4*i+j]=New_Ind_Old_Ind_Tet[out_neighborlist[4*i+j]];
                    else out_neighborlist[4*i+j]=-1;
                }
            }

            bool renum=0;for(i=0;i<out_numberofpoints;i++){if(Noeud_a_Sup[i]==-1){renum=1;break;}}

            if(renum)
            {
                I=0;
                for(i=0;i<out_numberofpoints;i++)
                {
                    if(Noeud_a_Sup[i]==0)
                    {
                        if(I!=i){long j;for(j=0;j<3;j++)out_pointlist[3*I+j]=out_pointlist[3*i+j];}
                        Noeud_a_Sup[i]=I;
                        I++;
                    }
                }
                out_numberofpoints=I;

                for(i=0;i<out_numberoftetrahedra;i++)
                {
                    long j;
                    for(j=0;j<4;j++)out_tetrahedronlist[4*i+j]=Noeud_a_Sup[out_tetrahedronlist[4*i+j]];
                }

                for(i=0;i<out_numberoftrifaces;i++)
                {
                    long j;
                    for(j=0;j<3;j++)out_trifacelist[3*i+j]=Noeud_a_Sup[out_trifacelist[3*i+j]];
                }

                I=0;
                for(i=0;i<in_numberofpoints;i++)
                {
                    if(Noeud_a_Sup[i]!=-1)
                    {
                        if(I!=i)in_pointmarkerlist[I]=in_pointmarkerlist[i];
                        I++;
                    }
                }
                in_numberofpoints=I;
            }
        }
    }

    //-----------------------------------------------------------------------//

    double Volume_Min_Tet;
    vector<double> List_Coord_et_Rayon_Sommet;
    vector<double> List_Volume_Sommet;

    for(i=0;i<out_numberoftetrahedra;i++)
    {
        double Centre[3];
        double Rayon;
        if(!TGM.circumsphere(&out_pointlist[3*out_tetrahedronlist[4*i]],
                                     &out_pointlist[3*out_tetrahedronlist[4*i+1]],
                                        &out_pointlist[3*out_tetrahedronlist[4*i+2]],
                                       &out_pointlist[3*out_tetrahedronlist[4*i+3]],
                                     Centre,&Rayon))
        {
            cout<<"\nTetraedre plat ! "<<endl;
            return 2;
        }

        double Volume=(C_Vec3d(&out_pointlist[3*out_tetrahedronlist[4*i]],&out_pointlist[3*out_tetrahedronlist[4*i+1]])^
                       C_Vec3d(&out_pointlist[3*out_tetrahedronlist[4*i]],&out_pointlist[3*out_tetrahedronlist[4*i+2]]))*
                       C_Vec3d(&out_pointlist[3*out_tetrahedronlist[4*i]],&out_pointlist[3*out_tetrahedronlist[4*i+3]]);

        List_Volume_Sommet.push_back(Volume);

        if(i)
        {
            if(Volume_Min_Tet<Volume)
                Volume_Min_Tet=Volume;
        }
        else
        {
            Volume_Min_Tet=Volume;
        }

        List_Coord_et_Rayon_Sommet.push_back(Centre[0]);
        List_Coord_et_Rayon_Sommet.push_back(Centre[1]);
        List_Coord_et_Rayon_Sommet.push_back(Centre[2]);
        List_Coord_et_Rayon_Sommet.push_back(Rayon);
    }

    //cout<<"Volume_Min_Tet ="<<Volume_Min_Tet<<endl;

    //Nb_Tri_Front=0;
    for(i=0;i<out_numberoftetrahedra;i++)
    {
        C_Sommet* P_Sommet = new C_Sommet;
        Diag_Vor.Ajout_Sommet(P_Sommet);

        P_Sommet->Ind_Noeud[0]=out_tetrahedronlist[4*i];
        P_Sommet->Ind_Noeud[1]=out_tetrahedronlist[4*i+2];
        P_Sommet->Ind_Noeud[2]=out_tetrahedronlist[4*i+1];
        P_Sommet->Ind_Noeud[3]=out_tetrahedronlist[4*i+3];

        if((P_Sommet->Ind_Noeud[0]>=out_numberofpoints)||
           (P_Sommet->Ind_Noeud[1]>=out_numberofpoints)||
           (P_Sommet->Ind_Noeud[2]>=out_numberofpoints)||
           (P_Sommet->Ind_Noeud[3]>=out_numberofpoints))
        {
            cout<<"pb!!! index tet >= nb noeud "<<endl;
            {int STOP;cin>>STOP;}
        }


        P_Sommet->Ind_Sommet[0]=out_neighborlist[4*i+3];
        P_Sommet->Ind_Sommet[1]=out_neighborlist[4*i];
        P_Sommet->Ind_Sommet[2]=out_neighborlist[4*i+2];
        P_Sommet->Ind_Sommet[3]=out_neighborlist[4*i+1];

        P_Sommet->Ind_Group=Tab_Ind_Group_Tet[i];
        if(Ind_Group_Tet>=0)P_Sommet->Ghost=P_Sommet->Ind_Group!=Ind_Group_Tet;
        else P_Sommet->Ghost=0;

        long j;
        /*for(j=0;j<4;j++)
        {
            if(P_Sommet->Ind_Sommet[j]==-1)
                Nb_Tri_Front++;
        }*/
        
        for(j=0;j<3;j++)P_Sommet->Sommet[j]=List_Coord_et_Rayon_Sommet[4*i+j];

        P_Sommet->Rayon_Sphere=List_Coord_et_Rayon_Sommet[4*i+3];

        P_Sommet->Volume=List_Volume_Sommet[i];
    }

    //long k=0;
    for(i=0;i<out_numberoftetrahedra;i++)
    {
        C_Sommet* P_Sommet=Diag_Vor.List_Sommet[i];
    
        long j;
        for(j=0;j<4;j++)
        {
            if(P_Sommet->Ind_Sommet[j]<0)
            {
                C_Sommet* P_Sommet_Inf = new C_Sommet;
                Diag_Vor.Ajout_Sommet(P_Sommet_Inf);
                
                P_Sommet_Inf->Sommet_Infinie=1;
                P_Sommet_Inf->Ind_Noeud[3]=-1;
                P_Sommet_Inf->Ind_Sommet[0]=P_Sommet->My_Index;
                P_Sommet_Inf->Ind_Sommet[1]=-1;
                P_Sommet_Inf->Ind_Sommet[2]=-1;
                P_Sommet_Inf->Ind_Sommet[3]=-1;

                if(P_Sommet->Ind_Sommet[j]<-1)P_Sommet_Inf->Ind_Sommet_Out=-P_Sommet->Ind_Sommet[j]-2;
                else P_Sommet_Inf->Ind_Sommet_Out=-1;

                P_Sommet->Ind_Sommet[j]=P_Sommet_Inf->My_Index;
                
                if(j%2)
                {
                    P_Sommet_Inf->Ind_Noeud[0]=P_Sommet->Ind_Noeud[j];
                    P_Sommet_Inf->Ind_Noeud[1]=P_Sommet->Ind_Noeud[(j+1)%4];
                    P_Sommet_Inf->Ind_Noeud[2]=P_Sommet->Ind_Noeud[(j+2)%4];
                    
                    //Tab_Ind_Noeud_Tri_Front[3*k]=P_Sommet->Ind_Noeud[j];
                    //Tab_Ind_Noeud_Tri_Front[3*k+1]=P_Sommet->Ind_Noeud[(j+2)%4];
                    //Tab_Ind_Noeud_Tri_Front[3*k+2]=P_Sommet->Ind_Noeud[(j+1)%4];
                }
                else
                {
                    P_Sommet_Inf->Ind_Noeud[0]=P_Sommet->Ind_Noeud[j];
                    P_Sommet_Inf->Ind_Noeud[1]=P_Sommet->Ind_Noeud[(j+2)%4];
                    P_Sommet_Inf->Ind_Noeud[2]=P_Sommet->Ind_Noeud[(j+1)%4];

                    //Tab_Ind_Noeud_Tri_Front[3*k]=P_Sommet->Ind_Noeud[j];
                    //Tab_Ind_Noeud_Tri_Front[3*k+1]=P_Sommet->Ind_Noeud[(j+1)%4];
                    //Tab_Ind_Noeud_Tri_Front[3*k+2]=P_Sommet->Ind_Noeud[(j+2)%4];
                }

                //k++;
            }
        }
    }

    //-----------------------------------------------------------------------//
    // triangulation de la frontiere:

    Nb_Tri_Front=out_numberoftrifaces;
    Tab_Ind_Noeud_Tri_Front=(long*)realloc(Tab_Ind_Noeud_Tri_Front,sizeof(long)*3*out_numberoftrifaces);
    for(i=0;i<(out_numberoftrifaces*3);i++)Tab_Ind_Noeud_Tri_Front[i]=out_trifacelist[i];

    if(Nb_Tri_Front_Ini!=0)
    {
        Tab_Flag_Tri_Front=(long*)realloc(Tab_Flag_Tri_Front,sizeof(long)*out_numberoftrifaces);
        for(i=0;i<out_numberoftrifaces;i++)Tab_Flag_Tri_Front[i]=out_trifacemarkerlist[i];
    }
    
    //-----------------------------------------------------------------------//
    // Noeuds:
    
    Diag_Vor.Nb_Noeud=out_numberofpoints;
    Diag_Vor.Tab_Noeud=(double*)realloc(Diag_Vor.Tab_Noeud,sizeof(double)*3*out_numberofpoints);
    for(i=0;i<(out_numberofpoints)*3;i++)Diag_Vor.Tab_Noeud[i]=out_pointlist[i];

    //-----------------------------------------------------------------------//

    vector<long> New_Ind_Old_Noeud_Ini_bis(Nb_Noeud_Ini,-1);
    vector<long> Old_Ind_New_Noeud_Ini_bis(in_numberofpoints);

    for(i=0;i<in_numberofpoints;i++)
    {
        Old_Ind_New_Noeud_Ini_bis[i]=in_pointmarkerlist[i]-1;
        New_Ind_Old_Noeud_Ini_bis[Old_Ind_New_Noeud_Ini_bis[i]]=i;
    }
    
    //cout<<Nb_Noeud_Ini-(long)in_numberofpoints<<" points supprimes :\n"<<endl;

    //-----------------------------------------------------------------------//

    long I=0;
    for(i=0;i<Nb_Noeud_Ini;i++)
    {
        if(New_Ind_Old_Noeud_Ini_bis[i]!=-1)
        {
            if(I!=i)
            {
                Tab_Noeud_Ini[3*I]=Tab_Noeud_Ini[3*i];
                Tab_Noeud_Ini[3*I+1]=Tab_Noeud_Ini[3*i+1];
                Tab_Noeud_Ini[3*I+2]=Tab_Noeud_Ini[3*i+2];
            }
            I++;
        }
        else
            cout<<i<<endl;
    }
    //cout<<endl;

    Nb_Noeud_Ini=in_numberofpoints;

    for(i=0;i<New_Ind_Old_Noeud_Ini.size();i++)if(New_Ind_Old_Noeud_Ini[i]!=-1)New_Ind_Old_Noeud_Ini[i]=New_Ind_Old_Noeud_Ini_bis[New_Ind_Old_Noeud_Ini[i]];
    
    for(i=0;i<Old_Ind_New_Noeud_Ini_bis.size();i++)Old_Ind_New_Noeud_Ini_bis[i]=Old_Ind_New_Noeud_Ini[Old_Ind_New_Noeud_Ini_bis[i]];
    Old_Ind_New_Noeud_Ini.resize(Nb_Noeud_Ini);
    copy(Old_Ind_New_Noeud_Ini_bis.begin(),Old_Ind_New_Noeud_Ini_bis.end(),Old_Ind_New_Noeud_Ini.begin());

    for(i=0;i<3*Nb_Tri_Front_Ini;i++)
    {
        long New_Ind_Noeud_Tri_Front_Ini=New_Ind_Old_Noeud_Ini_bis[Tab_Ind_Noeud_Tri_Front_Ini[i]];
        Tab_Ind_Noeud_Tri_Front_Ini[i]=New_Ind_Noeud_Tri_Front_Ini;

        if(New_Ind_Noeud_Tri_Front_Ini==-1)
        {
            cout<<"pb : New_Ind_Noeud_Tri_Front_Ini==-1"<<endl;
            {int STOP;cin>>STOP;}
        }
    }

    //-----------------------------------------------------------------------//

    if(Nb_Tri_Front_Ini!=0)Verif_Topo_Tri_Front_et_Initialise_Set_Ind_Noeud_Front_0();

    //-----------------------------------------------------------------------//

    return 3;
}

#ifdef _WIN32
void EXIT_Tet(int Sig){ExitThread(0);}
unsigned __stdcall Appel_Tetgen_Lib(void* args_list)
#else
void EXIT_Tet(int Sig){pthread_exit((void*)0);}
void* Appel_Tetgen_Lib(void* args_list)
#endif
{
    signal(SIGSEGV,EXIT_Tet);//Illegal storage access segment violation
    signal(SIGABRT,EXIT_Tet);//Abnormal termination abnormal termination triggered by abort call
    signal(SIGFPE,EXIT_Tet);//Floating-point error floating point exception
    signal(SIGILL,EXIT_Tet);//Illegal instruction - invalid function image
    //SIGINT CTRL+C signal 
    //SIGTERM Termination request
    
    //-----------------------------------------------------------------------//

    void** Args_List=(void**)args_list;

    C_Meshless_3d* PML=(C_Meshless_3d*)Args_List[0];
    char* Arg_Tet=(char*)Args_List[1];
    
    tetgenio in,out;
    in.firstnumber=0;
    out.firstnumber=0;
    
    in.numberofpoints=int(PML->Diag_Vor.Nb_Noeud);
    in.pointlist=new REAL[(in.numberofpoints)*3];
    
    long i;
    for(i=0;i<(in.numberofpoints)*3;i++)
        in.pointlist[i]=REAL(PML->Diag_Vor.Tab_Noeud[i]);
    
    in.pointmarkerlist=new int[in.numberofpoints];
    for(i=0;i<in.numberofpoints;i++)in.pointmarkerlist[i]=i+1;

    in.numberoffacets=int(PML->Nb_Tri_Front);
    if(PML->Nb_Tri_Front!=0)
    {
        in.facetlist=new tetgenio::facet[in.numberoffacets];
        in.facetmarkerlist=new int[in.numberoffacets];
    }

    for(i=0;i<in.numberoffacets;i++)
    {
        tetgenio::facet* f=&in.facetlist[i];
        f->numberofpolygons=1;
        f->polygonlist=new tetgenio::polygon[f->numberofpolygons];
        f->numberofholes=0;
        f->holelist=(REAL*) NULL;
        
        tetgenio::polygon* p = &f->polygonlist[0];
        p->numberofvertices=3;
        p->vertexlist = new int[p->numberofvertices];

        long j;
        for(j=0;j<3;j++)
            p->vertexlist[j]=int(PML->Tab_Ind_Noeud_Tri_Front[3*i+j]);

        in.facetmarkerlist[i]=int(PML->Tab_Flag_Tri_Front[i]);
    }

    //-----------------------------------------------------------------------//

    //in.save_nodes("in");
    //in.save_poly("in");

    //tetrahedralize("d",&in,&out);
    //tetrahedralize("pYV",&in,&out);
    //tetrahedralize("pq1.414V",&in,&out);
    tetrahedralize(Arg_Tet,&in,&out);
    //tetrahedralize("pn",&in,&out);

    //out.save_nodes("out");
    //out.save_elements("out");
    //out.save_faces("out");
    //out.save_neighbors("out");
    //in.save_poly("out");

    //-----------------------------------------------------------------------//

    int Retour_Load_TDC=PML->Load_Tetgen_TDC(in.numberofpoints,out.numberofpoints,out.numberoftrifaces,out.numberoftetrahedra,
                in.pointmarkerlist,out.pointlist,out.trifacelist,out.trifacemarkerlist,out.tetrahedronlist,out.neighborlist);

    //--------------------------------------------------------------------------//

#ifdef _WIN32
    return Retour_Load_TDC;
#else
    return (void*)Retour_Load_TDC;
#endif
}

int Appel_Tetgen_Exe(void* args_list)
{
    void** Args_List=(void**)args_list;

    C_Meshless_3d* PML=(C_Meshless_3d*)Args_List[0];
    char* Arg_Tet=(char*)Args_List[1];
    
    //-----------------------------------------------------------------------//

    string Tetgen_Path,Tetgen_Exe_Name;
#ifdef _WIN32
    Tetgen_Path="";
    Tetgen_Exe_Name=Tetgen_Path;Tetgen_Exe_Name+="tet.exe";
#else
    Tetgen_Path="";
    Tetgen_Exe_Name=Tetgen_Path;Tetgen_Exe_Name+="tet";
#endif

    ostringstream Tetgen_In_File_Name;
    ostringstream Tetgen_Out_File_Name;
    Tetgen_In_File_Name<<"Tetgen_In_"<<PML->Rank_In_Group;
    Tetgen_Out_File_Name<<"Tetgen_Out_"<<PML->Rank_In_Group;
    
    ofstream Tetgen_In;
    Tetgen_In.open(Tetgen_In_File_Name.str().c_str(),ios::binary);

    int in_numberofpoints=PML->Diag_Vor.Nb_Noeud;
    int in_numberoftrifaces=PML->Nb_Tri_Front;

    //Tetgen_In.write((char*)&(PML->Diag_Vor.Nb_Noeud),sizeof(long));
    //Tetgen_In.write((char*)&(PML->Nb_Tri_Front),sizeof(long));
    Tetgen_In.write((char*)&(in_numberofpoints),sizeof(int));
    Tetgen_In.write((char*)&(in_numberoftrifaces),sizeof(int));
    Tetgen_In.write((char*)(PML->Diag_Vor.Tab_Noeud),PML->Diag_Vor.Nb_Noeud*3*sizeof(double));
    if(in_numberoftrifaces!=0)
    {
        //Tetgen_In.write((char*)(PML->Tab_Ind_Noeud_Tri_Front),PML->Nb_Tri_Front*3*sizeof(long));
        int* Buffer_Temp=(int*)malloc(sizeof(int)*in_numberoftrifaces*3);
        int i;for(i=0;i<in_numberoftrifaces*3;i++)Buffer_Temp[i]=int(PML->Tab_Ind_Noeud_Tri_Front[i]);
        Tetgen_In.write((char*)(Buffer_Temp),in_numberoftrifaces*3*sizeof(int));
        //Tetgen_In.write((char*)(PML->Tab_Flag_Tri_Front),PML->Nb_Tri_Front*sizeof(long));
        for(i=0;i<in_numberoftrifaces;i++)Buffer_Temp[i]=int(PML->Tab_Flag_Tri_Front[i]);
        Tetgen_In.write((char*)(Buffer_Temp),in_numberoftrifaces*sizeof(int));
        free(Buffer_Temp);
    }
    Tetgen_In.close();

    //-----------------------------------------------------------------------//
    
    string Command=Tetgen_Exe_Name+' '+Tetgen_In_File_Name.str()+' '+Tetgen_Out_File_Name.str()+' '+Arg_Tet;

    int Retour_Tetgen=system(Command.c_str());

    if(Retour_Tetgen) return 1;

    //-----------------------------------------------------------------------//

    ifstream Tetgen_Out;
    Tetgen_Out.open(Tetgen_Out_File_Name.str().c_str(),ios::binary);

    int out_numberofpoints;
    int out_numberoftrifaces; 
    int out_numberoftetrahedra;

    Tetgen_Out.read((char*)&(in_numberofpoints),sizeof(int));
    Tetgen_Out.read((char*)&(out_numberofpoints),sizeof(int));
    Tetgen_Out.read((char*)&(out_numberoftrifaces),sizeof(int));
    Tetgen_Out.read((char*)&(out_numberoftetrahedra),sizeof(int));

    int* in_pointmarkerlist=(int*)malloc(in_numberofpoints*sizeof(int));
    REAL* out_pointlist=(REAL*)malloc(out_numberofpoints*3*sizeof(REAL));
    int* out_trifacelist=(int*)malloc(out_numberoftrifaces*3*sizeof(int));
    int* out_trifacemarkerlist=(in_numberoftrifaces!=0)?(int*)malloc(out_numberoftrifaces*sizeof(int)):NULL;
    int* out_tetrahedronlist=(int*)malloc(out_numberoftetrahedra*4*sizeof(int));
    int* out_neighborlist=(int*)malloc(out_numberoftetrahedra*4*sizeof(int));
    
    Tetgen_Out.read((char*)in_pointmarkerlist,in_numberofpoints*sizeof(int));
    Tetgen_Out.read((char*)out_pointlist,out_numberofpoints*3*sizeof(REAL));
    Tetgen_Out.read((char*)out_trifacelist,out_numberoftrifaces*3*sizeof(int));
    if(in_numberoftrifaces!=0)Tetgen_Out.read((char*)out_trifacemarkerlist,out_numberoftrifaces*sizeof(int));
    Tetgen_Out.read((char*)out_tetrahedronlist,out_numberoftetrahedra*4*sizeof(int));
    Tetgen_Out.read((char*)out_neighborlist,out_numberoftetrahedra*4*sizeof(int));

    Tetgen_Out.close();

    //--------------------------------------------------------------------------//

    int Retour_Load_TDC=PML->Load_Tetgen_TDC(in_numberofpoints,out_numberofpoints,out_numberoftrifaces,out_numberoftetrahedra,
                                             in_pointmarkerlist,out_pointlist,out_trifacelist,out_trifacemarkerlist,out_tetrahedronlist,out_neighborlist);

    //--------------------------------------------------------------------------//

    free(in_pointmarkerlist);
    free(out_pointlist);
    free(out_trifacelist);
    if(in_numberoftrifaces!=0)free(out_trifacemarkerlist);
    free(out_tetrahedronlist);
    free(out_neighborlist);

    return Retour_Load_TDC;
}

void C_Meshless_3d::Randomise_Noeuds(double Random_Dim)
{
    long Init=0;//1134311171;//time(NULL);
    srand(Init);
    //cout<<"Rondom init = "<<Init<<endl;
    //cout<<"Rondomisation a : "<<Random_Dim<<endl;
    long i;
    for(i=0;i<Diag_Vor.Nb_Noeud;i++)
    {
        long j;
        for(j=0;j<3;j++)
        {
            double Random=(2.*rand()-RAND_MAX)/RAND_MAX;
            Diag_Vor.Tab_Noeud[3*i+j]+=Random_Dim*Random;
        }

        /*double r=sqrt(pow(Diag_Vor.Tab_Noeud[3*i+0],2)+pow(Diag_Vor.Tab_Noeud[3*i+1],2)+pow(Diag_Vor.Tab_Noeud[3*i+2],2));
        double Teta=acos(Diag_Vor.Tab_Noeud[3*i+2]/r);
        double Phi=0.;
        double r_Sin_Teta=sqrt(pow(Diag_Vor.Tab_Noeud[3*i+0],2)+pow(Diag_Vor.Tab_Noeud[3*i+1],2));
        if(r_Sin_Teta!=0.)Phi=acos(Diag_Vor.Tab_Noeud[3*i+0]/r_Sin_Teta);
        if(Diag_Vor.Tab_Noeud[3*i+1]<0)Phi=2*PI-Phi;

        double r_Min=0.8;
        double r_Max=1.;
        double d_r=(r_Max-r_Min)/2.;
        
        double Teta_Min=0.;
        double Teta_Max=PI/2.;
        double d_Teta=(Teta_Max-Teta_Min)/2.;

        double Phi_Min=0.;
        double Phi_Max=PI/2.;
        double d_Phi=(Phi_Max-Phi_Min)/2.;

        double Epsilone=1./20.;

        if(r>(r_Max-d_r*Epsilone))r=r_Max-d_r*Epsilone;
        else if(r<r_Min+d_r*Epsilone)r=r_Min+d_r*Epsilone;

        if(Teta>(Teta_Max-d_Teta*Epsilone))Teta=Teta_Max-d_Teta*Epsilone;

        //if(Phi>(Phi_Max-d_Phi*Epsilone))Phi=Phi_Max-d_Phi*Epsilone;
        //else if(Phi<(Phi_Min+d_Phi*Epsilone))Phi=Phi_Min+d_Phi*Epsilone;

        Diag_Vor.Tab_Noeud[3*i  ]=r*sin(Teta)*cos(Phi);
        Diag_Vor.Tab_Noeud[3*i+1]=r*sin(Teta)*sin(Phi);
        Diag_Vor.Tab_Noeud[3*i+2]=r*cos(Teta);*/
    }
}

//---------------------------------------------------------------------------//

void C_Meshless_3d::Construction_Topologie_Voronoi()
{
    //cout<<"\nConstruction Topologie Voronoi-------------------------------------------------\n"<<endl;
    
    long T_0=clock();

    Diag_Vor.Build_Topologie();

    long T_1=clock();
    double Temp_de_Calcul=(T_1-T_0)/double(CLOCKS_PER_SEC);
    //cout<<"Temp de calcul = "<<Temp_de_Calcul<<" s.\n"<<endl;
        
    //-----------------------------------------------------------------------//

    Diag_Vor.Calcul_Normale_et_Aire_Faces();
    Diag_Vor.Calcul_Volume_Cellules();

    //-----------------------------------------------------------------------//
}

//---------------------------------------------------------------------------//

bool C_Meshless_3d::Voronoi_Contrain_TetGen(int Type_Appel,char* Arg_Tet,long ind_group_tet,bool erase_tet_out)
{
    //cout<<"\nTetraedrisation Delaunay contrainte Tetgen ------------------------------------\n"<<endl;

    //-----------------------------------------------------------------------//

    Ind_Group_Tet=ind_group_tet;
    Erase_Tet_Out=erase_tet_out;
    
    void* Args_List[2]={(void*)this,(void*)Arg_Tet};

    double Random_Dim=PRECISION_0;
    //Randomise_Noeuds(Random_Dim*0.5e-3);
    //Randomise_Noeuds(Random_Dim);
    
    long Nb_Tentative_max=3;
    long Nb_Tentative=0;

    bool Ok=0;

    do
    {
        Nb_Tentative++;
        //cout<<"\nAppel TetGen ";
        switch(Type_Appel)
        {
        case 0:    
            {
                cout<<"Lib..."<<endl;
#ifdef _WIN32
                unsigned threadID;
                HANDLE  hThread=(HANDLE)_beginthreadex(NULL,0,&Appel_Tetgen_Lib,(void*)Args_List,0,&threadID);
                long Temps=INFINITE;
                if(WaitForSingleObject(hThread,Temps)==WAIT_OBJECT_0)
                {
                    unsigned long ExitCode;
                    GetExitCodeThread(hThread,&ExitCode);
                     if(ExitCode==3)Ok=1;
                }
#else
                pthread_t id_Thread;
                int Status_In=pthread_create(&id_Thread,NULL,Appel_Tetgen_Lib,(void*)Args_List);
                int Status_Out;
                pthread_join(id_Thread,(void**)&Status_Out);

                if(int(Status_Out)==3)Ok=1;
#endif        
            }
            break;
            
        case 1:
            {
                //cout<<"Exe..."<<endl;

                int Retour_Fonction_Tetgen_Exe=Appel_Tetgen_Exe((void*)Args_List);

                if(Retour_Fonction_Tetgen_Exe==3)Ok=1;
            }
            break;
        default :
            break;
        }

        if(Ok) break;

        if(Nb_Tentative==Nb_Tentative_max)
        {
            cout<<"\n Echec Tetgen apres "<<Nb_Tentative<<" tentatives."<<endl;
            return 0;
        }

        memcpy(Diag_Vor.Tab_Noeud,Tab_Noeud_Ini,3*Nb_Noeud_Ini*sizeof(double));
        Random_Dim*=1.e1;
        Randomise_Noeuds(Random_Dim);

        //-------------------------------------------------------------------//

    }while(1);

    //-----------------------------------------------------------------------//

    Construction_Topologie_Voronoi();

    Verif_Topo_Tri_Front_et_Initialise_Tab_Ind_Noeud_Front_1();

    //-----------------------------------------------------------------------//

    return 1;
}

//---------------------------------------------------------------------------//
