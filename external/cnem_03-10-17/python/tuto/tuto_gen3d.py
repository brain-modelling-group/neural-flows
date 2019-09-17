##
## Copyright (C) 2003-2011
## Lounes ILLOUL (illoul_lounes@yahoo.fr)
## Philippe LORONG (philippe.lorong@ensam.eu)
## Arts et Metiers ParisTech, Paris, France
##
## $Revision$ - $Date$

import sys
import os
import shutil
import re
import math
import cPickle
import numpy as np
import scipy as sp
from scipy.sparse import coo_matrix
from scipy.sparse.linalg.dsolve import spsolve
from scipy.sparse.linalg.isolve import gmres

sys.path.append('../bin')
    
import load_node_front
import py_cnem3d
import check_gs
import py_assembling
import outvar

#-------------------------------------------------------------------------------
# read nodes and boundary :
print '\n--------------------------------------------------------------------------------\n'
print 'read node and boundary...\n'

[XYZ_Noeud,IN_Tri_Ini]=load_node_front.load3d('data3d_big/')

#-------------------------------------------------------------------------------
# call scni cnem3d :
print '\n--------------------------------------------------------------------------------\n'

Type_FF=0
Sup_NN_GS=0

[GS,XYZ_Noeud,IN_Tri_Ini,IN_Tri,IN_Tet,INV_NN,PNV_NN,INNO,INON]=\
py_cnem3d.scni(XYZ_Noeud,IN_Tri_Ini,Type_FF,Sup_NN_GS)

#print '\ncheck scni...\n'
#check_gs.check(GS,XYZ_Noeud[0:n,:])

#-------------------------------------------------------------------------------
# assembling for thermal :
print '\n--------------------------------------------------------------------------------\n'
print 'assembling'

n=len(GS[0])

Mat_A=np.array([[1.,0.,0.,0.],\
                [0.,1.,0.,0.],\
                [0.,0.,1.,0.]])

Mat_D=np.zeros((3*n,3))
for i in range(n):
    e=10.*XYZ_Noeud[i,0]+1.
    Mat_D[3*i:3*(i+1),:]=np.array([[e ,0.,0.],\
                                   [0.,e ,0.],\
                                   [0.,0.,e ]])
    
[B,C,V]=py_assembling.gen(GS,Mat_A,Mat_D)
K=list()
for i in range(n):
    K.append(10.*XYZ_Noeud[i,1]+1.)
    
[B,C,V]=py_assembling.thermal(GS,K)
MK=B.transpose()*(V*C)*B

#-------------------------------------------------------------------------------
# solve case :
print '\n--------------------------------------------------------------------------------\n'
print 'solve case...\n'

#boundary condition definition :
#   T=T1 on external boundary 
#   T=T2 on internal boundary

IN_Front=set(IN_Tri.flatten())
C=np.array([0.5,0.5,0.5])
n_C=[list(),list()]
for i in IN_Front:
    N=XYZ_Noeud[i,:]
    r=np.sqrt(sum((N-C)**2))
    if (r>0.2) and (r<0.3) :
        n_C[1].append(i)
    else :
        n_C[0].append(i)
        
n_C_ext=np.array(n_C[0])
n_C_int=np.array(n_C[1])

T1=0
T2=1

T=np.zeros(n)

T[n_C_ext]=T1
T[n_C_int]=T2

DDL_bloc=np.hstack([n_C_ext,n_C_int])
DDL_bloc=np.unique(DDL_bloc)
DDL_Tot=np.array(range(n))
DDL_Libre=np.setdiff1d(DDL_Tot,DDL_bloc)

b=-(MK[:,DDL_bloc]*T[DDL_bloc])
MK=MK[DDL_Libre,:]
MK=MK[:,DDL_Libre]

#solve the linear problem

T[DDL_Libre]=spsolve(MK,b[DDL_Libre])
#T[DDL_Libre]=gmres(MK,b[DDL_Libre])[0]

#-------------------------------------------------------------------------------
# write the result :
print '\n--------------------------------------------------------------------------------\n'
print 'write result to vtk format for paraview'

outvar.vtk(XYZ_Noeud,IN_Tet,T,None,0)
    
#-------------------------------------------------------------------------------














