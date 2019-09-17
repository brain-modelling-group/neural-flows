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
# draw tri :

#draw2d.tri(Tri,XY_Noeud)

#-------------------------------------------------------------------------------
#assembling for hydrodynamic
print '\n--------------------------------------------------------------------------------\n'
print 'assembling\n'

n=len(GS[0])

NU=list()
NU.append((1.))

[B,C,V]=py_assembling.hydrodyn(GS,NU) 
MK=B.transpose()*(V*C)*B

#-------------------------------------------------------------------------------
#solve case :
print '\n--------------------------------------------------------------------------------\n'
print 'solve case...\n'

# boundary condition definition :
# on external boundary :
#   U = u_inf , V = 0. on X=0   
#   V = 0 on Y = 0 and Y = 1.
# on internal boundary : 
#   U,V = 0

u_inf=1.

n_x_0=list()
n_x_1=list()
n_y_0=list()
n_y_1=list()
n_c_ext=Ind_Noeud_Front[0:Nb_Noeud_Front[0]]
n_c_int=Ind_Noeud_Front[Nb_Noeud_Front[0]:]

for i in n_c_ext:
    if abs(XY_Noeud[i,0])<1.e-6:
        n_x_0.append(i)
    elif abs(XY_Noeud[i,0]-1.)<1.e-6:
        n_x_1.append(i)
        
    if abs(XY_Noeud[i,1])<1.e-6:
        n_y_0.append(i)
    elif abs(XY_Noeud[i,1]-1.)<1.e-6:
        n_y_1.append(i)
        
n_x_0=np.array(n_x_0)
n_x_1=np.array(n_x_1)
n_y_0=np.array(n_y_0)
n_y_1=np.array(n_y_1)
n_c_int=np.array(n_c_int)

DDL_U_x_0=n_x_0*3
DDL_V_x_0=n_x_0*3+1

DDL_V_y_0=n_y_0*3+1
DDL_V_y_1=n_y_1*3+1

DDL_U_c_int=n_c_int*3
DDL_V_c_int=n_c_int*3+1

UVP=np.zeros(3*n)

UVP[DDL_U_x_0]=u_inf
UVP[DDL_V_x_0]=0.
UVP[DDL_V_y_0]=0.
UVP[DDL_V_y_1]=0.
UVP[DDL_U_c_int]=0.
UVP[DDL_V_c_int]=0.

DDL_bloc=np.hstack([DDL_U_x_0,DDL_V_x_0,DDL_V_y_0,DDL_V_y_1,DDL_U_c_int,DDL_V_c_int])
DDL_bloc=np.unique(DDL_bloc)
DDL_Tot=np.array(range(3*n))
DDL_Libre=np.setdiff1d(DDL_Tot,DDL_bloc)

b=-(MK[:,DDL_bloc]*UVP[DDL_bloc])
MK=MK[DDL_Libre,:]
MK=MK[:,DDL_Libre]

#solve the linear problem

UVP[DDL_Libre]=spsolve(MK,b[DDL_Libre])
#UVP[DDL_Libre]=gmres(MK,b[DDL_Libre])[0]

UVP=UVP.reshape((np.size(UVP,0)/3,3))

#-------------------------------------------------------------------------------
# write the result :
print '\n--------------------------------------------------------------------------------\n'
print 'write result to vtk format for paraview'

outvar.vtk(XY_Noeud,Tri,UVP[:,2],UVP[:,[0,1]],0)

#-------------------------------------------------------------------------------
