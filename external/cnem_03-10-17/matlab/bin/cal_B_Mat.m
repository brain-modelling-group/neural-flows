% Copyright (C) 2003-2011
% Lounes ILLOUL (illoul_lounes@yahoo.fr)
% Philippe LORONG (philippe.lorong@ensam.eu)
% Arts et Metiers ParisTech, Paris, France

function B = cal_B_Mat(GS,nb_var)

Nb_V=GS.Nb_V;
Ind_V=GS.Ind_V;
Grad=GS.Grad;
Dim=size(Grad,1);
n=size(Nb_V,2);

nb_val=(Dim*sum(Nb_V)+n)*nb_var;
I_B=zeros(1,nb_val);
J_B=zeros(1,nb_val);
V_B=zeros(1,nb_val);
    
L=1;
L_bis=1;

if Dim==2
    for i=1:n
        nb_val_i=2*Nb_V(i)+1;
        J=Ind_V(L:L+Nb_V(i)-1)+1;
        bx=Grad(1,L:L+Nb_V(i)-1);
        by=Grad(2,L:L+Nb_V(i)-1);
        L=L+Nb_V(i);
        for j=1:nb_var
            k=nb_var*(i-1)+j;    
            I=k*ones(1,Nb_V(i));            
            I_B(L_bis:nb_val_i+L_bis-1)=[3*(I-1)+1,3*(I-1)+2,3*k];
            J_B(L_bis:nb_val_i+L_bis-1)=[nb_var*(J-1)+j,nb_var*(J-1)+j,nb_var*(i-1)+j];
            V_B(L_bis:nb_val_i+L_bis-1)=[bx,by,1.];
            L_bis=L_bis+nb_val_i;
        end
    end
else
    for i=1:n
        nb_val_i=3*Nb_V(i)+1;
        J=Ind_V(L:L+Nb_V(i)-1)+1;
        bx=Grad(1,L:L+Nb_V(i)-1);
        by=Grad(2,L:L+Nb_V(i)-1);
        bz=Grad(3,L:L+Nb_V(i)-1);
        L=L+Nb_V(i);
        for j=1:nb_var
            k=nb_var*(i-1)+j;
            I=k*ones(1,Nb_V(i));
            I_B(L_bis:nb_val_i+L_bis-1)=[4*(I-1)+1,4*(I-1)+2,4*(I-1)+3,4*k];
            J_B(L_bis:nb_val_i+L_bis-1)=[nb_var*(J-1)+j,nb_var*(J-1)+j,nb_var*(J-1)+j,nb_var*(i-1)+j];
            V_B(L_bis:nb_val_i+L_bis-1)=[bx,by,bz,1.];
            L_bis=L_bis+nb_val_i;
        end
    end
end
    
B=sparse(I_B,J_B,V_B,nb_var*(Dim+1)*n,nb_var*n);
