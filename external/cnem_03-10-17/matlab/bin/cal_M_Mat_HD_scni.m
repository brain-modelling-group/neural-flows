% Copyright (C) 2003-2011
% Lounes ILLOUL (illoul_lounes@yahoo.fr)
% Philippe LORONG (philippe.lorong@ensam.eu)
% Arts et Metiers ParisTech, Paris, France

function Mat=cal_M_Mat_HD_scni(GS,Ro)

Mat=cal_Mat_Vec(Ro.*GS.Vol_C',[1;1;0]);