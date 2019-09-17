% Copyright (C) 2003-2011
% Lounes ILLOUL (illoul_lounes@yahoo.fr)
% Philippe LORONG (philippe.lorong@ensam.eu)
% Arts et Metiers ParisTech, Paris, France

function B=cal_B_Mat_hydrodyn_axi_pre(GS)

nb_var=3;

Nb_V_GS=GS.Nb_V;
Ind_V_GS=GS.Ind_V;
Grad=GS.Grad;

Nb_V_Int=GS.Nb_V_Int;
Ind_V_Int=GS.Ind_V_Int;
FF_Int=GS.FF_Int;

nb_CdM_ext=0;
for i=1:size(Nb_V_Int,1)
    if Nb_V_Int(i)==0
       nb_CdM_ext=nb_CdM_ext+1;
    end
end

Dim=2;
n=size(Nb_V_GS,2);

nb_val=(Dim*sum(Nb_V_GS)+sum(Nb_V_Int)+nb_CdM_ext)*2+(Dim*sum(Nb_V_GS)+n);

I_B=zeros(1,nb_val);
J_B=zeros(1,nb_val);
V_B=zeros(1,nb_val);
    
L_GS=1;
L_Int=1;
L_bis=1;

for i=1:n
    
    nb_val_GS_i=2*Nb_V_GS(i);
    J_GS=Ind_V_GS(L_GS:L_GS+Nb_V_GS(i)-1)+1;
    bx=Grad(1,L_GS:L_GS+Nb_V_GS(i)-1);
    by=Grad(2,L_GS:L_GS+Nb_V_GS(i)-1);
    L_GS=L_GS+Nb_V_GS(i);
    
    nb_val_Int_i=Nb_V_Int(i);
    if nb_val_Int_i==0
        nb_val_Int_i=1;
        J_Int=i;
        ff=1;
    else
        J_Int=Ind_V_Int(L_Int:L_Int+Nb_V_Int(i)-1)+1;
        ff=FF_Int(L_Int:L_Int+Nb_V_Int(i)-1);
    end
    L_Int=L_Int+Nb_V_Int(i);
     
    for j=1:2
        k=nb_var*(i-1)+j;    
        I_GS=k*ones(1,Nb_V_GS(i));  
        I_Int=k*ones(1,nb_val_Int_i);
        I_B(L_bis:L_bis+nb_val_GS_i+nb_val_Int_i-1)=[3*(I_GS-1)+1,3*(I_GS-1)+2,3*(I_Int-1)+3];
        J_B(L_bis:L_bis+nb_val_GS_i+nb_val_Int_i-1)=[nb_var*(J_GS-1)+j,nb_var*(J_GS-1)+j,nb_var*(J_Int-1)+j];
        V_B(L_bis:L_bis+nb_val_GS_i+nb_val_Int_i-1)=[bx,by,ff];
        L_bis=L_bis+nb_val_GS_i+nb_val_Int_i;
    end
    
    nb_val_Int_i=1;
    J_Int=i;
    ff=1;
    
    j=3;
    
    k=nb_var*(i-1)+j;    
    I_GS=k*ones(1,Nb_V_GS(i));  
    I_Int=k*ones(1,nb_val_Int_i);
    I_B(L_bis:L_bis+nb_val_GS_i+nb_val_Int_i-1)=[3*(I_GS-1)+1,3*(I_GS-1)+2,3*(I_Int-1)+3];
    J_B(L_bis:L_bis+nb_val_GS_i+nb_val_Int_i-1)=[nb_var*(J_GS-1)+j,nb_var*(J_GS-1)+j,nb_var*(J_Int-1)+j];
    V_B(L_bis:L_bis+nb_val_GS_i+nb_val_Int_i-1)=[bx,by,ff];
    L_bis=L_bis+nb_val_GS_i+nb_val_Int_i;
    
end

B=sparse(I_B,J_B,V_B,nb_var*(Dim+1)*n,nb_var*n);
