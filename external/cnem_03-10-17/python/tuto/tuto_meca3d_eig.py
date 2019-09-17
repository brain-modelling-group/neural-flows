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
from scipy.sparse.linalg.eigen.arpack import eigen_symmetric

sys.path.append('../bin')

import load_node_front
import py_cnem3d
import check_gs
import py_assembling
import out_var3

import cal_mode_propre

#-------------------------------------------------------------------------------
# read nodes and boundary :
print '\n--------------------------------------------------------------------------------\n'
print 'read node and boundary...\n'

[XYZ_Noeud,IN_Tri_Ini]=load_node_front.load3d('bare/')

#-------------------------------------------------------------------------------
# call scni cnem3d :
print '\n--------------------------------------------------------------------------------\n'

Type_FF=0
Sup_NN_GS=0

[GS,XYZ_Noeud,IN_Tri_Ini,IN_Tri,IN_Tet,INV_NN,PNV_NN,INNO,INON]=\
py_cnem3d.scni(XYZ_Noeud,IN_Tri_Ini,Type_FF,Sup_NN_GS)

#print '\ncheck scni...\n'
#check_gs.check(GS,XYZ_Noeud)

#-------------------------------------------------------------------------------
# assembling for mechanics :
print '\n--------------------------------------------------------------------------------\n'
print 'cal K meca...\n'

n=len(GS[0])

E_NU=[(200.e9,0.266)]
Rho=[7800]

[B,C,V]=py_assembling.meca(GS,E_NU)
MK=B.transpose()*(V*C)*B
invMM=py_assembling.cal_Mas(GS[0],3,Rho,1,1)

#-------------------------------------------------------------------------------
#solve case :
print '\n--------------------------------------------------------------------------------\n'
print 'solve case...\n'

#boundary condition definition :
#   U,V,W deplacement = 0 on X=0   

n_Bloc=list()
for i in range(0,n):
    if abs(XYZ_Noeud[i,0])<1.e-6:
        n_Bloc.append(i)
        
n_Bloc=np.array(n_Bloc)

DDL_U_Bloc=n_Bloc*3
DDL_V_Bloc=n_Bloc*3+1
DDL_W_Bloc=n_Bloc*3+2

DDL_bloc=np.hstack([DDL_U_Bloc,DDL_V_Bloc,DDL_W_Bloc])
DDL_bloc=np.unique(DDL_bloc)

DDL_Tot=np.array(range(3*n))
DDL_Libre=np.setdiff1d(DDL_Tot,DDL_bloc)

MK=MK[DDL_Libre,:]
MK=MK[:,DDL_Libre]

invMM=invMM[DDL_Libre,:]
invMM=invMM[:,DDL_Libre]

nb_mode=5
[ValPro,VecPro]=eigen_symmetric(invMM*MK,k=nb_mode,which='SM')

#-------------------------------------------------------------------------------
# write the result :
print '\n--------------------------------------------------------------------------------\n'
print 'write result to vtk format'

UVW=np.zeros((3*n,nb_mode))
UVW[DDL_Libre,:]=VecPro

UVW_bis=np.zeros((3*n,nb_mode))
UVW_bis[0:n,:]=UVW[0:3*n:3,:]
UVW_bis[n:2*n,:]=UVW[1:3*n:3,:]
UVW_bis[2*n:3*n,:]=UVW[2:3*n:3,:]
UVW_bis=UVW_bis.flatten('F')
UVW_bis=UVW_bis.reshape((n,nb_mode*3),order='F')

out_var3.vtk(XYZ_Noeud,IN_Tet,None,UVW_bis,0)

#-------------------------------------------------------------------------------

