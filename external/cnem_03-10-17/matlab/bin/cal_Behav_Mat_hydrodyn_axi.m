% Copyright (C) 2003-2011
% Lounes ILLOUL (illoul_lounes@yahoo.fr)
% Philippe LORONG (philippe.lorong@ensam.eu)
% Arts et Metiers ParisTech, Paris, France

function Behav=cal_Behav_Mat_hydrodyn_axi(NU,n,r)

PP_couple=0;%mean(NU)*eps;

Behav=zeros(7*n,7);
for i=1:n
    if size(NU,1)==n
        NU_i=NU(i);
    else
        NU_i=NU;
    end
    Behav(7*(i-1)+1:7*i,:)=[2*NU_i  0.    0. 0.    0.      0. -1.
                            0.      NU_i  0. NU_i  0.      0. 0.
                            0.      0.    2*NU_i /(r(i)*r(i)) 0.    0.      0. -1/r(i)
                            0.      NU_i  0. NU_i  0.      0. 0.
                            0.      0.    0. 0.    2*NU_i  0. -1.
                            0.      0.    0. 0.    0.      0. 0.
                            -1.     0.    -1/r(i)  0.     -1. 0. PP_couple];
end

Behav=sparse_block(Behav,size(Behav,2),n);
