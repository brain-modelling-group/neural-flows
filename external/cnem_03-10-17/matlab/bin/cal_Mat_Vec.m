% Copyright (C) 2003-2011
% Lounes ILLOUL (illoul_lounes@yahoo.fr)
% Philippe LORONG (philippe.lorong@ensam.eu)
% Arts et Metiers ParisTech, Paris, France

function Mat=cal_Mat_Vec(Vec,coef)

n=size(Vec,1);
rep=size(coef,1);
Mat=zeros(rep*n,1);
for i=1:rep
    Mat(i:rep:rep*n,1)=coef(i)*Vec;
end
Mat=spdiags(Mat,0,rep*n,rep*n);
