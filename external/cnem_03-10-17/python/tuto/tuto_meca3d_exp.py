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

[XYZ_Noeud,IN_Tri_Ini]=load_node_front.load3d('bare/')

#-------------------------------------------------------------------------------
# call scni cnem3d :
print '\n--------------------------------------------------------------------------------\n'

Type_FF=0
Sup_NN_GS=1

[GS,XYZ_Noeud,IN_Tri_Ini,IN_Tri,IN_Tet,INV_NN,PNV_NN,INNO,INON]=\
py_cnem3d.scni(XYZ_Noeud,IN_Tri_Ini,Type_FF,Sup_NN_GS)

#print '\ncheck scni...\n'
#check_gs.check(GS,XYZ_Noeud[0:n,:])

#-------------------------------------------------------------------------------
# assembling for mechanic  :
print '\n--------------------------------------------------------------------------------\n'
print 'cal B, Behav, Vol, Mas...\n'

n=len(GS[0])

E_NU=[(200.e9,0.266)]
Rho=[7800]

[B,BehavElast,Vol]=py_assembling.meca(GS,E_NU)

M=py_assembling.cal_Mas(GS[0],3,Rho,0)

#-------------------------------------------------------------------------------
#solve case :
print '\n--------------------------------------------------------------------------------\n'
print 'solve case...\n'

#inial condition :

# displacement on X==0 = 0

n_Bloc=list()
for i in range(0,n):
    if abs(XYZ_Noeud[i,0])<1.e-6:
        n_Bloc.append(i)
        
n_Bloc=np.array(n_Bloc)

DDL_U_Bloc=n_Bloc*3
DDL_V_Bloc=n_Bloc*3+1
DDL_W_Bloc=n_Bloc*3+2

# variables initialization

U=np.zeros(3*n)
Uo=np.zeros(3*n)
Uo[0:3*n:3]=-1.
Uoo=np.zeros(3*n)

Strain=np.zeros(6*n)
Stress=np.zeros(6*n)
SigMis=np.zeros(n)

FInt=np.zeros(3*n)
FExt=np.zeros(3*n)

################################################
# CRITICAL !!! TO BE MODIFIED FOR EVERY MESH !!!
# , the minimal edge mesh length
Distance_Noeuds_Min=5.e-3
################################################

Coef_Reduc_Pas_Temps=0.5
celerite=math.sqrt(E_NU[0][0]/Rho[0])
dt=Coef_Reduc_Pas_Temps*Distance_Noeuds_Min/celerite

# the incremental loop : time integration 

print 'dt=',dt

t=0
inc=0
nb_inc=1000

nb_inc_out=10

while inc<nb_inc:
    
    print 'inc=',inc

    # compute strain
    Strain[:]=B*U

    # compute stress
    Stress[:]=BehavElast*Strain

    #compute internal forces
    FInt[:]=-(Stress*Vol)*B

    #compute external forces (None)
    #FExt[:]=Cal_FExt

    #compute new acceleration
    Uoo[:]=(FExt+FInt)/M

    #compute new velocity
    Uo[:]=Uo+Uoo*dt

    #compute new dispalacement
    U[:]=U+Uo*dt

    # dispalacement boundary condition imposition
    U[DDL_U_Bloc]=0.
    U[DDL_V_Bloc]=0.
    U[DDL_W_Bloc]=0.

    # out sigma mises, and displacement for
    #   paraview eatch nb_inc_out increment 
    if not inc%nb_inc_out :
        # compute sigma mises
        SigMis[:]=((Stress[0::6]-Stress[1::6])**2+\
                   (Stress[0::6]-Stress[2::6])**2+\
                   (Stress[1::6]-Stress[2::6])**2+\
                 6*(Stress[3::6]**2+\
                    Stress[4::6]**2+\
                    Stress[5::6]**2));
        # out 
        outvar.vtk(XYZ_Noeud[0:n,:],IN_Tri_Ini,SigMis,U.reshape((n,3)),inc)
        
    t+=dt
    inc+=1
    
#-------------------------------------------------------------------------------

