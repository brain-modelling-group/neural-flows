##
## Copyright (C) 2003-2011
## Lounes ILLOUL (illoul_lounes@yahoo.fr)
## Philippe LORONG (philippe.lorong@ensam.eu)
## Arts et Metiers ParisTech, Paris, France
##
## $Revision$ - $Date$

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
#assembling for mechanic :
print '\n--------------------------------------------------------------------------------\n'
print 'assembling\n'

n=len(GS[0])

E_NU=list()
E_NU.append((200.e9,0.266))

[B,C,V]=py_assembling.meca(GS,E_NU)
MK=B.transpose()*(V*C)*B

#-------------------------------------------------------------------------------
#solve case :
print '\n--------------------------------------------------------------------------------\n'
print 'solve case...\n'

#boundary condition definition :
#   U,V deplacement = 0 on Y=0   
#   U = 0 and V=0.1 on Y=1 

v=0.1

n_y_0=list()
n_y_1=list()
n_c_ext=Ind_Noeud_Front[0:Nb_Noeud_Front[0]]

for i in n_c_ext:
    if abs(XY_Noeud[i,1])<1.e-6:
        n_y_0.append(i)
    elif abs(XY_Noeud[i,1]-1.)<1.e-6:
        n_y_1.append(i)

n_y_0=np.array(n_y_0)
n_y_1=np.array(n_y_1)

DDL_U_y_0=n_y_0*2
DDL_V_y_0=n_y_0*2+1
DDL_U_y_1=n_y_1*2
DDL_V_y_1=n_y_1*2+1

UV=np.zeros(2*n)

UV[DDL_U_y_0]=0.
UV[DDL_U_y_0]=v
UV[DDL_V_y_1]=0.
UV[DDL_V_y_1]=0.

DDL_bloc=np.hstack([DDL_U_y_0,DDL_V_y_0,DDL_U_y_1,DDL_V_y_1])
DDL_bloc=np.unique(DDL_bloc)
DDL_Tot=np.array(range(2*n))
DDL_Libre=np.setdiff1d(DDL_Tot,DDL_bloc)

b=-(MK[:,DDL_bloc]*UV[DDL_bloc])
MK=MK[DDL_Libre,:]
MK=MK[:,DDL_Libre]

#solve the linear problem

UV[DDL_Libre]=spsolve(MK,b[DDL_Libre])
#UV[DDL_Libre]=gmres(MK,b[DDL_Libre])[0]

Strain=B*UV 
Stress=C*Strain;
Stress=Stress.reshape((np.size(Stress,0)/3,3))
UV=UV.reshape((np.size(UV,0)/2,2))

#-------------------------------------------------------------------------------
# write the result :
print '\n--------------------------------------------------------------------------------\n'
print 'write result to vtk format for paraview'

outvar.vtk(XY_Noeud,Tri,Stress,UV,0)

#-------------------------------------------------------------------------------
