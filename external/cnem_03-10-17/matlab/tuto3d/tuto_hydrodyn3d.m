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

%% hydrodynamic problem : fluid flowing around hole

%% Assembling

n=size(XYZ_Noeud,1);

NU=1.;

[B,C,V]=m_assembling_hydrodyn(GS,NU);
K_Mat_HD=B'*V*C*B;

%% boundary condition definition

Ind_Node_Front=unique(reshape(IN_Tri,1,[]));

U_Inf=1.;

C=[0.5,0.5,0.5];
R=0.25;

UVWP=zeros(4*n,1);
DDL_bloc=[];

for i=1:size(Ind_Node_Front,2)
    Ind_i=Ind_Node_Front(i);
    N=XYZ_Noeud(Ind_i,:);
    
    if abs(N(1,1))<1.e-6
        DDL=4*(Ind_i-1)+1+0;
        DDL_bloc=[DDL_bloc,DDL];
        UVWP(DDL)=U_Inf;
        DDL=4*(Ind_i-1)+1+1;
        DDL_bloc=[DDL_bloc,DDL];
        UVWP(DDL)=0;
        DDL=4*(Ind_i-1)+1+2;
        DDL_bloc=[DDL_bloc,DDL];
        UVWP(DDL)=0;
        DDL=4*(Ind_i-1)+1+3;
        DDL_bloc=[DDL_bloc,DDL];
        UVWP(DDL)=1;
    end
    
    if abs(N(1,1)-1)<1.e-6
        DDL=4*(Ind_i-1)+1+0;
        DDL_bloc=[DDL_bloc,DDL];
        UVWP(DDL)=U_Inf;
        DDL=4*(Ind_i-1)+1+1;
        DDL_bloc=[DDL_bloc,DDL];
        UVWP(DDL)=0;
        DDL=4*(Ind_i-1)+1+2;
        DDL_bloc=[DDL_bloc,DDL];
        UVWP(DDL)=0;
    end
        
    if abs(N(1,2))<1.e-6
        DDL=4*(Ind_i-1)+1+1;
        DDL_bloc=[DDL_bloc,DDL];
        UVWP(DDL)=0;
    end
    
    if abs(N(1,2)-1)<1.e-6
        DDL=4*(Ind_i-1)+1+1;
        DDL_bloc=[DDL_bloc,DDL];
        UVWP(DDL)=0;
    end
        
    if abs(N(1,3))<1.e-6
        DDL=4*(Ind_i-1)+1+2;
        DDL_bloc=[DDL_bloc,DDL];
        UVWP(DDL)=0;
    end
    
    if abs(N(1,3)-1)<1.e-6
        DDL=4*(Ind_i-1)+1+2;
        DDL_bloc=[DDL_bloc,DDL];
        UVWP(DDL)=0;
    end
    
    r=sqrt(sum((N-C).^2,2));
    if abs(r-R)<0.1
        DDL=4*(Ind_i-1)+1+0;
        DDL_bloc=[DDL_bloc,DDL];
        UVWP(DDL)=0;
        DDL=4*(Ind_i-1)+1+1;
        DDL_bloc=[DDL_bloc,DDL];
        UVWP(DDL)=0;
        DDL=4*(Ind_i-1)+1+2;
        DDL_bloc=[DDL_bloc,DDL];
        UVWP(DDL)=0;
    end
end

DDL_bloc=unique(DDL_bloc);
DDL_Tot=1:4*n;
DDL_Libre=setdiff(DDL_Tot,DDL_bloc);

%% solve problem

Vec_B=-K_Mat_HD(:,DDL_bloc)*UVWP(DDL_bloc);

UVWP(DDL_Libre)=K_Mat_HD(DDL_Libre,DDL_Libre)\Vec_B(DDL_Libre);

%% print result (paraview)

UVWP=reshape(UVWP,4,n)';

out_var_vtk(XYZ_Noeud,IN_Tet,UVWP(:,4),UVWP(:,1:3),0);

%%