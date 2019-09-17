% illoul_lounes@yahoo.fr
% ENSAM Paris

clc;
clear all;
close all;
delete var_*.vtk;

addpath('func_meca_explicite');

addpath('../bin');

%% load domain (nodes + boundary(s)) and  draw boundary(s) 

load('data_scni_exp');

figure;
tri_out_handle=trimesh(IN_Tri_Ini,XYZ_Noeud(:,1),XYZ_Noeud(:,2),XYZ_Noeud(:,3),'edgecolor','black');
alpha(tri_out_handle,0.5);
axis vis3d
axis equal

%% SCNI integration

Sup_NN_GS = 1;
Type_FF = 0;

[GS,XYZ_Noeud,IN_Tri_Ini,IN_Tri,IN_Tet,INV_NN,PNV_NN,IN_New_Old,IN_Old_New]=...
    m_cnem3d_scni(XYZ_Noeud,IN_Tri_Ini,Type_FF,Sup_NN_GS);

%% Assembling

E_NU=[200e9,0.266];
Rho=7800;

n=size(XYZ_Noeud,1);
nb_var=3;
dim=3;

B_Mat_meca=cal_B_Mat_meca(cal_B_Mat(GS,nb_var),dim);
Behav_Mat_meca=cal_Behav_Mat_meca(E_NU,n,dim);
Vol_Mat_meca=cal_Vol_Mat(GS,size(B_Mat_meca,1)/n);
M_Mat_meca=Rho*diag(cal_Vol_Mat(GS,3));

%% Solve the macanical problem

U=zeros(3*n,1);
%U(1:3:3*n,:)=1.e-2*XYZ_Noeud(1:n,1);
Uo=zeros(3*n,1);
Uo(1:3:3*n,:)=-1.*ones(n,1);
Uoo=zeros(3*n,1);

Coef_Reduc_Pas_Temps=0.5;
dist_node_min=0.5e-3;
celerite=sqrt(E_NU(1)/Rho);

dt=Coef_Reduc_Pas_Temps*dist_node_min/celerite;

SigMis=zeros(n,1);

t=0;
nb_inc=500;
inc=1;

Vec_ED=zeros(nb_inc,1);
Vec_EC=zeros(nb_inc,1);
Vec_t=zeros(nb_inc,1);

while inc<=nb_inc
    
    def=B_Mat_meca*U;
    Sig=Behav_Mat_meca*def;

    SigMis=cal_VonMises(Sig);

    SigMis=(SigMis./2.).^0.5;
  
    FInt=-B_Mat_meca'*(Vol_Mat_meca*Sig);
   
    Vec_ED(inc)=-U'*FInt;
    Vec_EC(inc)=(M_Mat_meca.*Uo)'*Uo;
    Vec_t(inc)=t;
    
    %----------------------------------------------------------------
    
    FExt=cal_FExt(XYZ_Noeud,IN_Tri_Ini,n);
    
    %----------------------------------------------------------------
    
    F=FInt;%+FExt;
    Uoo=F./M_Mat_meca;
    Uo_pred=Uo+Uoo*dt;
    dU_pred=Uo_pred*dt;
    
    dU=Impos_U(XYZ_Noeud,U,dU_pred,n);
    Uo=dU/dt;
    U=U+dU;
    
    %----------------------------------------------------------------
    
    t=t+dt;
    
    if mod(inc,3)==0 && inc < 500
        out_var_vtk(XYZ_Noeud(1:n,:),IN_Tri_Ini,SigMis,reshape(U,3,n)',inc);
    end
    
    inc=inc+1
end

figure
hold on
plot(Vec_t,Vec_EC,'color','b','LineWidth',2);
plot(Vec_t,Vec_ED,'color','r','LineWidth',2);
plot(Vec_t,Vec_ED+Vec_EC,'color','g','LineWidth',2);
hold off

%--------------------------------------------------------------------