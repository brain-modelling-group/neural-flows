% Copyright (C) 2003-2011
% Lounes ILLOUL (illoul_lounes@yahoo.fr)
% Philippe LORONG (philippe.lorong@ensam.eu)
% Arts et Metiers ParisTech, Paris, France

function Behav=cal_Behav_Mat_meca(E_NU,n,dim)

if dim==2
    Behav=zeros(3*n,3);
    for i=1:n
        
        if size(E_NU,1)==1
            e_nu=E_NU;
        else
            e_nu=E_NU(i,:);
        end
            
        A=(1-e_nu(2))*e_nu(1)/((1+e_nu(2))*(1-2*e_nu(2)));
        B=e_nu(2)*e_nu(1)/((1+e_nu(2))*(1-2*e_nu(2)));
        C=(A-B)/2;

        Behav(3*(i-1)+1:3*i,:)=[A  B  0.
                                B  A  0.
                                0. 0. C];
    end
else
    Behav=zeros(6*n,6);
    for i=1:n
        
        if size(E_NU,1)==1
            e_nu=E_NU;
        else
            e_nu=E_NU(i,:);
        end
        
        A=(1-e_nu(2))*e_nu(1)/((1+e_nu(2))*(1-2*e_nu(2)));
        B=e_nu(2)*e_nu(1)/((1+e_nu(2))*(1-2*e_nu(2)));
        C=(A-B)/2;

        Behav(6*(i-1)+1:6*i,:)=[A  B  B  0. 0. 0.
                                B  A  B  0. 0. 0.
                                B  B  A  0. 0. 0.
                                0. 0. 0. C  0. 0.
                                0. 0. 0. 0. C  0.
                                0. 0. 0. 0. 0. C];
    end
end

Behav=sparse_block(Behav,size(Behav,2),n);
