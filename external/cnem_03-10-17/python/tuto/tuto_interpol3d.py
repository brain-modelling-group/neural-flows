##
## Copyright (C) 2003-2011
## Lounes ILLOUL (illoul_lounes@yahoo.fr)
## Philippe LORONG (philippe.lorong@ensam.eu)
## Arts et Metiers ParisTech, Paris, France
##
## $Revision: 25 $ - $Date: 2012-02-22 17:36:30 +0100 (mer., 22 fevr. 2012) $

import shutil
import re
import math
import cPickle
import numpy as np
import scipy as sp

import sys
sys.path.append('../bin')
import load_node_front
import py_cnem3d

#-------------------------------------------------------------------------------
# read nodes and boundary :
print '\n--------------------------------------------------------------------------------\n'
print 'read node and boundary...\n'

[XYZ_Noeud,IN_Tri_Ini]=load_node_front.load3d('cubeuni3d/')

#-------------------------------------------------------------------------------
# creat dummy point location for interpolation evaluation

XYZ_Point=list((np.random.random(1000000*3)-0.5)*0.15)

#-------------------------------------------------------------------------------
# creat the interpolator
print '\n--------------------------------------------------------------------------------\n'
print 'creat the interpolator...\n'


Type_FF=0

interpol=py_cnem3d.interpol(XYZ_Noeud,IN_Tri_Ini,XYZ_Point,Type_FF)

## if we don't enter the boundary tri IN_Tri_Ini, the convex hull of the nodes
##    will be taken as boundary, let's try :

#interpol=py_cnem3d.interpol(XYZ_Noeud,[],XYZ_Point,Type_FF)

#----------------------------------------------------------------------------
# interpolate variable filds : Var
print '\n--------------------------------------------------------------------------------\n'
print 'interpolate variable filds...\n'

# test : Var = XYZ_Noeud ==> interpolated Var on XYZ_Point = XYZ_Point

Var=np.array(XYZ_Noeud)
Var=Var.reshape((Var.shape[0]/3,3))

#interpolate Var :
#Var_Int=interpol.interpolate(Var)

Mat_Int=interpol.mat_interpol_glob()
Var_Int=Mat_Int*Var

XYZ_Point=np.array(XYZ_Point)
XYZ_Point=XYZ_Point.reshape((XYZ_Point.shape[0]/3,3))

Dif=Var_Int-XYZ_Point

maxdif=0.

for i in xrange(len(Dif)):
    if interpol.In_Out[i] : # point interpolation in the domain 
        maxdif_i=max(abs(Dif[i]))
        if maxdif_i>maxdif:
            maxdif=maxdif_i
        
print 'err max : ', maxdif

#-------------------------------------------------------------------------------
