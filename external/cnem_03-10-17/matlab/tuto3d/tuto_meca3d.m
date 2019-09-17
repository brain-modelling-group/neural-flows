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

%% mechenical probelm : shearing cube with hole

%% Assembling

n=size(XYZ_Noeud,1);

E_NU=[200e9,0.266];

[B,C,V]= m_assembling_meca(GS,E_NU);
K_Mat_meca=B'*V*C*B;

%% boundary condition definition

Ind_Node_Front=unique(reshape(IN_Tri,1,[]));

UVW=zeros(3*n,1);
DDL_bloc=[];

VW_bh=0.; 
U_h=0.1;
U_b=0.; 

for i=1:size(Ind_Node_Front,2)
    Ind_i=Ind_Node_Front(i);
    N=XYZ_Noeud(Ind_i,:);
    
    if abs(N(1,3)-0.)<1.e-3
        DDL=3*(Ind_i-1)+1+0;
        DDL_bloc=[DDL_bloc,DDL];
        UVW(DDL)=U_b;
        DDL=3*(Ind_i-1)+1+1;
        DDL_bloc=[DDL_bloc,DDL];
        UVW(DDL)=VW_bh;
        DDL=3*(Ind_i-1)+1+2;
        DDL_bloc=[DDL_bloc,DDL];
        UVW(DDL)=VW_bh;
    elseif abs(N(1,3)-1.)<1.e-3
        DDL=3*(Ind_i-1)+1+0;
        DDL_bloc=[DDL_bloc,DDL];
        UVW(DDL)=U_h;
        DDL=3*(Ind_i-1)+1+1;
        DDL_bloc=[DDL_bloc,DDL];
        UVW(DDL)=VW_bh;
        DDL=3*(Ind_i-1)+1+2;
        DDL_bloc=[DDL_bloc,DDL];
        UVW(DDL)=VW_bh;
    end
end

DDL_bloc=unique(DDL_bloc);
DDL_Tot=1:3*n;
DDL_Libre=setdiff(DDL_Tot,DDL_bloc);

%% Solve problem

Vec_B=-K_Mat_meca(:,DDL_bloc)*UVW(DDL_bloc);

UVW(DDL_Libre)=K_Mat_meca(DDL_Libre,DDL_Libre)\Vec_B(DDL_Libre);

%% Post

Sig=C*(B*UVW);

SigMis=((Sig(1:6:size(Sig,1))-Sig(2:6:size(Sig,1))).^2+...
        (Sig(1:6:size(Sig,1))-Sig(3:6:size(Sig,1))).^2+...
        (Sig(2:6:size(Sig,1))-Sig(3:6:size(Sig,1))).^2+...
      6*(Sig(4:6:size(Sig,1)).^2+Sig(5:6:size(Sig,1)).^2+Sig(6:6:size(Sig,1)).^2));
SigMis=(SigMis./2.).^0.5;

UVW=reshape(UVW,3,n)';
Sig=reshape(Sig,6,n)';

%% print result (paraview)

out_var_vtk(XYZ_Noeud(1:n,:),IN_Tet,[Sig,SigMis],UVW,0);

%%