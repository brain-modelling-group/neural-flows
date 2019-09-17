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

import CNEM2D
from numpy import array as nparray
from numpy import zeros
from scipy import sparse

class interpol:

    def __init__(self,XY_Noeud,Nb_Noeud_Front,Ind_Noeud_Front,XY_Point):

        [IN_New_Old,IN_Old_New,Nb_Contrib,INV,FF] = \
        CNEM2D.INTERPOL_CNEM2D(XY_Noeud,Nb_Noeud_Front,Ind_Noeud_Front,XY_Point)

        INV=list(INV)
        
        IN_New_Old=nparray(IN_New_Old)-1
        IN_Old_New=nparray(IN_Old_New)-1

        for i in range(len(INV)):
            INV[i]=IN_Old_New[INV[i]]

        indptr=zeros(len(Nb_Contrib)+1,dtype='int')
        indptr[1:len(Nb_Contrib)+1]=Nb_Contrib
        for i in xrange(len(Nb_Contrib)):
            indptr[i+1]+=indptr[i]
        self.Mat_INT=sparse.csr_matrix((FF,INV,indptr),shape=(len(XY_Point)/2,len(XY_Noeud)/2),dtype='double')
        
        self.In_Out=nparray(Nb_Contrib,dtype='int')

    def interpolate(self,Var):

        return self.Mat_INT*Var

def mesh(XY_Noeud,Nb_Noeud_Front,Ind_Noeud_Front):
   
    [Ind_Noeud_New_Old,Ind_Noeud_Old_New,Tri] = \
    CNEM2D.MESH_CNEM2D(XY_Noeud,Nb_Noeud_Front,Ind_Noeud_Front)

    XY_Noeud_New=list()
    for i in Ind_Noeud_Old_New :
        XY_Noeud_New.append(XY_Noeud[2*(i-1)])
        XY_Noeud_New.append(XY_Noeud[2*(i-1)+1])

    Ind_Noeud_Front_New=list()
    for i in range(len(Ind_Noeud_Front)) :
        Ind_Noeud_Front_New.append(Ind_Noeud_New_Old[Ind_Noeud_Front[i]]-1)

    XY_Noeud_New=nparray(XY_Noeud_New)
    XY_Noeud_New=XY_Noeud_New.reshape((XY_Noeud_New.shape[0]/2,2))
    Tri=nparray(Tri)
    Tri=Tri.reshape((Tri.shape[0]/3,3))

    return [XY_Noeud_New,Ind_Noeud_Front_New,Tri,Ind_Noeud_New_Old,Ind_Noeud_Old_New]

def scni(XY_Noeud,Nb_Noeud_Front,Ind_Noeud_Front):
   
    [Ind_Noeud_New_Old,Ind_Noeud_Old_New,Vol_Cel,XY_CdM,Nb_Contrib,INV,Grad,Tri] = \
    CNEM2D.SCNI_CNEM2D(XY_Noeud,Nb_Noeud_Front,Ind_Noeud_Front)

    XY_Noeud_New=list()
    for i in Ind_Noeud_Old_New :
        XY_Noeud_New.append(XY_Noeud[2*(i-1)])
        XY_Noeud_New.append(XY_Noeud[2*(i-1)+1])

    Ind_Noeud_Front_New=list()
    for i in range(len(Ind_Noeud_Front)) :
        Ind_Noeud_Front_New.append(Ind_Noeud_New_Old[Ind_Noeud_Front[i]]-1)

    XY_Noeud_New=nparray(XY_Noeud_New)
    XY_Noeud_New=XY_Noeud_New.reshape((XY_Noeud_New.shape[0]/2,2))
    Tri=nparray(Tri)
    Tri=Tri.reshape((Tri.shape[0]/3,3))
    XY_CdM=nparray(XY_CdM)
    XY_CdM=XY_CdM.reshape((XY_CdM.shape[0]/2,2))

    return [[Vol_Cel,Nb_Contrib,INV,Grad,XY_CdM],XY_Noeud_New,Ind_Noeud_Front_New,Tri,Ind_Noeud_New_Old,Ind_Noeud_Old_New]

