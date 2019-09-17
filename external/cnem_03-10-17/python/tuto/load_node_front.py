##
## Copyright (C) 2003-2011
## Lounes ILLOUL (illoul_lounes@yahoo.fr)
## Philippe LORONG (philippe.lorong@ensam.eu)
## Arts et Metiers ParisTech, Paris, France
##
## $Revision$ - $Date$

def load2d(data_path):
  
    File = open(data_path+'xy.dat','r')
    XY_Noeud=list()
    for e in File:      
        XY_Noeud.append(float(e))
    File.close()

    Nb_Noeud_Front=list()
    File = open(data_path+'nb_nf.dat','r')
    for e in File:
        Nb_Noeud_Front.append(int(e))
    File.close()

    Ind_Noeud_Front=list()
    File = open(data_path+'ind_nf.dat','r')
    for e in File:
        Ind_Noeud_Front.append(int(e))
    File.close()

    return XY_Noeud,Nb_Noeud_Front,Ind_Noeud_Front

def load3d(data_path):
  
    File = open(data_path+'xyz.dat','r')
    XYZ_Noeud=list()
    for e in File:    
        XYZ_Noeud.append(float(e))
    File.close()

    Tri_Front=list()
    File = open(data_path+'tri.dat','r')
    for e in File:
        Tri_Front.append(int(e))
    File.close()

    return XYZ_Noeud,Tri_Front

