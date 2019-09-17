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

import math
import numpy as np
import scipy as sp
import scipy.sparse as sparse

def cal_B(GS,Var1_to_Var2_i):

    Nb_V=GS[1]
    Ind_V=GS[2]
    Grad=GS[3]
    n=len(Nb_V)
    dim=len(GS[3])/len(GS[2])
    
    nb_var1=Var1_to_Var2_i.shape[1]/(dim+1)
    nb_var2=Var1_to_Var2_i.shape[0]

    Var1_to_Var2=np.tile(Var1_to_Var2_i.flatten(),n).reshape((n,nb_var2,nb_var1*(dim+1)))
    Var1_to_Var2=sparse.csr_matrix(sparse.bsr_matrix((Var1_to_Var2,range(n),range(n+1))))
    
    nb_elem=nb_var1*(dim*sum(Nb_V)+n)
    indptr_B=np.zeros(n*(dim+1)*nb_var1+1,dtype=np.dtype(int));
    indices_B=np.zeros(nb_elem,dtype=np.dtype(int));
    data_B=np.zeros(nb_elem,dtype=np.dtype(float));

    L=0
    M=0
    for i in range(n):
        nbv_i=Nb_V[i]
        J=np.array(Ind_V[L:L+nbv_i])
        bx=Grad[dim*L+0:dim*(L+nbv_i)+0:dim]
        by=Grad[dim*L+1:dim*(L+nbv_i)+1:dim]
        bz=Grad[dim*L+2:dim*(L+nbv_i)+2:dim] if dim==3 else None
        L+=nbv_i
        for j in range(nb_var1):
            k=0
            indptr_B[i*(dim+1)*nb_var1+(dim+1)*j+k+1]=M+nbv_i
            indices_B[M:M+nbv_i]=nb_var1*J+j
            data_B[M:M+nbv_i]=bx
            M+=nbv_i
            k+=1
            indptr_B[i*(dim+1)*nb_var1+(dim+1)*j+k+1]=M+nbv_i
            indices_B[M:M+nbv_i]=nb_var1*J+j
            data_B[M:M+nbv_i]=by
            M+=nbv_i
            k+=1
            if dim==3:
                indptr_B[i*(dim+1)*nb_var1+(dim+1)*j+k+1]=M+nbv_i
                indices_B[M:M+nbv_i]=nb_var1*J+j
                data_B[M:M+nbv_i]=bz
                M+=nbv_i
                k+=1
            indptr_B[i*(dim+1)*nb_var1+(dim+1)*j+k+1]=M+1
            indices_B[M]=nb_var1*i+j
            data_B[M]=1
            M+=1

    B=sparse.csr_matrix((data_B,indices_B,indptr_B),(n*(dim+1)*nb_var1,n*nb_var1));
    del indptr_B,indices_B,data_B
    return Var1_to_Var2*B

def cal_Mas(vol,nb_var0,Rho,Mat=True,Inv=False):

    n=len(vol)
    Vol_Rho=(np.array(vol)*np.array(Rho if len(Rho) == n else n*Rho)).repeat(nb_var0)
    if Inv:
        Vol_Rho=1./Vol_Rho     
    if Mat:
        return sparse.csr_matrix(sparse.dia_matrix((Vol_Rho,np.array([0])),shape=(n*nb_var0,n*nb_var0)))
    else :
        return Vol_Rho

def cal_Vol(vol,nb_var2,Mat=True):

    n=len(vol)
    Vol=np.array([vol]).repeat(nb_var2)
    if Mat:
        return sparse.csr_matrix(sparse.dia_matrix((Vol,np.array([0])),shape=(n*nb_var2,n*nb_var2)))
    else :
        return Vol
    
def cal_B_Meca(GS):
    
    dim=len(GS[3])/len(GS[2])

    Var1_to_Var2_i=np.array([[1.,0.,0.,0., 0.,0.,0.,0., 0.,0.,0.,0.],\
                             [0.,0.,0.,0., 0.,1.,0.,0., 0.,0.,0.,0.],\
                             [0.,0.,0.,0., 0.,0.,0.,0., 0.,0.,1.,0.],\
                             [0.,0.,0.,0., 0.,0.,1.,0., 0.,1.,0.,0.],\
                             [0.,0.,1.,0., 0.,0.,0.,0., 1.,0.,0.,0.],\
                             [0.,1.,0.,0., 1.,0.,0.,0., 0.,0.,0.,0.]]) \
                             if dim==3 else \
                   np.array([[1.,0.,0.,0.,0.,0.],\
                             [0.,0.,0.,0.,1.,0.],\
                             [0.,1.,0.,1.,0.,0.]])
                  
    return cal_B(GS,Var1_to_Var2_i)

def cal_Behav_Meca(n,E_NU,dim):

    Behav=np.zeros(n*6*6) if dim==3 else np.zeros(n*3*3)

    Behav_const=1 if len(E_NU)==1 else 0

    j=0
    for i in range(n):
        e_nu=E_NU[0] if Behav_const else E_NU[i]
        a=(1-e_nu[1])*e_nu[0]/((1+e_nu[1])*(1-2*e_nu[1]))
        b=e_nu[1]*e_nu[0]/((1+e_nu[1])*(1-2*e_nu[1]))
        c=(a-b)/2
        if dim==3:
            Behav[j:j+36]=np.array([a, b, b, 0.,0.,0.,\
                                    b, a, b, 0.,0.,0.,\
                                    b, b, a, 0.,0.,0.,\
                                    0.,0.,0.,c, 0.,0.,\
                                    0.,0.,0.,0.,c, 0.,\
                                    0.,0.,0.,0.,0.,c])
            j+=36
        else :
            Behav[j:j+9]=np.array([a ,b ,0.,\
                                   b ,a ,0.,\
                                   0.,0.,c]);
            j+=9

    Behav=Behav.reshape((n,6,6)) if dim==3 else Behav.reshape((n,3,3))
    return sparse.csr_matrix(sparse.bsr_matrix((Behav,range(n),range(n+1))))
    
def meca(GS,E_NU):

    n=len(GS[0])
    dim=len(GS[3])/len(GS[2])

    B=cal_B_Meca(GS)
    
    Behav=cal_Behav_Meca(n,E_NU,dim)

    Vol=cal_Vol(GS[0],B.shape[0]/n)
    
    return B,Behav,Vol

def cal_B_Thermal(GS):
    
    dim=len(GS[3])/len(GS[2])

    Var1_to_Var2_i=np.array([[1.,0.,0.,0.],\
                             [0.,1.,0.,0.],\
                             [0.,0.,1.,0.]]) \
                             if dim==3 else \
                   np.array([[1.,0.,0.],\
                             [0.,1.,0.]])
                  
    return cal_B(GS,Var1_to_Var2_i)

def cal_Behav_Thermal(n,K,dim):

    Behav=np.zeros(n*3*3) if dim==3 else np.zeros(n*2*2)

    Behav_const=1 if len(K)==1 else 0

    j=0
    for i in range(n):
        k=K[0] if Behav_const else K[i]
        if dim==3:
            Behav[j:j+9]=np.array([k ,0.,0.,\
                                   0.,k ,0.,\
                                   0.,0.,k])
            j+=9
        else :
            Behav[j:j+4]=np.array([k ,0.,\
                                   0.,k]);
            j+=4

    Behav=Behav.reshape((n,3,3)) if dim==3 else Behav.reshape((n,2,2))
    return sparse.csr_matrix(sparse.bsr_matrix((Behav,range(n),range(n+1))))

def thermal(GS,K):

    n=len(GS[0])
    dim=len(GS[3])/len(GS[2])

    B=cal_B_Thermal(GS)

    Behav=cal_Behav_Thermal(n,K,dim)

    Vol=cal_Vol(GS[0],B.shape[0]/n)

    return B,Behav,Vol
    
def cal_B_Hydrodyn(GS):
    
    dim=len(GS[3])/len(GS[2])

    Var1_to_Var2_i=np.array([[1.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.],\
                             [0.,1.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.],\
                             [0.,0.,1.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.],\
                             [0.,0.,0.,0.,1.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.],\
                             [0.,0.,0.,0.,0.,1.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.],\
                             [0.,0.,0.,0.,0.,0.,1.,0.,0.,0.,0.,0.,0.,0.,0.,0.],\
                             [0.,0.,0.,0.,0.,0.,0.,0.,1.,0.,0.,0.,0.,0.,0.,0.],\
                             [0.,0.,0.,0.,0.,0.,0.,0.,0.,1.,0.,0.,0.,0.,0.,0.],\
                             [0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,1.,0.,0.,0.,0.,0.],\
                             [0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,1.]])\
                             if dim==3 else \
                   np.array([[1.,0.,0.,0.,0.,0.,0.,0.,0.],\
                             [0.,1.,0.,0.,0.,0.,0.,0.,0.],\
                             [0.,0.,0.,1.,0.,0.,0.,0.,0.],\
                             [0.,0.,0.,0.,1.,0.,0.,0.,0.],\
                             [0.,0.,0.,0.,0.,0.,0.,0.,1.]])
                  
    return cal_B(GS,Var1_to_Var2_i)

def cal_Behav_Hydrodyn(n,NU,dim):

    Behav=np.zeros(n*10*10) if dim==3 else np.zeros(n*5*5)

    Behav_const=1 if len(NU)==1 else 0

    eps=0.#np.mean(NU)*1.e-16

    j=0
    for i in range(n):
        nu=NU[0] if Behav_const else NU[i]
        if dim==3:
            Behav[j:j+100]=np.array([2*nu ,0.,0.,0.,0.  ,0.,0.,0.,0.  ,-1.,\
                                     0.   ,nu,0.,nu,0.  ,0.,0.,0.,0.  ,0. ,\
                                     0.   ,0.,nu,0.,0.  ,0.,nu,0.,0.  ,0. ,\
                                     0.   ,nu,0.,nu,0.  ,0.,0.,0.,0.  ,0. ,\
                                     0.   ,0.,0.,0.,2*nu,0.,0.,0.,0.  ,-1.,\
                                     0.   ,0.,0.,0.,0.  ,nu,0.,nu,0.  ,0. ,\
                                     0.   ,0.,nu,0.,0.  ,0.,nu,0.,0.  ,0. ,\
                                     0.   ,0.,0.,0.,0.  ,nu,0.,nu,0.  ,0. ,\
                                     0.   ,0.,0.,0.,0.  ,0.,0.,0.,2*nu,-1.,\
                                    -1.   ,0.,0.,0.,-1. ,0.,0.,0.,-1. ,eps])
            j+=100
        else :
            Behav[j:j+25]=np.array([2*nu,0.,0.,0.  ,-1.,\
                                    0.  ,nu,nu,0.  ,0. ,\
                                    0.  ,nu,nu,0.  ,0. ,\
                                    0.  ,0.,0.,2*nu,-1.,\
                                    -1. ,0.,0.,-1. ,eps])
            j+=25

    Behav=Behav.reshape((n,10,10)) if dim==3 else Behav.reshape((n,5,5))
    return sparse.csr_matrix(sparse.bsr_matrix((Behav,range(n),range(n+1))))

def hydrodyn(GS,NU):

    n=len(GS[0])
    dim=len(GS[3])/len(GS[2])
    
    B=cal_B_Hydrodyn(GS)

    Behav=cal_Behav_Hydrodyn(n,NU,dim)

    Vol=cal_Vol(GS[0],B.shape[0]/n)

    return B,Behav,Vol

def cal_Behav_Gen(n,Mat_Couple,dim):

    Behav_const=1 if (Mat_Couple.shape[0]/Mat_Couple.shape[1])==1 else 0
    Mat_Couple=Mat_Couple.flatten()
    if Behav_const :
        Mat_Couple=Mat_Couple.reshape((1,Mat_Couple.shape[0]))
        Mat_Couple=Mat_Couple.repeat(n,axis=1)
   
    Mat_Couple=Mat_Couple.reshape((n,3,3)) if dim==3 else Mat_Couple.reshape((n,2,2))
    return sparse.csr_matrix(sparse.bsr_matrix((Mat_Couple,range(n),range(n+1))))

def gen(GS,Mat_Vars,Mat_Couple):

    n=len(GS[0])
    dim=len(GS[3])/len(GS[2])
    
    B=cal_B(GS,Mat_Vars)

    Behav=cal_Behav_Gen(n,Mat_Couple,dim)

    Vol=cal_Vol(GS[0],B.shape[0]/n)

    return B,Behav,Vol












