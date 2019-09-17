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
#assembling for hydrodynamic :
print '\n--------------------------------------------------------------------------------\n'
print 'assembling...\n'

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
#   U = u_inf , V,W = 0. , on X=0   
#   V = 0 on Y = 0 , Y = 1. , Z = 0. and Z = 1. 
# on internal boundary : 
#   U,V,W = 0.

u_inf=1.
p_inf=0.

n_x_0=list()
n_x_1=list()
n_y_0=list()
n_y_1=list()
n_z_0=list()
n_z_1=list()
n_c_int=list()

IN_Front=set(IN_Tri.flatten())
C=np.array([0.5,0.5,0.5])
n_C=[list(),list()]
for i in IN_Front:
    N=XYZ_Noeud[i,:]
    
    if abs(N[0])<1.e-6:
        n_x_0.append(i)
    if abs(N[0]-1.)<1.e-6:
        n_x_1.append(i)
    if abs(N[1])<1.e-6:
        n_y_0.append(i)
    if abs(N[1]-1.)<1.e-6:
        n_y_1.append(i)
    if abs(N[2])<1.e-6:
        n_z_0.append(i)
    if abs(N[2]-1.)<1.e-6:
        n_z_1.append(i)
    r=np.sqrt(sum((N-C)**2))
    if (r>0.2) and (r<0.3) :
        n_c_int.append(i)

n_x_0=np.array(n_x_0)
n_x_1=np.array(n_x_1)
n_y_0=np.array(n_y_0)
n_y_1=np.array(n_y_1)
n_z_0=np.array(n_z_0)
n_z_1=np.array(n_z_1)
n_c_int=np.array(n_c_int)
        
DDL_U_x_0=4*n_x_0
DDL_V_x_0=4*n_x_0+1
DDL_W_x_0=4*n_x_0+2
DDL_U_y_0=4*n_y_0
DDL_V_y_0=4*n_y_0+1
DDL_W_y_0=4*n_y_0+2
DDL_U_y_1=4*n_y_1
DDL_V_y_1=4*n_y_1+1
DDL_W_y_1=4*n_y_1+2
DDL_U_z_0=4*n_z_0
DDL_V_z_0=4*n_z_0+1
DDL_W_z_0=4*n_z_0+2
DDL_U_z_1=4*n_z_1
DDL_V_z_1=4*n_z_1+1
DDL_W_z_1=4*n_z_1+2
DDL_U_n_c_int=4*n_c_int
DDL_V_n_c_int=4*n_c_int+1
DDL_W_n_c_int=4*n_c_int+2

UVWP=np.zeros(4*n)

UVWP[DDL_U_x_0]=u_inf
UVWP[DDL_V_x_0]=0.
UVWP[DDL_W_x_0]=0.
UVWP[DDL_U_y_0]=0.
UVWP[DDL_V_y_0]=0.
UVWP[DDL_W_y_0]=0.
UVWP[DDL_U_y_1]=0.
UVWP[DDL_V_y_1]=0.
UVWP[DDL_W_y_1]=0.
UVWP[DDL_U_z_0]=0.
UVWP[DDL_V_z_0]=0.
UVWP[DDL_W_z_0]=0.
UVWP[DDL_U_z_1]=0.
UVWP[DDL_V_z_1]=0.
UVWP[DDL_W_z_1]=0.
UVWP[DDL_U_n_c_int]=0.
UVWP[DDL_V_n_c_int]=0.
UVWP[DDL_W_n_c_int]=0.

DDL_bloc=np.hstack([DDL_U_x_0,DDL_V_x_0,DDL_W_x_0,DDL_U_y_0,DDL_V_y_0,DDL_W_y_0,\
                    DDL_U_y_1,DDL_V_y_1,DDL_W_y_1,DDL_U_z_0,DDL_V_z_0,DDL_W_z_0,\
                    DDL_U_z_1,DDL_V_z_1,DDL_W_z_1,DDL_U_n_c_int,DDL_V_n_c_int,DDL_W_n_c_int])
DDL_bloc=np.unique(DDL_bloc)
DDL_Tot=np.array(range(4*n))
DDL_Libre=np.setdiff1d(DDL_Tot,DDL_bloc)

b=-(MK[:,DDL_bloc]*UVWP[DDL_bloc])
MK=MK[DDL_Libre,:]
MK=MK[:,DDL_Libre]

#solve the linear problem

UVWP[DDL_Libre]=spsolve(MK,b[DDL_Libre])
#UVWP[DDL_Libre,0]=gmres(MK,b[DDL_Libre])[0]
UVWP=UVWP.reshape((UVWP.shape[0]/4,4))

#-------------------------------------------------------------------------------
# write the result :
print '\n--------------------------------------------------------------------------------\n'
print 'write result to vtk format for paraview'

outvar.vtk(XYZ_Noeud,IN_Tet,UVWP[:,3],UVWP[:,0:3],0)
    
#-------------------------------------------------------------------------------

