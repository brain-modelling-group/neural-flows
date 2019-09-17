% Copyright (C) 2003-2011
% Lounes ILLOUL (illoul_lounes@yahoo.fr)
% Philippe LORONG (philippe.lorong@ensam.eu)
% Arts et Metiers ParisTech, Paris, France

clc
clear all;
close all; 
clc;
addpath('../bin');

%% load domain (nodes + boundary(s)) and  draw boundary(s) 

load('data_small');% the domain : nodes + bounary(s) 

% plot 
% boundarys

figure;
hold on;
axis equal;

plot_boundary(XY_Node,Nb_Node_Front,Ind_Node_Front);

% node

plot(XY_Node(:,1),XY_Node(:,2),'.','color','green');

hold off;

%% SCNI integration

[GS,XY_Node,Ind_Node_Front,Ind_Node_Tri,Ind_Node_New_Old,Ind_Node_Old_New,Cel]=...
m_cnem2d_scni(XY_Node,Nb_Node_Front,Ind_Node_Front);

%plot constrained Delaunay mesh

figure
hold on;
axis equal;
trimesh(Ind_Node_Tri,XY_Node(:,1),XY_Node(:,2),'color','red');
hold off;

%%  Laplace’s Equation problem :

%% Assembling

n=size(XY_Node,1);

Mat_A=[1. 0. 0.
       0. 1. 0.];  

% constant
%Mat_D=[1. 0.
%       0. 1.]; 

% variable 
Mat_D=zeros(2*n,2); 
Mat_D(1:2:2*n,1)=XY_Node(:,1)+0.1;
Mat_D(2:2:2*n,2)=XY_Node(:,1)+0.1;

[B,C,V]= m_assembling_gen(GS,Mat_A,Mat_D);
Mat_A=B'*V*C*B;

%% boundary condition definition

V1=0; % Var value at external boundary 
V2=1; % Var value at internal boundary

n=size(XY_Node,1);
n_C_ext=Ind_Node_Front([1:Nb_Node_Front(1)]);
n_C_int=Ind_Node_Front([Nb_Node_Front(1)+1:Nb_Node_Front(1)+Nb_Node_Front(2)]);

Var=zeros(n,1);
Var(n_C_ext')=V1;
Var(n_C_int')=V2;

DDL_bloc=unique([n_C_ext;n_C_int]);

DDL_Tot=1:n;
DDL_Libre=setdiff(DDL_Tot,DDL_bloc);

%% solve problem

Vec_B=-Mat_A(:,DDL_bloc)*Var(DDL_bloc);
Var(DDL_Libre)=Mat_A(DDL_Libre,DDL_Libre)\Vec_B(DDL_Libre);

%% post

Grad_Var=B*Var;
Grad_Var=reshape(Grad_Var,2,n)';

%% Plot result

%Var

h=figure;
set(h,'Name','var iso');
hold on;
axis equal;
colormap jet
tricontour([XY_Node(:,1),XY_Node(:,2)],Ind_Node_Tri,Var,10);
hold off;

h=figure;
set(h,'Name','Var');
hold on;
axis equal;
colormap jet;
%trisurf(Ind_Node_Tri,XY_Node(:,1),XY_Node(:,2),zeros(size(XY_Node(:,1))),'FaceVertexCData',Var,'FaceColor','interp','EdgeColor','none','FaceLighting','none');
plot_cel_vc(Cel,Var);
hold off;

%Grad Var

h=figure;
set(h,'Name','grad var');
hold on;
axis equal;
quiver(XY_Node(:,1),XY_Node(:,2),Grad_Var(:,1),Grad_Var(:,2));
hold off;

%%