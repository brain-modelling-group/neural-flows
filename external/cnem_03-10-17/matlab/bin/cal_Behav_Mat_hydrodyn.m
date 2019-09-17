% Copyright (C) 2003-2011
% Lounes ILLOUL (illoul_lounes@yahoo.fr)
% Philippe LORONG (philippe.lorong@ensam.eu)
% Arts et Metiers ParisTech, Paris, France

function Behav=cal_Behav_Mat_hydrodyn(NU,n,dim)

n_bis=size(NU,1);

PP_couple=0;%mean(NU)*eps;

if dim==2
    Behav=zeros(5*n_bis,5);
    for i=1:n_bis
        Behav(5*(i-1)+1:5*i,:)=[2*NU(i) 0. 0.  0.   -1.
                                0.   NU(i) NU(i)  0.    0.
                                0.   NU(i) NU(i)  0.    0.
                                0.   0. 0.  2*NU(i) -1.
                               -1.   0. 0.  -1.   PP_couple];
    end
else
    Behav=zeros(10*n_bis,10);
    for i=1:n_bis
        Behav(10*(i-1)+1:10*i,:)=[2*NU(i) 0. 0. 0. 0.   0. 0. 0. 0.   -1.
                                  0.   NU(i) 0. NU(i) 0.   0. 0. 0. 0.   0.
                                  0.   0. NU(i) 0. 0.   0. NU(i) 0. 0.   0.
                                  0.   NU(i) 0. NU(i) 0.   0. 0. 0. 0.   0.
                                  0.   0. 0. 0. 2*NU(i) 0. 0. 0. 0.   -1.
                                  0.   0. 0. 0. 0.   NU(i) 0. NU(i) 0.   0.  
                                  0.   0. NU(i) 0. 0.   0. NU(i) 0. 0.   0.
                                  0.   0. 0. 0. 0.   NU(i) 0. NU(i) 0.   0.
                                  0.   0. 0. 0. 0.   0. 0. 0. 2*NU(i) -1
                                  -1.  0. 0. 0. -1.  0. 0. 0. -1.  PP_couple];
    end
end

Behav=sparse_block(Behav,size(Behav,2),n);
