##
## Copyright (C) 2003-2011
## Lounes ILLOUL (illoul_lounes@yahoo.fr)
## Philippe LORONG (philippe.lorong@ensam.eu)
## Arts et Metiers ParisTech, Paris, France
##
## $Revision: 25 $ - $Date: 2012-02-22 17:36:30 +0100 (mer., 22 fevr. 2012) $

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

[XYZ_Noeud,IN_Tri_Ini]=load_node_front.load3d('data3d_small/')

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
# assembling for mechanic  :
print '\n--------------------------------------------------------------------------------\n'
print 'assembling...\n'

n=len(GS[0])

E_NU=[(200.e9,0.266)]

[B,C,V]=py_assembling.meca(GS,E_NU)
MK=B.transpose()*(V*C)*B

#-------------------------------------------------------------------------------
#solve case :
print '\n--------------------------------------------------------------------------------\n'
print 'solve case...\n'

#boundary condition definition :
#   U,V,W deplacement = 0 on Z=0   
#   U,W = 0 and V=0.1 on Z=1 

v=0.1

n_z_0=list()
n_z_1=list()

IN_Front=set(IN_Tri.flatten())

for i in IN_Front:
    N=XYZ_Noeud[i,:]
    
    if abs(N[2])<1.e-6:
        n_z_0.append(i)
    elif abs(N[2]-1.)<1.e-6:
        n_z_1.append(i)

n_z_0=np.array(n_z_0)
n_z_1=np.array(n_z_1)

DDL_U_z_0=n_z_0*3
DDL_V_z_0=n_z_0*3+1
DDL_W_z_0=n_z_0*3+2
DDL_U_z_1=n_z_1*3
DDL_V_z_1=n_z_1*3+1
DDL_W_z_1=n_z_1*3+2

UVW=np.zeros(3*n)

UVW[DDL_U_z_0]=0.
UVW[DDL_V_z_0]=0.
UVW[DDL_W_z_0]=0.
UVW[DDL_U_z_1]=0.
UVW[DDL_V_z_1]=v
UVW[DDL_W_z_1]=0.

DDL_bloc=np.hstack([DDL_U_z_0,DDL_V_z_0,DDL_W_z_0,DDL_V_z_1,DDL_U_z_1,DDL_W_z_1])
DDL_bloc=np.unique(DDL_bloc)
DDL_Tot=np.array(range(3*n))
DDL_Libre=np.setdiff1d(DDL_Tot,DDL_bloc)

b=-(MK[:,DDL_bloc]*UVW[DDL_bloc])
MK=MK[DDL_Libre,:]
MK=MK[:,DDL_Libre]

#solve the linear problem

UVW[DDL_Libre]=spsolve(MK,b[DDL_Libre])
#UVW[DDL_Libre]=gmres(MK,b[DDL_Libre])[0]

Strain=B*UVW 
Stress=C*Strain;
Stress=Stress.reshape(Stress.shape[0]/6,6)
UVW=UVW.reshape((UVW.shape[0]/3,3))

#-------------------------------------------------------------------------------
# write the result :
print '\n--------------------------------------------------------------------------------\n'
print 'write result to vtk format for paraview'

outvar.vtk(XYZ_Noeud,IN_Tet,Stress,UVW,0)
    
#-------------------------------------------------------------------------------

