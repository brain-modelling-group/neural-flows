% illoul_lounes@yahoo.fr
% ENSAM Paris

clear all;
close all; 
clc;

addpath('../bin');

%% load domain (nodes + boundary(s)) and  draw boundary(s) 

load('data_scni_eig'); 

figure;
tri_out_handle=trimesh(IN_Tri_Ini,XYZ_Noeud(:,1),XYZ_Noeud(:,2),XYZ_Noeud(:,3),'edgecolor','black');
alpha(tri_out_handle,0.5);
axis vis3d
axis equal

%% SCNI integration

Sup_NN_GS = 0;
Type_FF = 0;

[GS,XYZ_Noeud,IN_Tri_Ini,IN_Tri,IN_Tet,INV_NN,PNV_NN,IN_New_Old,IN_Old_New]=...
    m_cnem3d_scni(XYZ_Noeud,IN_Tri_Ini,Type_FF,Sup_NN_GS);

%% Assembling

n=size(XYZ_Noeud,1);

E_NU=[200e9,0.266];
Rho=7800;

[B,C,V]= m_assembling_meca(GS,E_NU);
K_Mat_meca=B'*V*C*B;
M_Mat_meca=Rho*cal_Vol_Mat(GS,3);

%% boundary condition definition

Ind_Node_Front=unique(reshape(IN_Tri,1,[]));

DDL_bloc=[];

for i=1:size(Ind_Node_Front,2)
    Ind_i=Ind_Node_Front(i);
    N=XYZ_Noeud(Ind_i,:);
    
    if abs(N(1,1)-0.)<1.e-3
        DDL=3*(Ind_i-1)+1+0;
        DDL_bloc=[DDL_bloc,DDL];
        DDL=3*(Ind_i-1)+1+1;
        DDL_bloc=[DDL_bloc,DDL];
        DDL=3*(Ind_i-1)+1+2;
        DDL_bloc=[DDL_bloc,DDL];
    end
end

DDL_bloc=unique(DDL_bloc);
DDL_Tot=1:3*n;
DDL_Libre=setdiff(DDL_Tot,DDL_bloc);

%% solve problem

nb_mode=10;
V=zeros(n,nb_mode);
[V(DDL_Libre,:),D]=eigs(K_Mat_meca(DDL_Libre,DDL_Libre),M_Mat_meca(DDL_Libre,DDL_Libre),nb_mode,'sm');

%% Post

V_bis=[];
for i=1:size(V,2)
    V_bis=[V_bis,reshape(V(:,i),3,n)'];
end
V=V_bis;

%% print result (paraview)

out_var_vtk(XYZ_Noeud(1:n,:),IN_Tet,[],5e-4*V,0);

%%