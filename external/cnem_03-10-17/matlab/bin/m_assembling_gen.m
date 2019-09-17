% Copyright (C) 2003-2011
% Lounes ILLOUL (illoul_lounes@yahoo.fr)
% Philippe LORONG (philippe.lorong@ensam.eu)
% Arts et Metiers ParisTech, Paris, France

function [B,C,V]= m_assembling_gen(GS,Mat_Vars,Mat_Couple)

n=size(GS.Vol_C,2);
dim=size(GS.Grad,1);
nb_var=size(Mat_Vars,2)/(dim+1);

B=cal_B_Mat_gen(cal_B_Mat(GS,nb_var),Mat_Vars);
C=sparse_block(Mat_Couple,size(Mat_Couple,2),n);
V=cal_Mat_Vec(GS.Vol_C',ones(size(B,1)/n,1));
