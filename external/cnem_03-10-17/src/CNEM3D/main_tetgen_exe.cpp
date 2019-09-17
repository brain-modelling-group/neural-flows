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

#include "tetgen.h"
#include <fstream>
#include <iostream>

using namespace std;

int main(int argc,char* argv[])
{
    ifstream Tetgen_In;
    Tetgen_In.open(argv[1],ios::binary);

    int numberofpoints_In;
    int numberoftri_In;

    Tetgen_In.read((char*)&(numberofpoints_In),sizeof(int));
    Tetgen_In.read((char*)&(numberoftri_In),sizeof(int));

    cout<<"arg tetgen : "<<argv[3]<<endl;
    cout<<"nb noeud in : "<<numberofpoints_In<<endl;
    cout<<"nb tri in : "<<numberoftri_In<<endl;

    double* pointlist_In=new double[numberofpoints_In*3];
    Tetgen_In.read((char*)pointlist_In,numberofpoints_In*3*sizeof(double));
    int* trilist_In=NULL;
    int* trimarkerlist_In=NULL;
    if(numberoftri_In!=0)
    {
        trilist_In=new int[numberoftri_In*3];
        trimarkerlist_In=new int[numberoftri_In];
        Tetgen_In.read((char*)trilist_In,numberoftri_In*3*sizeof(int));
        Tetgen_In.read((char*)trimarkerlist_In,numberoftri_In*sizeof(int));
    }

    Tetgen_In.close();

    //-----------------------------------------------------------------------//
    
    tetgenio in,out;
    in.firstnumber=0;
    out.firstnumber=0;
    
    in.numberofpoints=int(numberofpoints_In);
    in.pointlist=pointlist_In;
    
    in.pointmarkerlist=new int[numberofpoints_In];
    int i;for(i=0;i<in.numberofpoints;i++)in.pointmarkerlist[i]=i+1;

    in.numberoffacets=numberoftri_In;
    if(numberoftri_In!=0)
    {
        in.facetlist=new tetgenio::facet[in.numberoffacets];
        in.facetmarkerlist=new int[in.numberoffacets];

        for(i=0;i<in.numberoffacets;i++)
        {
            tetgenio::facet* f=&in.facetlist[i];
            f->numberofpolygons=1;
            f->polygonlist=new tetgenio::polygon[f->numberofpolygons];
            f->numberofholes=0;
            f->holelist=NULL;
            
            tetgenio::polygon* p = &f->polygonlist[0];
            p->numberofvertices=3;
            p->vertexlist = new int[p->numberofvertices];

            int j;
            for(j=0;j<3;j++)
                p->vertexlist[j]=trilist_In[3*i+j];

            in.facetmarkerlist[i]=trimarkerlist_In[i];
        }
        delete [] trilist_In;
        delete [] trimarkerlist_In;
    }

    //-----------------------------------------------------------------------//

    //in.save_nodes("in");
    //in.save_poly("in");

    //tetrahedralize("d",&in,&out);
    //tetrahedralize("pq",&in,&out);
    //tetrahedralize("pq1.414V",&in,&out);
    //tetrahedralize("pnV",&in,&out);
    //tetrahedralize("pn",&in,&out);
    tetrahedralize(argv[3],&in,&out);
    //out.save_nodes("out");
    //out.save_elements("out");
    //out.save_faces("out");
    //out.save_neighbors("out");

    //-----------------------------------------------------------------------//

    //for(i=0;i<in.numberofpoints;i++)in.pointmarkerlist[i]--;

    ofstream Tetgen_Out;
    Tetgen_Out.open(argv[2],ios::binary);

    Tetgen_Out.write((char*)&(in.numberofpoints),sizeof(int));
    Tetgen_Out.write((char*)&(out.numberofpoints),sizeof(int));
    Tetgen_Out.write((char*)&(out.numberoftrifaces),sizeof(int));
    Tetgen_Out.write((char*)&(out.numberoftetrahedra),sizeof(int));
    Tetgen_Out.write((char*)(in.pointmarkerlist),(in.numberofpoints)*sizeof(int));
    Tetgen_Out.write((char*)(out.pointlist),(out.numberofpoints)*3*sizeof(double));
    Tetgen_Out.write((char*)(out.trifacelist),(out.numberoftrifaces)*3*sizeof(int));
    if(numberoftri_In!=0)Tetgen_Out.write((char*)(out.trifacemarkerlist),(out.numberoftrifaces)*sizeof(int));
    Tetgen_Out.write((char*)(out.tetrahedronlist),(out.numberoftetrahedra)*4*sizeof(int));
    Tetgen_Out.write((char*)(out.neighborlist),(out.numberoftetrahedra)*4*sizeof(int));
    
    Tetgen_Out.close();

    //-----------------------------------------------------------------------//

    return 0;
}
