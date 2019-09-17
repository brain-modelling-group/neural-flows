##
## This file is part of CNEMLIB.
## 
## Copyright (C) 2003-2011
## Lounes ILLOUL (illoul_lounes@yahoo.fr)
## Philippe LORONG (philippe.lorong@ensam.eu)
## Arts et Metiers ParisTech, Paris, France
## 
## CNEMLIB is free software: you can redistribute it and/or modify
## it under the terms of the GNU Lesser General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## CNEMLIB is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU Lesser General Public License for more details.
##
## You should have received a copy of the GNU Lesser General Public License
## along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
##
## Please report bugs to illoul_lounes@yahoo.fr 

import numpy as np
from scipy.sparse import coo_matrix

def check(GS,Coord):
    row=np.zeros(len(GS[2]))
    k=0
    for i in range(len(GS[1])):
        for j in range(GS[1][i]):
            row[k]=i
            k=k+1

    dim=len(GS[3])/len(GS[2])

    for i in range(dim):
        B_i=coo_matrix((GS[3][i::dim],(row,GS[2])))
        r=B_i*Coord
        s=''
        for i in range(dim):
            s=s+'('+str(np.min(r[:,i],0))+' - '+str(np.max(r[:,i],0))+') '
        print s
    
    return
