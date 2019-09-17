% Copyright (C) 2003-2011
% Lounes ILLOUL (illoul_lounes@yahoo.fr)
% Philippe LORONG (philippe.lorong@ensam.eu)
% Arts et Metiers ParisTech, Paris, France

function Mat=cal_Vol_Mat(GS,rep)

Vec=GS.Vol_C';
n=size(Vec,1);
Mat=zeros(rep*n,1);
for i=1:rep
    Mat(i:rep:rep*n,1)=Vec;
end
Mat=spdiags(Mat,0,rep*n,rep*n);
