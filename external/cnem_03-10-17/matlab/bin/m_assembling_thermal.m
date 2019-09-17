% Copyright (C) 2003-2011
% Lounes ILLOUL (illoul_lounes@yahoo.fr)
% Philippe LORONG (philippe.lorong@ensam.eu)
% Arts et Metiers ParisTech, Paris, France

function [B,C,V]= m_assembling_thermal(GS,K)

n=size(GS.Vol_C,2);
dim=size(GS.Grad,1);
nb_var=1;

B=cal_B_Mat_therm(cal_B_Mat(GS,nb_var),dim);
C=cal_Behav_Mat_therm(K,n,dim);
V=cal_Mat_Vec(GS.Vol_C',ones(size(B,1)/n,1));
