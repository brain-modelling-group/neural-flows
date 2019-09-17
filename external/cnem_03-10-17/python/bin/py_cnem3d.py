##
## This file is part of CNEMLIB.
## 
## Copyright (C) 2003-2011
## Lounes ILLOUL (illoul_lounes@yahoo.fr)
## Philippe LORONG (philippe.lorong@ensam.eu)
## Arts et Metiers ParisTech, Paris, France
## 
## CNEMLIB is free software: you can redistribute it and/or modify
## it under the terms of the GNU Lesser General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## CNEMLIB is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU Lesser General Public License for more details.
##
## You should have received a copy of the GNU Lesser General Public License
## along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
##
## Please report bugs to illoul_lounes@yahoo.fr 

import CNEM3D
from numpy import array as nparray
from numpy import zeros
from scipy import sparse
import math
import array
import os

my_dir=os.path.abspath(os.path.dirname(__file__))
#os.putenv('PATH',os.getenv('PATH')+os.pathsep+my_dir)

class interpol:

    def __init__(self,XYZ_Noeud,IN_Tri_Ini,XYZ_Point,Type_FF):

        Type_Call_Tet=0
        XYZ_Noeud_c=list(XYZ_Noeud)
        IN_Tri_Ini_c=list(IN_Tri_Ini)

        nb_noeud_ini=len(XYZ_Noeud_c)/3

        if len(IN_Tri_Ini)!=0:
            bbox=file(my_dir+'/bbox_03','rb')
            nb_noeud_tri_bbox=array.array('I')
            nb_noeud_tri_bbox.read(bbox,2)
            noeud_bbox=array.array('f')
            noeud_bbox.read(bbox,nb_noeud_tri_bbox[0]*3)
            in_tri_bbox=array.array('I')
            in_tri_bbox.read(bbox,nb_noeud_tri_bbox[1]*3)
            bbox.close()

            min_max_xyz=[min(XYZ_Noeud_c[0:3*nb_noeud_ini:3]),max(XYZ_Noeud_c[0:3*nb_noeud_ini:3]),\
                         min(XYZ_Noeud_c[1:3*nb_noeud_ini:3]),max(XYZ_Noeud_c[1:3*nb_noeud_ini:3]),\
                         min(XYZ_Noeud_c[2:3*nb_noeud_ini:3]),max(XYZ_Noeud_c[2:3*nb_noeud_ini:3])]
            O=[(min_max_xyz[1]+min_max_xyz[0])/2,\
               (min_max_xyz[3]+min_max_xyz[2])/2,\
               (min_max_xyz[5]+min_max_xyz[4])/2]
            R=0.5*math.sqrt(3.)*max([min_max_xyz[1]-min_max_xyz[0],\
                                     min_max_xyz[3]-min_max_xyz[2],\
                                     min_max_xyz[5]-min_max_xyz[4]])
            Coef=1.5
                                                                
            for i in xrange(len(noeud_bbox)/3) :
                for j in range(3):
                    XYZ_Noeud_c.append(float(noeud_bbox[3*i+j])*R*Coef+O[j])
            
            for id_node in in_tri_bbox :
                IN_Tri_Ini_c.append(int(id_node)+nb_noeud_ini)

        #IOMaillage.OUT_TRI_V3D([XYZ_Noeud_c,IN_Tri_Ini_c],[[1.,1.,0.,0.5],[0.,1.,0.]],'Tri_V3D_1',1)
        #v3d.show('Tri_V3D_1.tri')
        
        [IN_New_Old,IN_Old_New,INV_NN,PNV_NN,\
         IN_Point,Nb_Contrib,INV,FF]=\
         CNEM3D.INTERPOL_CNEM3D(XYZ_Noeud_c,IN_Tri_Ini_c,XYZ_Point,Type_Call_Tet,Type_FF)

        INV_NN=list(INV_NN)
        INV=list(INV)
        
        IN_New_Old=nparray(IN_New_Old)-1
        IN_Old_New=nparray(IN_Old_New)-1

        nb_noeud_ini_new=len(IN_Old_New)
        INV_NN_new=[]
        PNV_NN_new=[]
        new_ind_new_noeud=[-1]*len(INV_NN)
        I=0
        for i in range(len(INV)):
            if INV[i]<nb_noeud_ini_new:
                INV[i]=IN_Old_New[INV[i]]
            else :
                j=INV[i]-nb_noeud_ini_new
                if new_ind_new_noeud[j]==-1 :
                    I=I+1
                    new_ind_new_noeud[j]=nb_noeud_ini+I-1
                    INV_NN_new.extend(IN_Old_New[INV_NN[3*j:3*(j+1)]])
                    PNV_NN_new.extend(PNV_NN[3*j:3*(j+1)])
                INV[i]=new_ind_new_noeud[j]

        INV_NN=nparray(INV_NN_new)
        PNV_NN=nparray(PNV_NN_new)

        if I!=0 :
            indptr=nparray(range(0,INV_NN.shape[0]/3+1),dtype='int')*3        
            self.Mat_INT_NN=sparse.csr_matrix((PNV_NN,INV_NN,indptr),shape=(I,nb_noeud_ini),dtype='double')
        else :
            self.Mat_INT_NN=None
    
        IN_Point=nparray(IN_Point)
        inv_IN_Point=zeros(IN_Point.shape,dtype='int')
        inv_IN_Point[IN_Point]=range(0,IN_Point.shape[0])
        
        indptr=zeros(len(Nb_Contrib)+1,dtype='int')
        indptr[1:len(Nb_Contrib)+1]=Nb_Contrib
        for i in xrange(len(Nb_Contrib)):
            indptr[i+1]+=indptr[i]
        Mat_FF=sparse.csr_matrix((FF,INV,indptr),shape=(len(XYZ_Point)/3,nb_noeud_ini+I),dtype='double')
        self.Mat_INT=Mat_FF[inv_IN_Point,:]

        self.In_Out=nparray(Nb_Contrib,dtype='int')
        self.In_Out=self.In_Out[inv_IN_Point]
        self.In_Out=self.In_Out != 0
        
    def interpolate(self,Var):

        Var_bis=Var
        if self.Mat_INT_NN!=None :
            Var_bis=zeros((Var.shape[0]+self.Mat_INT_NN.shape[0],Var.shape[1]))
            Var_bis[0:Var.shape[0],:]=Var
            Var_bis[Var.shape[0]:Var.shape[0]+self.Mat_INT_NN.shape[0],:]=self.Mat_INT_NN*Var

        return self.Mat_INT*Var_bis

    def mat_interpol_glob(self):
        
        if self.Mat_INT_NN!=None :
            Nb_Noeud_Ini=self.Mat_INT_NN.shape[1]
            return self.Mat_INT[:,:Nb_Noeud_Ini]+self.Mat_INT[:,Nb_Noeud_Ini:]*self.Mat_INT_NN
        else :
            return self.Mat_INT
        
def scni(XYZ_Noeud,IN_Tri_Ini,Type_FF,Sup_NN_GS):

    Type_Call_Tet=0
    [IN_New_Old,IN_Old_New,New_Noeud,INV_NN,PNV_NN,\
    Vol_Cel,Nb_Contrib,INV,Grad,IN_Tri,IN_Tet]=\
    CNEM3D.SCNI_CNEM3D(XYZ_Noeud,IN_Tri_Ini,Type_Call_Tet,Type_FF,Sup_NN_GS)

    XYZ_Noeud_New=list()
    for i in IN_Old_New :
        XYZ_Noeud_New.extend(XYZ_Noeud[3*(i-1):3*i])
    XYZ_Noeud_New.extend(New_Noeud)

    IN_Tri_Ini_New=list()
    for i in range(len(IN_Tri_Ini)) :
        IN_Tri_Ini_New.append(IN_New_Old[IN_Tri_Ini[i]]-1)

    XYZ_Noeud_New=nparray(XYZ_Noeud_New)
    XYZ_Noeud_New=XYZ_Noeud_New.reshape((XYZ_Noeud_New.shape[0]/3,3))
    IN_Tri_Ini_New=nparray(IN_Tri_Ini_New)
    IN_Tri_Ini_New=IN_Tri_Ini_New.reshape((IN_Tri_Ini_New.shape[0]/3,3))
    IN_Tri=nparray(IN_Tri)
    IN_Tri=IN_Tri.reshape((IN_Tri.shape[0]/3,3))
    IN_Tet=nparray(IN_Tet)
    IN_Tet=IN_Tet.reshape((IN_Tet.shape[0]/4,4))
    INV_NN=nparray(INV_NN)
    INV_NN=INV_NN.reshape((INV_NN.shape[0]/3,3))
    PNV_NN=nparray(PNV_NN)
    PNV_NN=PNV_NN.reshape((PNV_NN.shape[0]/3,3))
    IN_New_Old=nparray(IN_New_Old)
    IN_Old_New=nparray(IN_Old_New)
    
    return [[Vol_Cel,Nb_Contrib,INV,Grad],\
            XYZ_Noeud_New,IN_Tri_Ini_New,\
            IN_Tri,IN_Tet,\
            INV_NN,PNV_NN,\
            IN_New_Old,IN_Old_New]

def mesh(XYZ_Noeud,IN_Tri_Ini):

    Type_Call_Tet=0
    [IN_New_Old,IN_Old_New,New_Noeud,IN_Tri,IN_Tet]=\
    CNEM3D.MESH_CNEM3D(XYZ_Noeud,IN_Tri_Ini,Type_Call_Tet)

    XYZ_Noeud_New=list()
    for i in IN_Old_New :
        XYZ_Noeud_New.extend(XYZ_Noeud[3*(i-1):3*i])
    XYZ_Noeud_New.extend(New_Noeud)

    IN_Tri_Ini_New=list()
    for i in range(len(IN_Tri_Ini)) :
        IN_Tri_Ini_New.append(IN_New_Old[IN_Tri_Ini[i]]-1)

    XYZ_Noeud_New=nparray(XYZ_Noeud_New)
    XYZ_Noeud_New=XYZ_Noeud_New.reshape((XYZ_Noeud_New.shape[0]/3,3))
    IN_Tri_Ini_New=nparray(IN_Tri_Ini_New)
    IN_Tri_Ini_New=IN_Tri_Ini_New.reshape((IN_Tri_Ini_New.shape[0]/3,3))
    IN_Tri=nparray(IN_Tri)
    IN_Tri=IN_Tri.reshape((IN_Tri.shape[0]/3,3))
    IN_Tet=nparray(IN_Tet)
    IN_Tet=IN_Tet.reshape((IN_Tet.shape[0]/4,4))
    IN_New_Old=nparray(IN_New_Old)
    IN_Old_New=nparray(IN_Old_New)
    
    return [XYZ_Noeud_New,IN_Tri_Ini_New,\
            IN_Tri,IN_Tet,\
            IN_New_Old,IN_Old_New]
