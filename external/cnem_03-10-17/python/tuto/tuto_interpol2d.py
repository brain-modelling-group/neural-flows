##
## Copyright (C) 2003-2011
## Lounes ILLOUL (illoul_lounes@yahoo.fr)
## Philippe LORONG (philippe.lorong@ensam.eu)
## Arts et Metiers ParisTech, Paris, France
##
## $Revision$ - $Date$

import shutil
import re
import math
import cPickle
import numpy as np
import scipy as sp

import sys
sys.path.append('../bin')
import load_node_front
import py_cnem2d

#-------------------------------------------------------------------------------
# read nodes and boundary :
print '\n--------------------------------------------------------------------------------\n'
print 'read node and boundary...\n'

[XY_Noeud,Nb_Noeud_Front,Ind_Noeud_Front]=load_node_front.load2d('data2d_big/')

#-------------------------------------------------------------------------------
# creat dummy point location for interpolation evaluation

XY_Point=list((np.random.random(100000*2)-0.5)*1.5+0.5)

#-------------------------------------------------------------------------------
# creat the interpolator
print '\n--------------------------------------------------------------------------------\n'
print 'creat the interpolator...\n'

interpol=py_cnem2d.interpol(XY_Noeud,Nb_Noeud_Front,Ind_Noeud_Front,XY_Point)

#----------------------------------------------------------------------------
# interpolate variable filds : Var
print '\n--------------------------------------------------------------------------------\n'
print 'interpolate variable filds...\n'

# test : Var = XY_Noeud ==> interpolated Var on XY_Point = XY_Point

Var=np.array(XY_Noeud)
Var=Var.reshape((Var.shape[0]/2,2))

#interpolate Var :
Var_Int=interpol.interpolate(Var)

XY_Point=np.array(XY_Point)
XY_Point=XY_Point.reshape((XY_Point.shape[0]/2,2))

Dif=Var_Int-XY_Point

maxdif=0.

for i in xrange(len(Dif)):
    if interpol.In_Out[i] : # point interpolation in the domain 
        maxdif_i=max(abs(Dif[i]))
        if maxdif_i>maxdif:
            maxdif=maxdif_i
        
print 'err max : ', maxdif

#-------------------------------------------------------------------------------
