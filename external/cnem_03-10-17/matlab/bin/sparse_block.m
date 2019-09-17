% Copyright (C) 2003-2011
% Lounes ILLOUL (illoul_lounes@yahoo.fr)
% Philippe LORONG (philippe.lorong@ensam.eu)
% Arts et Metiers ParisTech, Paris, France

function SP=sparse_block(vec_mat,m,nb_mat)

nb_mat_bis=size(vec_mat,1)/m;
n=size(vec_mat,2);

const=0;
if nb_mat_bis==1
    const=1;
end

nb_elem=m*n;
nb_elem_glob=nb_elem*nb_mat;

I_SP=zeros(1,nb_elem_glob);
J_SP=zeros(1,nb_elem_glob);

if const==1
    V_SP=zeros(1,nb_elem_glob);
    vec_mat=reshape(vec_mat',nb_elem,1)';
    for i=1:nb_mat
        V_SP(nb_elem*(i-1)+1:nb_elem*i)=vec_mat;
    end    
else
    V_SP=reshape(vec_mat',nb_elem_glob,1)';
end

I=ones(1,n);
for i=1:nb_mat
    J=n*(i-1)+1:n*i;
    for j=1:m
        k=m*(i-1)+j;
        l=n*(k-1)+1:n*k;
        I_SP(l)=k*I;
        J_SP(l)=J;
    end
 end
 
SP=sparse(I_SP,J_SP,V_SP,nb_mat*m,nb_mat*n);
