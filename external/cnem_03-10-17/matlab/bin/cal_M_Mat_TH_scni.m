% Copyright (C) 2003-2011
% Lounes ILLOUL (illoul_lounes@yahoo.fr)
% Philippe LORONG (philippe.lorong@ensam.eu)
% Arts et Metiers ParisTech, Paris, France

function M=cal_M_Mat_TH_scni(GS,Ro,Cap)

M=cal_Mat_Vec(Ro.*Cap.*GS.Vol_C',[1]);
