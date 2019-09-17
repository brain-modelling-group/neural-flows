% illoul_lounes@yahoo.fr
% ENSAM Paris

clear all;
close all; 
clc;

addpath('../bin');

%% load domain (nodes + boundary(s)) and  draw boundary(s) 

load('data_scni_mth_1'); 

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

%% thermal problem : 

%% Assembling

n=size(XYZ_Noeud,1);

K=1.;

[B,C,V]= m_assembling_thermal(GS,K);
K_Mat_T=B'*V*C*B;

%% boundary condition definition

Ind_Node_Front=unique(reshape(IN_Tri,1,[]));

T1=0;
T2=1;

C=[0.5,0.5,0.5];
R=0.25;

T=zeros(n,1);
DDL_bloc=[];

for i=1:size(Ind_Node_Front,2)
    Ind_i=Ind_Node_Front(i);
    N=XYZ_Noeud(Ind_i,:);
    r=sqrt(sum((N-C).^2,2));
    if abs(r-R)<0.1
        DDL=Ind_i;
        DDL_bloc=[DDL_bloc,DDL];
        T(DDL)=T1;
    else
        DDL=Ind_i;
        DDL_bloc=[DDL_bloc,DDL];
        T(DDL)=T2;
    end
end

DDL_bloc=unique(DDL_bloc);
DDL_Tot=1:n;
DDL_Libre=setdiff(DDL_Tot,DDL_bloc);

%% solve problem

Vec_B=-K_Mat_T(:,DDL_bloc)*T(DDL_bloc);
T(DDL_Libre)=K_Mat_T(DDL_Libre,DDL_Libre)\Vec_B(DDL_Libre);

%% post

Grad_T=B*T;
Grad_T=reshape(Grad_T,3,n)';

%% print result (paraview)

out_var_vtk(XYZ_Noeud(1:n,:),IN_Tet,T,Grad_T,0);

%%