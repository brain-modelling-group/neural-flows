##
## Copyright (C) 2003-2011
## Lounes ILLOUL (illoul_lounes@yahoo.fr)
## Philippe LORONG (philippe.lorong@ensam.eu)
## Arts et Metiers ParisTech, Paris, France
##
## $Revision:$ - $Date:$

import sys
import os
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
import py_cnem2d
import check_gs
import py_assembling
import outvar

#-------------------------------------------------------------------------------
# read nodes and boundary :
print '\n--------------------------------------------------------------------------------\n'
print 'read node and boundary...\n'

[XY_Noeud,Nb_Noeud_Front,Ind_Noeud_Front]=load_node_front.load2d('data2d_big/')

#-------------------------------------------------------------------------------
# call scni cnem2d :
print '\n--------------------------------------------------------------------------------\n'

[GS,XY_Noeud,Ind_Noeud_Front,Tri,INNO,INON]=py_cnem2d.scni(XY_Noeud,Nb_Noeud_Front,Ind_Noeud_Front)

#print '\ncheck scni...\n'
#check_gs.check(GS,XY_Noeud)

#-------------------------------------------------------------------------------
# draw tri :

#draw2d.tri(Tri,XY_Noeud)

#-------------------------------------------------------------------------------
# assembling for thermal
print '\n--------------------------------------------------------------------------------\n'
print 'assembling\n'

# for this exemple, we use variable thermal conductity k,
# depending on the x position : k=10*x+1

n=len(GS[0])

Mat_A=np.array([[1.,0.,0.],\
                [0.,1.,0.]])

Mat_D=np.zeros((2*n,2))
for i in range(n):
    e=10.*XY_Noeud[i,0]+1.
    Mat_D[2*i:2*(i+1),:]=np.array([[e ,0.],\
                                   [0.,e ]])
    
[B,C,V]=py_assembling.gen(GS,Mat_A,Mat_D) 
MK=B.transpose()*(V*C)*B

#-------------------------------------------------------------------------------
# solve case :
print '\n--------------------------------------------------------------------------------\n'
print 'solve case...\n'

#boundary condition definition :
#   T=T1 on external boundary 
#   T=T2 on internal boundary

T1=0
T2=1

n_C_ext=np.array(Ind_Noeud_Front[0:Nb_Noeud_Front[0]])
n_C_int=np.array(Ind_Noeud_Front[Nb_Noeud_Front[0]:])

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

outvar.vtk(XY_Noeud,Tri,T,None,0)

#-------------------------------------------------------------------------------
