% Copyright (C) 2003-2011
% Lounes ILLOUL (illoul_lounes@yahoo.fr)
% Philippe LORONG (philippe.lorong@ensam.eu)
% Arts et Metiers ParisTech, Paris, France

function Behav=cal_Behav_Mat_therm(K,n,dim)

n_bis=size(K,1);

if dim==2
    Behav=zeros(2*n_bis,2);
    for i=1:n_bis
        Behav(2*(i-1)+1:2*i,:)=[K(i) 0
                                0 K(i)];
    end
else
    Behav=zeros(3*n_bis,3);
    for i=1:n_bis
        Behav(3*(i-1)+1:3*i,:)=[K(i)  0. 0.
                                0. K(i)  0.
                                0. 0. K(i)];
    end
end

Behav=sparse_block(Behav,size(Behav,2),n);
