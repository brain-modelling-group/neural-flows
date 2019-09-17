% Copyright (C) 2003-2011
% Lounes ILLOUL (illoul_lounes@yahoo.fr)
% Philippe LORONG (philippe.lorong@ensam.eu)
% Arts et Metiers ParisTech, Paris, France

function [B,C,V]= m_assembling_hydrodyn_axi(GS,NU)

n=size(GS.Vol_C,2);
nb_var=3;

B=cal_B_Mat_hydrodyn_axi_pre(GS,nb_var);
B=cal_B_Mat_hydrodyn_axi(B);
C=cal_Behav_Mat_hydrodyn_axi(NU,n,GS.r);
V=cal_Mat_Vec(GS.Vol_C',ones(size(B,1)/n,1));

